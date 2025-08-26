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
  final bool isGameOver;

  GameState({
    required this.dots,
    required this.score,
    required this.lives,
    required this.maxLives,
    required this.speedMultiplier,
    required this.isGameOver,
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
        radius: 15,
      );
    });
    return GameState(
      dots: dots,
      score: 0,
      lives: 5,
      maxLives: 5,
      speedMultiplier: 1.0,
      isGameOver: false,
    );
  }

  GameState copyWith({
    List<Dot>? dots,
    int? score,
    int? lives,
    int? maxLives,
    double? speedMultiplier,
    bool? isGameOver,
  }) {
    return GameState(
      dots: dots ?? this.dots,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      isGameOver: isGameOver ?? this.isGameOver,
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

  void _startTicker() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _onTick());
  }

  void updateAreaSize(Size size) {
    _areaSize = size;
  }

  void _onTick() {
    if (_areaSize == Size.zero || state.isGameOver) return;
    final newDots = state.dots.map((dot) {
      var newPos = dot.position + dot.velocity * state.speedMultiplier;
      var newVel = dot.velocity;
      if (newPos.dx <= dot.radius || newPos.dx >= _areaSize.width - dot.radius) {
        newVel = Offset(-newVel.dx, newVel.dy);
      }
      if (newPos.dy <= dot.radius || newPos.dy >= _areaSize.height - dot.radius) {
        newVel = Offset(newVel.dx, -newVel.dy);
      }
      return Dot(position: newPos, velocity: newVel, color: dot.color, radius: dot.radius);
    }).toList();
    emit(state.copyWith(dots: newDots));
  }

  void handleTap(Offset tapPos) async {
    if (state.isGameOver) return;
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
      emit(state.copyWith(
        score: state.score + 1,
        speedMultiplier: state.speedMultiplier * 1.1,
      ));
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

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores') ?? [];
    scores.add(state.score.toString());
    await prefs.setStringList('scores', scores);
  }

  void restart() {
    emit(GameState.initial(_rand, _dotCount));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
