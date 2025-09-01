import 'package:flutter/foundation.dart';

/// Types of achievement criteria.
enum AchievementType { score, time }

/// Represents a single achievement.
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final num threshold;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.threshold,
  });
}

/// List of all achievements available in the game.
const List<Achievement> achievements = [
  Achievement(
    id: 'score_50',
    title: 'Score 50',
    description: 'Reach a score of 50 in a single game.',
    type: AchievementType.score,
    threshold: 50,
  ),
  Achievement(
    id: 'survive_3_minutes',
    title: 'Survive 3 minutes',
    description: 'Stay alive for 3 minutes in one game.',
    type: AchievementType.time,
    threshold: 180, // seconds
  ),
];
