import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/game_cubit.dart';
import 'leaderboard_page.dart';

class GamePage extends StatelessWidget {
  final bool glowEnabled;
  const GamePage({super.key, required this.glowEnabled});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: _GameView(glowEnabled: glowEnabled),
    );
  }
}

class _GameView extends StatefulWidget {
  final bool glowEnabled;
  const _GameView({required this.glowEnabled});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.glowEnabled) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Hunter'),
        actions: [
          BlocBuilder<GameCubit, GameState>(
            buildWhen: (p, c) => p.isPaused != c.isPaused,
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: () => context.read<GameCubit>().togglePause(),
              );
            },
          ),
        ],
      ),
      body: BlocListener<GameCubit, GameState>(
        listenWhen: (previous, current) =>
            !previous.isGameOver && current.isGameOver,
        listener: (context, state) {
          final gameCubit = context.read<GameCubit>();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Game Over'),
                content: Text('Score: ${state.score}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(dialogContext)
                          .push(
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardPage(),
                        ),
                      )
                          .then((_) => gameCubit.restart());
                    },
                    child: const Text('Leaderboard'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      gameCubit.restart();
                    },
                    child: const Text('Play Again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Main Menu'),
                  ),
                ],
              );
            },
          );
        },
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                context.read<GameCubit>().updateAreaSize(
                    Size(constraints.maxWidth, constraints.maxHeight));
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      context.read<GameCubit>().handleTap(details.localPosition),
                  child: Stack(
                    children: [
                      ...state.dots.map(
                        (dot) => Positioned(
                          left: dot.position.dx - dot.radius,
                          top: dot.position.dy - dot.radius,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              final blur = widget.glowEnabled
                                  ? 8 + (_glowController.value * 6)
                                  : 8.0;
                              final spread = widget.glowEnabled
                                  ? 1 + (_glowController.value * 2)
                                  : 1.0;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: dot.radius * 2,
                                height: dot.radius * 2,
                                decoration: BoxDecoration(
                                  color: dot.color,
                                  shape: BoxShape.circle,
                                  boxShadow: dot.color == Colors.red
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: dot.color.withOpacity(0.6),
                                            blurRadius: blur,
                                            spreadRadius: spread,
                                          ),
                                        ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            state.maxLives,
                            (index) => Icon(
                              Icons.favorite,
                              color: index < state.lives
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Text('Score: ${state.score}'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
