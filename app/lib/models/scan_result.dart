import 'package:cloud_firestore/cloud_firestore.dart';
import 'animal_match.dart';
import 'feature_score.dart';

class ScanResult {
  final String scanId;
  final double score;
  final int percentile;
  final String faceShape;
  final String archetype;
  final String archetypeDescription;
  final Map<String, FeatureScore> features;
  final double goldenRatioScore;
  final String skinTone;
  final List<String> strengths;
  final List<String> areasToImprove;
  final List<String> haircutRecommendations;
  final String beardTips;
  final List<String> skincareRoutine;
  final List<String> glassesFrames;
  final String collarTips;
  final CelebMatch celebrityLookalike;
  final CharacterMatch fictionalCharacter;
  final int perceivedAge;
  final String vibe;
  final AnimalMatch animal;
  final String moodLogged;
  final DateTime createdAt;

  const ScanResult({
    required this.scanId,
    required this.score,
    required this.percentile,
    required this.faceShape,
    required this.archetype,
    required this.archetypeDescription,
    required this.features,
    required this.goldenRatioScore,
    required this.skinTone,
    required this.strengths,
    required this.areasToImprove,
    required this.haircutRecommendations,
    required this.beardTips,
    required this.skincareRoutine,
    required this.glassesFrames,
    required this.collarTips,
    required this.celebrityLookalike,
    required this.fictionalCharacter,
    required this.perceivedAge,
    required this.vibe,
    required this.animal,
    required this.moodLogged,
    required this.createdAt,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final featuresRaw = json['features'] as Map<String, dynamic>? ?? {};
    final features = featuresRaw.map(
      (k, v) => MapEntry(k, FeatureScore.fromJson(v as Map<String, dynamic>)),
    );

    return ScanResult(
      scanId: json['scan_id'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      percentile: json['percentile'] as int? ?? 50,
      faceShape: json['face_shape'] as String? ?? 'oval',
      archetype: json['archetype'] as String? ?? '',
      archetypeDescription: json['archetype_description'] as String? ?? '',
      features: features,
      goldenRatioScore: (json['golden_ratio_score'] as num?)?.toDouble() ?? 7.0,
      skinTone: json['skin_tone'] as String? ?? '',
      strengths: List<String>.from(json['strengths'] as List? ?? []),
      areasToImprove: List<String>.from(json['areas_to_improve'] as List? ?? []),
      haircutRecommendations: List<String>.from(json['haircut_recommendations'] as List? ?? []),
      beardTips: json['beard_tips'] as String? ?? '',
      skincareRoutine: List<String>.from(json['skincare_routine'] as List? ?? []),
      glassesFrames: List<String>.from(json['glasses_frames'] as List? ?? []),
      collarTips: json['collar_tips'] as String? ?? '',
      celebrityLookalike: CelebMatch.fromJson(
          json['celebrity_lookalike'] as Map<String, dynamic>? ?? {}),
      fictionalCharacter: CharacterMatch.fromJson(
          json['fictional_character'] as Map<String, dynamic>? ?? {}),
      perceivedAge: json['perceived_age'] as int? ?? 25,
      vibe: json['vibe'] as String? ?? '',
      animal: AnimalMatch.fromJson(json['animal'] as Map<String, dynamic>? ?? {}),
      moodLogged: json['mood_logged'] as String? ?? 'good',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory ScanResult.fromFirestore(Map<String, dynamic> data) {
    final featuresRaw = data['features'] as Map<String, dynamic>? ?? {};
    final features = featuresRaw.map(
      (k, v) => MapEntry(k, FeatureScore.fromJson(v as Map<String, dynamic>)),
    );

    return ScanResult(
      scanId: data['scanId'] as String? ?? '',
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      percentile: data['percentile'] as int? ?? 50,
      faceShape: data['faceShape'] as String? ?? 'oval',
      archetype: data['archetype'] as String? ?? '',
      archetypeDescription: data['archetypeDescription'] as String? ?? '',
      features: features,
      goldenRatioScore: (data['goldenRatioScore'] as num?)?.toDouble() ?? 7.0,
      skinTone: data['skinTone'] as String? ?? '',
      strengths: List<String>.from(data['strengths'] as List? ?? []),
      areasToImprove: List<String>.from(data['areasToImprove'] as List? ?? []),
      haircutRecommendations: List<String>.from(data['haircutRecommendations'] as List? ?? []),
      beardTips: data['beardTips'] as String? ?? '',
      skincareRoutine: List<String>.from(data['skincareRoutine'] as List? ?? []),
      glassesFrames: List<String>.from(data['glassesFrames'] as List? ?? []),
      collarTips: data['collarTips'] as String? ?? '',
      celebrityLookalike: CelebMatch.fromFirestore(
          data['celebrityLookalike'] as Map<String, dynamic>? ?? {}),
      fictionalCharacter: CharacterMatch.fromFirestore(
          data['fictionalCharacter'] as Map<String, dynamic>? ?? {}),
      perceivedAge: data['perceivedAge'] as int? ?? 25,
      vibe: data['vibe'] as String? ?? '',
      animal: AnimalMatch.fromFirestore(data['animal'] as Map<String, dynamic>? ?? {}),
      moodLogged: data['moodLogged'] as String? ?? 'good',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scan_id': scanId,
        'score': score,
        'percentile': percentile,
        'face_shape': faceShape,
        'archetype': archetype,
        'archetype_description': archetypeDescription,
        'features': features.map((k, v) => MapEntry(k, v.toJson())),
        'golden_ratio_score': goldenRatioScore,
        'skin_tone': skinTone,
        'strengths': strengths,
        'areas_to_improve': areasToImprove,
        'haircut_recommendations': haircutRecommendations,
        'beard_tips': beardTips,
        'skincare_routine': skincareRoutine,
        'glasses_frames': glassesFrames,
        'collar_tips': collarTips,
        'celebrity_lookalike': celebrityLookalike.toJson(),
        'fictional_character': fictionalCharacter.toJson(),
        'perceived_age': perceivedAge,
        'vibe': vibe,
        'animal': animal.toJson(),
        'mood_logged': moodLogged,
        'created_at': createdAt.toIso8601String(),
      };
}
