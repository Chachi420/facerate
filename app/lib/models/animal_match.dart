class AnimalMatch {
  final String name;
  final String emoji;
  final String rarity;
  final String reason;
  final String vibeDescription;

  const AnimalMatch({
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.reason,
    required this.vibeDescription,
  });

  factory AnimalMatch.fromJson(Map<String, dynamic> json) {
    return AnimalMatch(
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🐾',
      rarity: json['rarity'] as String? ?? 'Common',
      reason: json['reason'] as String? ?? '',
      vibeDescription: json['vibe_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'rarity': rarity,
        'reason': reason,
        'vibe_description': vibeDescription,
      };

  factory AnimalMatch.fromFirestore(Map<String, dynamic> data) {
    return AnimalMatch(
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🐾',
      rarity: data['rarity'] as String? ?? 'Common',
      reason: data['reason'] as String? ?? '',
      vibeDescription: data['vibeDescription'] as String? ?? '',
    );
  }

  bool get isFree =>
      rarity == 'Common' || rarity == 'Uncommon' || rarity == 'Rare';
}

class CelebMatch {
  final String name;
  final int matchPercentage;
  final String reason;

  const CelebMatch({
    required this.name,
    required this.matchPercentage,
    required this.reason,
  });

  factory CelebMatch.fromJson(Map<String, dynamic> json) {
    return CelebMatch(
      name: json['name'] as String? ?? '',
      matchPercentage: json['match_percentage'] as int? ?? 70,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'match_percentage': matchPercentage,
        'reason': reason,
      };

  factory CelebMatch.fromFirestore(Map<String, dynamic> data) {
    return CelebMatch(
      name: data['name'] as String? ?? '',
      matchPercentage: data['matchPercentage'] as int? ?? 70,
      reason: data['reason'] as String? ?? '',
    );
  }
}

class CharacterMatch {
  final String name;
  final String franchise;
  final int matchPercentage;
  final String reason;

  const CharacterMatch({
    required this.name,
    required this.franchise,
    required this.matchPercentage,
    required this.reason,
  });

  factory CharacterMatch.fromJson(Map<String, dynamic> json) {
    return CharacterMatch(
      name: json['name'] as String? ?? '',
      franchise: json['franchise'] as String? ?? '',
      matchPercentage: json['match_percentage'] as int? ?? 70,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'franchise': franchise,
        'match_percentage': matchPercentage,
        'reason': reason,
      };

  factory CharacterMatch.fromFirestore(Map<String, dynamic> data) {
    return CharacterMatch(
      name: data['name'] as String? ?? '',
      franchise: data['franchise'] as String? ?? '',
      matchPercentage: data['matchPercentage'] as int? ?? 70,
      reason: data['reason'] as String? ?? '',
    );
  }
}
