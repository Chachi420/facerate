import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/scan_result.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  DocumentReference _userRef(String uid) => _db.collection('users').doc(uid);

  Stream<UserProfile> userStream(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists) {
        return UserProfile(
          uid: uid,
          email: '',
          displayName: '',
          createdAt: DateTime.now(),
        );
      }
      return UserProfile.fromFirestore(snap.data() as Map<String, dynamic>);
    });
  }

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _userRef(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  Future<void> createUser(UserProfile profile) async {
    await _userRef(profile.uid).set(profile.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _userRef(uid).update(data);
  }

  Future<void> updateSaveHistory(String uid, bool value) async {
    await _userRef(uid).update({'saveHistory': value});
  }

  Future<List<ScanResult>> getScanHistory(String uid, {int limit = 20}) async {
    final snapshot = await _userRef(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return ScanResult.fromFirestore(doc.data());
    }).toList();
  }

  Stream<List<ScanResult>> scanHistoryStream(String uid, {int limit = 20}) {
    return _userRef(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ScanResult.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> saveScan(String uid, ScanResult result) async {
    final data = {
      'scanId': result.scanId,
      'score': result.score,
      'percentile': result.percentile,
      'faceShape': result.faceShape,
      'archetype': result.archetype,
      'archetypeDescription': result.archetypeDescription,
      'features': result.features.map((k, v) => MapEntry(k, v.toJson())),
      'goldenRatioScore': result.goldenRatioScore,
      'skinTone': result.skinTone,
      'strengths': result.strengths,
      'areasToImprove': result.areasToImprove,
      'haircutRecommendations': result.haircutRecommendations,
      'beardTips': result.beardTips,
      'skincareRoutine': result.skincareRoutine,
      'glassesFrames': result.glassesFrames,
      'collarTips': result.collarTips,
      'celebrityLookalike': result.celebrityLookalike.toJson(),
      'fictionalCharacter': result.fictionalCharacter.toJson(),
      'perceivedAge': result.perceivedAge,
      'vibe': result.vibe,
      'animal': result.animal.toJson(),
      'moodLogged': result.moodLogged,
      'createdAt': Timestamp.fromDate(result.createdAt),
    };

    await _userRef(uid).collection('scans').doc(result.scanId).set(data);
  }

  Future<void> deleteAllUserData(String uid) async {
    final scans = await _userRef(uid).collection('scans').get();
    final batch = _db.batch();
    for (final doc in scans.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_userRef(uid));
    await batch.commit();
  }
}
