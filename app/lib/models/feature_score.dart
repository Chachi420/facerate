class FeatureScore {
  final double score;
  final String description;

  const FeatureScore({required this.score, required this.description});

  factory FeatureScore.fromJson(Map<String, dynamic> json) {
    return FeatureScore(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'description': description,
      };
}
