import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<int> _scores = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('scores') ?? [];
    setState(() {
      _scores = stored.map(int.parse).toList()..sort((b, a) => a.compareTo(b));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _scores.isEmpty
          ? const Center(child: Text('No scores yet'))
          : ListView.builder(
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                final score = _scores[index];
                return ListTile(
                  leading: Text('#'+(index + 1).toString()),
                  title: Text('Score: '+score.toString()),
                );
              },
            ),
    );
  }
}

