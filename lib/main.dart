import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/game_cubit.dart';
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

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Hunter'),
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
                  onTapUp: (details) =>
                      context.read<GameCubit>().handleTap(details.localPosition),
                  child: Stack(
                    children: [
                      ...state.dots.map(
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
