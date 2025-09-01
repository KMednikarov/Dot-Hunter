import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'bloc/leaderboard_cubit.dart';

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
        body: BlocBuilder<LeaderboardCubit, List<int>>(
          builder: (context, scores) {
            return scores.isEmpty
                ? const Center(child: Text('No scores yet'))
                : ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final score = scores[index];
                      return ListTile(
                        leading: Text('#${index + 1}'),
                        title: Text('Score: $score'),
                        trailing: IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            const storeLink =
                                'https://play.google.com/store/apps/details?id=com.example.dot_hunter';
                            Share.share(
                              'I scored $score in Dot Hunter! Try it: $storeLink',
                            );
                          },
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
