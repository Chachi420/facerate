import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMoodProvider = StateProvider<String>((ref) => 'good');
final selectedModeProvider = StateProvider<String>((ref) => 'honest');
