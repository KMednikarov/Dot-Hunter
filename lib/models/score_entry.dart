class ScoreEntry {
  final String playerId;
  final int score;

  ScoreEntry({required this.playerId, required this.score});

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      playerId: json['player'] as String,
      score: (json['score'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'player': playerId,
        'score': score,
      };
}
