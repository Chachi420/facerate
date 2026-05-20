import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool saveHistory;
  final bool darkMode; // false = light (default)

  const SettingsState({
    this.notificationsEnabled = false,
    this.saveHistory = false,
    this.darkMode = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? saveHistory,
    bool? darkMode,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      saveHistory: saveHistory ?? this.saveHistory,
      darkMode: darkMode ?? this.darkMode,
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
      darkMode: prefs.getBool('darkMode') ?? false,
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

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> reload() => _load();
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
