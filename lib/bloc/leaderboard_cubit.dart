import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardCubit extends Cubit<List<int>> {
  LeaderboardCubit() : super([]) {
    loadScores();
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('scores') ?? [];
    emit(stored.map(int.parse).toList()..sort((b, a) => a.compareTo(b)));
  }
}
