import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final double slowCooldownProgress;
  final int freezePowerupCharges;
  final bool isFreezeActive;
  final double freezeCooldownProgress;
  final int shieldPowerupCharges;
  final bool isShieldActive;
  final double shieldCooldownProgress;

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
    required this.slowCooldownProgress,
    required this.freezePowerupCharges,
    required this.isFreezeActive,
    required this.freezeCooldownProgress,
    required this.shieldPowerupCharges,
    required this.isShieldActive,
    required this.shieldCooldownProgress,
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
      slowPowerupCharges: 2,
      isSlowActive: false,
      slowCooldownProgress: 1.0,
      freezePowerupCharges: 2,
      isFreezeActive: false,
      freezeCooldownProgress: 1.0,
      shieldPowerupCharges: 1,
      isShieldActive: false,
      shieldCooldownProgress: 1.0,
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
    double? slowCooldownProgress,
    int? freezePowerupCharges,
    bool? isFreezeActive,
    double? freezeCooldownProgress,
    int? shieldPowerupCharges,
    bool? isShieldActive,
    double? shieldCooldownProgress,
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
      slowCooldownProgress: slowCooldownProgress ?? this.slowCooldownProgress,
      freezePowerupCharges:
          freezePowerupCharges ?? this.freezePowerupCharges,
      isFreezeActive: isFreezeActive ?? this.isFreezeActive,
      freezeCooldownProgress:
          freezeCooldownProgress ?? this.freezeCooldownProgress,
      shieldPowerupCharges:
          shieldPowerupCharges ?? this.shieldPowerupCharges,
      isShieldActive: isShieldActive ?? this.isShieldActive,
      shieldCooldownProgress:
          shieldCooldownProgress ?? this.shieldCooldownProgress,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial(Random(), 6)) {
    _startTicker();
  }

  final Random _rand = Random();
  final int _dotCount = 6;
  Size _areaSize = Size.zero;
  Timer? _timer;
  Timer? _slowTimer;
  Timer? _freezeTimer;
  DateTime? _slowCooldownStart;
  DateTime? _freezeCooldownStart;
  DateTime? _shieldCooldownStart;
  final Duration _slowCooldownDuration = const Duration(seconds: 10);
  final Duration _freezeCooldownDuration = const Duration(seconds: 10);
  final Duration _shieldCooldownDuration = const Duration(seconds: 15);

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
    var newState = state.copyWith(dots: newDots);
    newState = _updateCooldowns(newState);
    emit(newState);
  }

  GameState _updateCooldowns(GameState base) {
    final now = DateTime.now();

    // Slow power-up cooldown
    var slowCharges = base.slowPowerupCharges;
    var slowProgress = base.slowCooldownProgress;
    if (slowCharges < 2) {
      _slowCooldownStart ??= now;
      slowProgress = (now.difference(_slowCooldownStart!).inMilliseconds /
              _slowCooldownDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      if (slowProgress >= 1.0) {
        slowCharges += 1;
        if (slowCharges < 2) {
          _slowCooldownStart = now;
          slowProgress = 0.0;
        } else {
          _slowCooldownStart = null;
          slowProgress = 1.0;
        }
      }
    } else {
      slowProgress = 1.0;
      _slowCooldownStart = null;
    }

    // Freeze power-up cooldown
    var freezeCharges = base.freezePowerupCharges;
    var freezeProgress = base.freezeCooldownProgress;
    if (freezeCharges < 2) {
      _freezeCooldownStart ??= now;
      freezeProgress = (now.difference(_freezeCooldownStart!).inMilliseconds /
              _freezeCooldownDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      if (freezeProgress >= 1.0) {
        freezeCharges += 1;
        if (freezeCharges < 2) {
          _freezeCooldownStart = now;
          freezeProgress = 0.0;
        } else {
          _freezeCooldownStart = null;
          freezeProgress = 1.0;
        }
      }
    } else {
      freezeProgress = 1.0;
      _freezeCooldownStart = null;
    }

    // Shield power-up cooldown
    var shieldCharges = base.shieldPowerupCharges;
    var shieldProgress = base.shieldCooldownProgress;
    if (shieldCharges < 1) {
      _shieldCooldownStart ??= now;
      shieldProgress = (now.difference(_shieldCooldownStart!).inMilliseconds /
              _shieldCooldownDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      if (shieldProgress >= 1.0) {
        shieldCharges = 1;
        _shieldCooldownStart = null;
        shieldProgress = 1.0;
      }
    } else {
      shieldProgress = 1.0;
      _shieldCooldownStart = null;
    }

    return base.copyWith(
      slowPowerupCharges: slowCharges,
      slowCooldownProgress: slowProgress,
      freezePowerupCharges: freezeCharges,
      freezeCooldownProgress: freezeProgress,
      shieldPowerupCharges: shieldCharges,
      shieldCooldownProgress: shieldProgress,
    );
  }

  void useSlowPowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.slowPowerupCharges <= 0 || state.isSlowActive) return;
    emit(state.copyWith(
      slowPowerupCharges: state.slowPowerupCharges - 1,
      isSlowActive: true,
      slowCooldownProgress: 0.0,
    ));

    _slowCooldownStart ??= DateTime.now();

    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(isSlowActive: false));
      }
    });
  }

  void useFreezePowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.freezePowerupCharges <= 0 || state.isFreezeActive) return;
    emit(state.copyWith(
      freezePowerupCharges: state.freezePowerupCharges - 1,
      isFreezeActive: true,
      freezeCooldownProgress: 0.0,
    ));

    _freezeCooldownStart ??= DateTime.now();

    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(isFreezeActive: false));
      }
    });
  }

  void useShieldPowerup() {
    if (state.isGameOver || state.isPaused) return;
    if (state.shieldPowerupCharges <= 0 || state.isShieldActive) return;
    emit(state.copyWith(
      shieldPowerupCharges: state.shieldPowerupCharges - 1,
      isShieldActive: true,
      shieldCooldownProgress: 0.0,
    ));

    _shieldCooldownStart ??= DateTime.now();
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

  void restart() {
    _slowTimer?.cancel();
    _freezeTimer?.cancel();
    _slowCooldownStart = null;
    _freezeCooldownStart = null;
    _shieldCooldownStart = null;
    emit(GameState.initial(_rand, _dotCount));
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
