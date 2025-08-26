import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'leaderboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Hunter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const GamePage(),
    );
  }
}

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

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  final Random _rand = Random();
  final int _dotCount = 6;
  late final Ticker _ticker;
  final List<Dot> _dots = [];
  int _score = 0;
  int _lives = 5;
  double _speedMultiplier = 1.0;
  bool _isGameOver = false;
  Size _areaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initDots();
    _ticker = createTicker(_onTick)..start();
  }

  void _initDots() {
    _dots.clear();
    for (int i = 0; i < _dotCount; i++) {
      final isRed = i == 0;
      _dots.add(
        Dot(
          position: Offset(_rand.nextDouble() * 300, _rand.nextDouble() * 500),
          velocity: Offset((_rand.nextDouble() * 2 - 1) * 2, (_rand.nextDouble() * 2 - 1) * 2),
          color: isRed ? Colors.red : Color.fromARGB(255, _rand.nextInt(256), _rand.nextInt(256), _rand.nextInt(256)),
          radius: 15,
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    if (_areaSize == Size.zero || _isGameOver) return;
    setState(() {
      for (final dot in _dots) {
        dot.position = dot.position + dot.velocity * _speedMultiplier;
        if (dot.position.dx <= dot.radius || dot.position.dx >= _areaSize.width - dot.radius) {
          dot.velocity = Offset(-dot.velocity.dx, dot.velocity.dy);
        }
        if (dot.position.dy <= dot.radius || dot.position.dy >= _areaSize.height - dot.radius) {
          dot.velocity = Offset(dot.velocity.dx, -dot.velocity.dy);
        }
      }
    });
  }

  void _handleTap(TapUpDetails details) {
    if (_isGameOver) return;
    final tapPos = details.localPosition;
    bool hitRed = false;
    bool hitAny = false;
    for (final dot in _dots) {
      final dist = (dot.position - tapPos).distance;
      if (dist <= dot.radius) {
        hitAny = true;
        if (dot.color == Colors.red) {
          hitRed = true;
        }
        break;
      }
    }

    if (hitRed) {
      setState(() {
        _score++;
        _speedMultiplier *= 1.1;
      });
    } else {
      setState(() {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _ticker.stop();
          _onGameOver();
        }
      });
    }
  }

  Future<void> _onGameOver() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores') ?? [];
    scores.add(_score.toString());
    await prefs.setStringList('scores', scores);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Score: '+_score.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                );
              },
              child: const Text('Leaderboard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restart();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _restart() {
    setState(() {
      _score = 0;
      _lives = 5;
      _speedMultiplier = 1.0;
      _isGameOver = false;
      _initDots();
      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Hunter'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _areaSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: _handleTap,
            child: Stack(
              children: [
                ..._dots.map(
                  (dot) => Positioned(
                    left: dot.position.dx - dot.radius,
                    top: dot.position.dy - dot.radius,
                    child: Container(
                      width: dot.radius * 2,
                      height: dot.radius * 2,
                      decoration: BoxDecoration(
                        color: dot.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text('Score: '+_score.toString()),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text('Lives: '+_lives.toString()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

