import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final bool isPro;
  final int credits;
  final int totalScans;
  final int streak;
  final DateTime? lastScanDate;
  final DateTime createdAt;
  final bool saveHistory;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isPro = false,
    this.credits = 0,
    this.totalScans = 0,
    this.streak = 0,
    this.lastScanDate,
    required this.createdAt,
    this.saveHistory = false,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      isPro: data['isPro'] as bool? ?? false,
      credits: data['credits'] as int? ?? 0,
      totalScans: data['totalScans'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      lastScanDate: (data['lastScanDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      saveHistory: data['saveHistory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'isPro': isPro,
        'credits': credits,
        'totalScans': totalScans,
        'streak': streak,
        'lastScanDate': lastScanDate != null ? Timestamp.fromDate(lastScanDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'saveHistory': saveHistory,
      };

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isPro,
    int? credits,
    int? totalScans,
    int? streak,
    DateTime? lastScanDate,
    DateTime? createdAt,
    bool? saveHistory,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isPro: isPro ?? this.isPro,
      credits: credits ?? this.credits,
      totalScans: totalScans ?? this.totalScans,
      streak: streak ?? this.streak,
      lastScanDate: lastScanDate ?? this.lastScanDate,
      createdAt: createdAt ?? this.createdAt,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }
}
