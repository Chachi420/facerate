import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

Future<void> markOnboardingComplete(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingComplete', true);
  ref.read(onboardingCompleteProvider.notifier).state = true;
}
