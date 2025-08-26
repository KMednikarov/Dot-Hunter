import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardCubit extends Cubit<List<int>> {
  LeaderboardCubit() : super([]) {
    loadScores();
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('scores') ?? [];
    // Sort scores in descending order so higher scores appear first.
    emit(stored.map(int.parse).toList()..sort((a, b) => b.compareTo(a)));
  }
}
