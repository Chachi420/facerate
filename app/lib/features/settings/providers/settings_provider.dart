import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool saveHistory;

  const SettingsState({
    this.notificationsEnabled = false,
    this.saveHistory = false,
  });

  SettingsState copyWith({bool? notificationsEnabled, bool? saveHistory}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      notificationsEnabled: prefs.getBool('notifications') ?? false,
      saveHistory: prefs.getBool('saveHistory') ?? false,
    );
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setSaveHistory(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveHistory', value);
    state = state.copyWith(saveHistory: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
