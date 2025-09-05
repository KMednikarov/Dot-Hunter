import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dot {
  Offset position;
  Offset velocity;
  final Color color;
  final double radius;

  Dot({
    required this.position,
    required this.velocity,
    required this.color,
    this.radius = 15,
  });
}

class GameState {
  final List<Dot> dots;
  final int score;
  final int lives;
  final int maxLives;
  final double speedMultiplier;
  final int speedIncreaseCount;
  final bool isGameOver;
  final bool isPaused;
  final int slowPowerupCharges;
  final bool isSlowActive;
  final int freezePowerupCharges;
  final bool isFreezeActive;
  final int shieldPowerupCharges;
  final bool isShieldActive;
  final double slowCooldown;
  final double freezeCooldown;
  final double shieldCooldown;

  GameState({
    required this.dots,
    required this.score,
    required this.lives,
    required this.maxLives,
    required this.speedMultiplier,
    required this.speedIncreaseCount,
    required this.isGameOver,
    required this.isPaused,
    required this.slowPowerupCharges,
    required this.isSlowActive,
    required this.freezePowerupCharges,
    required this.isFreezeActive,
    required this.shieldPowerupCharges,
    required this.isShieldActive,
    required this.slowCooldown,
    required this.freezeCooldown,
    required this.shieldCooldown,
  });

  factory GameState.initial(Random rand, int count) {
    final dots = List.generate(count, (i) {
      final isRed = i == 0;
      return Dot(
        position: Offset(rand.nextDouble() * 300, rand.nextDouble() * 500),
        velocity: Offset((rand.nextDouble() * 2 - 1) * 2, (rand.nextDouble() * 2 - 1) * 2),
        color: isRed
            ? Colors.red
            : Color.fromARGB(255, rand.nextInt(256), rand.nextInt(256), rand.nextInt(256)),
        radius: isRed ? 20 : 15,
      );
    });
    return GameState(
      dots: dots,
      score: 0,
      lives: 5,
      maxLives: 5,
      speedMultiplier: 1.0,
      speedIncreaseCount: 0,
      isGameOver: false,
      isPaused: false,
      slowPowerupCharges: 3,
      isSlowActive: false,
      freezePowerupCharges: 3,
      isFreezeActive: false,
      shieldPowerupCharges: 3,
      isShieldActive: false,
      slowCooldown: 0,
      freezeCooldown: 0,
      shieldCooldown: 0,
    );
  }

  GameState copyWith({
    List<Dot>? dots,
    int? score,
    int? lives,
    int? maxLives,
    double? speedMultiplier,
    int? speedIncreaseCount,
    bool? isGameOver,
    bool? isPaused,
    int? slowPowerupCharges,
    bool? isSlowActive,
    int? freezePowerupCharges,
    bool? isFreezeActive,
    int? shieldPowerupCharges,
    bool? isShieldActive,
    double? slowCooldown,
    double? freezeCooldown,
    double? shieldCooldown,
  }) {
    return GameState(
      dots: dots ?? this.dots,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      speedIncreaseCount: speedIncreaseCount ?? this.speedIncreaseCount,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      slowPowerupCharges: slowPowerupCharges ?? this.slowPowerupCharges,
      isSlowActive: isSlowActive ?? this.isSlowActive,
      freezePowerupCharges:
          freezePowerupCharges ?? this.freezePowerupCharges,
      isFreezeActive: isFreezeActive ?? this.isFreezeActive,
      shieldPowerupCharges:
          shieldPowerupCharges ?? this.shieldPowerupCharges,
      isShieldActive: isShieldActive ?? this.isShieldActive,
      slowCooldown: slowCooldown ?? this.slowCooldown,
      freezeCooldown: freezeCooldown ?? this.freezeCooldown,
      shieldCooldown: shieldCooldown ?? this.shieldCooldown,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial(Random(), 6)) {
    _loadPurchases();
    _startTicker();
    _analytics.logEvent(name: 'level_start');
  }

  final Random _rand = Random();
  final int _dotCount = 6;
  Size _areaSize = Size.zero;
  Timer? _timer;
  Timer? _slowTimer;
  Timer? _freezeTimer;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static const double _powerupCooldown = 5.0;

  void _startTicker() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _onTick());
  }

  void updateAreaSize(Size size) {
    _areaSize = size;
  }

  void _onTick() {
    if (_areaSize == Size.zero || state.isGameOver || state.isPaused) return;
    final newDots = state.isFreezeActive
        ? state.dots
        : state.dots.map((dot) {
            final slowFactor = state.isSlowActive ? 0.5 : 1.0;
            var newPos =
                dot.position + dot.velocity * state.speedMultiplier * slowFactor;
            var newVel = dot.velocity;
            if (newPos.dx <= dot.radius ||
                newPos.dx >= _areaSize.width - dot.radius) {
              newVel = Offset(-newVel.dx, newVel.dy);
            }
            if (newPos.dy <= dot.radius ||
                newPos.dy >= _areaSize.height - dot.radius) {
              newVel = Offset(newVel.dx, -newVel.dy);
            }
            return Dot(
                position: newPos,
                velocity: newVel,
                color: dot.color,
                radius: dot.radius);
          }).toList();
    final newSlowCooldown = state.slowCooldown > 0
        ? (state.slowCooldown - 0.016).clamp(0.0, _powerupCooldown).toDouble()
        : 0.0;
    final newFreezeCooldown = state.freezeCooldown > 0
        ? (state.freezeCooldown - 0.016).clamp(0.0, _powerupCooldown).toDouble()
        : 0.0;
    final newShieldCooldown = state.shieldCooldown > 0
        ? (state.shieldCooldown - 0.016).clamp(0.0, _powerupCooldown).toDouble()
        : 0.0;
    emit(state.copyWith(
      dots: newDots,
      slowCooldown: newSlowCooldown,
      freezeCooldown: newFreezeCooldown,
      shieldCooldown: newShieldCooldown,
    ));
  }

  void useSlowPowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.slowPowerupCharges <= 0 || state.isSlowActive || state.slowCooldown > 0) return;
    emit(state.copyWith(
      slowPowerupCharges: state.slowPowerupCharges - 1,
      isSlowActive: true,
      slowCooldown: _powerupCooldown,
    ));

    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(isSlowActive: false));
      }
    });

    _analytics.logEvent(name: 'power_up_used', parameters: {'type': 'slow'});
  }

  void useFreezePowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.freezePowerupCharges <= 0 || state.isFreezeActive || state.freezeCooldown > 0) return;
    emit(state.copyWith(
      freezePowerupCharges: state.freezePowerupCharges - 1,
      isFreezeActive: true,
      freezeCooldown: _powerupCooldown,
    ));

    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(isFreezeActive: false));
      }
    });

    _analytics.logEvent(name: 'power_up_used', parameters: {'type': 'freeze'});
  }

  void useShieldPowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.shieldPowerupCharges <= 0 || state.isShieldActive || state.shieldCooldown > 0) return;
    emit(state.copyWith(
      shieldPowerupCharges: state.shieldPowerupCharges - 1,
      isShieldActive: true,
      shieldCooldown: _powerupCooldown,
    ));

    _analytics.logEvent(name: 'power_up_used', parameters: {'type': 'shield'});
  }

  void handleTap(Offset tapPos) async {
    if (state.isGameOver || state.isPaused) return;
    bool hitRed = false;
    for (final dot in state.dots) {
      final dist = (dot.position - tapPos).distance;
      if (dist <= dot.radius) {
        if (dot.color == Colors.red) {
          hitRed = true;
        }
        break;
      }
    }

    if (hitRed) {
      final newCount = state.speedIncreaseCount + 1;
      var newDots = state.dots;
      if (newCount % 2 == 0) {
        newDots = state.dots.map((dot) {
          if (dot.color == Colors.red) return dot;
          return Dot(
            position: dot.position,
            velocity: dot.velocity,
            color: Color.fromARGB(
              255,
              _rand.nextInt(256),
              _rand.nextInt(256),
              _rand.nextInt(256),
            ),
            radius: dot.radius,
          );
        }).toList();
      }
      emit(state.copyWith(
        score: state.score + 1,
        speedMultiplier: state.speedMultiplier * 1.05,
        speedIncreaseCount: newCount,
        dots: newDots,
      ));
    } else {
      if (state.isShieldActive) {
        emit(state.copyWith(isShieldActive: false));
      } else {
        final lives = state.lives - 1;
        if (lives <= 0) {
          await _saveScore();
          await _analytics
              .logEvent(name: 'level_end', parameters: {'score': state.score});
          emit(state.copyWith(lives: 0, isGameOver: true));
        } else {
          emit(state.copyWith(lives: lives));
        }
      }
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores') ?? [];
    scores.add(state.score.toString());
    await prefs.setStringList('scores', scores);
  }

  Future<void> _loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final extraLives = prefs.getInt('extraLives') ?? 0;
    final extraPowerups = prefs.getInt('extraPowerups') ?? 0;

    if (extraLives > 0 || extraPowerups > 0) {
      emit(state.copyWith(
        lives: state.lives + extraLives,
        maxLives: state.maxLives + extraLives,
        slowPowerupCharges: state.slowPowerupCharges + extraPowerups,
        freezePowerupCharges: state.freezePowerupCharges + extraPowerups,
        shieldPowerupCharges: state.shieldPowerupCharges + extraPowerups,
      ));
    }
  }

  void restart() {
    _slowTimer?.cancel();
    _freezeTimer?.cancel();
    emit(GameState.initial(_rand, _dotCount));
    _analytics.logEvent(name: 'level_start');
  }

  void togglePause() {
    if (state.isGameOver) return;
    emit(state.copyWith(isPaused: !state.isPaused));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _slowTimer?.cancel();
    _freezeTimer?.cancel();
    return super.close();
  }
}
