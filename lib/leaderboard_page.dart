import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/leaderboard_cubit.dart';

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
        body: BlocBuilder<LeaderboardCubit, List<int>>(
          builder: (context, scores) {
            return scores.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noScoresYet))
                : ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final score = scores[index];
                      return ListTile(
                        leading: Text('#${index + 1}'),
                        title: Text(AppLocalizations.of(context)!.score(score)),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
