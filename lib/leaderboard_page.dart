import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/leaderboard_cubit.dart';
import 'models/score_entry.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaderboardCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
        ),
        body: BlocBuilder<LeaderboardCubit, List<ScoreEntry>>(
          builder: (context, scores) {
            return scores.isEmpty
                ? const Center(child: Text('No scores yet'))
                : ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final entry = scores[index];
                      return ListTile(
                        leading: Text('#${index + 1}'),
                        title: Text('Score: ${entry.score}'),
                        subtitle: Text('Player: ${entry.playerId}'),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
