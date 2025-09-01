import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievements.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completed = prefs.getStringList('achievements')?.toSet() ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        children: achievements.map((a) {
          final done = _completed.contains(a.id);
          return ListTile(
            title: Text(a.title),
            subtitle: Text(a.description),
            trailing: Icon(done ? Icons.check : Icons.close,
                color: done ? Colors.green : Colors.red),
          );
        }).toList(),
      ),
    );
  }
}
