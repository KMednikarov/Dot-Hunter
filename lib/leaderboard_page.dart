import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          title: Text(AppLocalizations.of(context)!.leaderboard),
        ),
        body: BlocBuilder<LeaderboardCubit, List<ScoreEntry>>(
          builder: (context, scores) {
            return scores.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noScoresYet))
                : ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final entry = scores[index];
                      return ListTile(
                        leading: Text('#${index + 1}'),
                        title: Text(AppLocalizations.of(context)!.score(score)),
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
