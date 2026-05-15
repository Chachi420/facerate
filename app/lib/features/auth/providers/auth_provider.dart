import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_profile.dart';
import '../../../services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, uid) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getUser(uid);
});

final currentUserProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final firestoreService = ref.read(firestoreServiceProvider);
      return firestoreService.userStream(user.uid).map((p) => p as UserProfile?);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
