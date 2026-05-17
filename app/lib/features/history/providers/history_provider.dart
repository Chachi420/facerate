import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/scan_result.dart';
import '../../auth/providers/auth_provider.dart';

final scanHistoryProvider = StreamProvider<List<ScanResult>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null || user.isAnonymous) return Stream.value([]);
      final firestoreService = ref.read(firestoreServiceProvider);
      return firestoreService.scanHistoryStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
