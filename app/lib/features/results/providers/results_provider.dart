import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/scan_result.dart';

final currentScanProvider = StateProvider<ScanResult?>((ref) => null);
final openSectionProvider = StateProvider<int?>((ref) => null);
