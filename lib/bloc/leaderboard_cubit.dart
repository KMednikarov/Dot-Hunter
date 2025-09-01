import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../models/score_entry.dart';
import '../services/auth_service.dart';

/// Cubit responsible for loading leaderboard scores from a backend service.
class LeaderboardCubit extends Cubit<List<ScoreEntry>> {
  LeaderboardCubit() : super(const []) {
    loadScores();
  }

  /// Fetches the latest scores from the backend service. The current player is
  /// anonymously authenticated to ensure their scores can be associated with a
  /// unique identifier.
  Future<void> loadScores() async {
    try {
      // Ensure we have a player id before contacting the backend.
      await AuthService.instance.getPlayerId();

      final response =
          await http.get(Uri.parse('https://example.com/scores'));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>;
        final scores = data
            .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
        emit(scores);
      } else {
        emit(const []);
      }
    } catch (_) {
      emit(const []);
    }
  }
}
