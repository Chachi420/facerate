import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/scan_result.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

final lastScanProvider = FutureProvider<ScanResult?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null || user.isAnonymous) return null;
      final firestoreService = ref.read(firestoreServiceProvider);
      final scans = await firestoreService.getScanHistory(user.uid, limit: 1);
      return scans.isEmpty ? null : scans.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final scanCountProvider = StateProvider<int>((ref) => 0);
