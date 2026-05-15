import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileStreamProvider);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.value;

    final user = userAsync.value;
    final displayName = user?.displayName ?? firebaseUser?.displayName ?? 'User';
    final email = user?.email ?? firebaseUser?.email ?? '';
    final isPro = user?.isPro ?? false;
    final credits = user?.credits ?? 0;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.purple,
                  backgroundImage: firebaseUser?.photoURL != null ? NetworkImage(firebaseUser!.photoURL!) : null,
                  child: firebaseUser?.photoURL == null ? Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.legendary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.legendary, width: 0.5),
                    ),
                    child: const Text('PRO', style: TextStyle(color: AppColors.legendary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Account section
          _SectionHeader('Account'),
          _SettingsRow(
            icon: Icons.star_outline,
            label: 'Subscription',
            value: isPro ? 'Pro' : 'Free',
            onTap: () => context.push('/paywall'),
          ),
          _SettingsRow(
            icon: Icons.bolt_outlined,
            label: 'Credits',
            value: '$credits credits',
            onTap: () => context.push('/paywall'),
          ),
          const SizedBox(height: 20),
          // Preferences
          _SectionHeader('Preferences'),
          _ToggleRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: settings.notificationsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
          ),
          _ToggleRow(
            icon: Icons.history,
            label: 'Save scan history',
            value: settings.saveHistory,
            onChanged: (v) async {
              ref.read(settingsProvider.notifier).setSaveHistory(v);
              final authUser = ref.read(authStateProvider).value;
              if (authUser != null && !authUser.isAnonymous) {
                await ref.read(firestoreServiceProvider).updateSaveHistory(authUser.uid, v);
              }
            },
          ),
          const SizedBox(height: 20),
          // Privacy
          _SectionHeader('Privacy'),
          _SettingsRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
          _SettingsRow(icon: Icons.gavel_outlined, label: 'CCPA / Data Rights', onTap: () {}),
          _SettingsRow(
            icon: Icons.delete_outline,
            label: 'Delete my data',
            labelColor: AppColors.red,
            onTap: () => _confirmDelete(context, ref),
          ),
          const SizedBox(height: 20),
          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/auth');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red, width: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete all data?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This will permanently delete your account, all scans, and data. This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authUser = ref.read(authStateProvider).value;
              if (authUser != null) {
                await ref.read(firestoreServiceProvider).deleteAllUserData(authUser.uid);
                await ref.read(authServiceProvider).deleteAccount();
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/auth');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color? labelColor;

  const _SettingsRow({required this.icon, required this.label, this.value, required this.onTap, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: labelColor ?? AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: labelColor ?? AppColors.textPrimary, fontSize: 14))),
            if (value != null) Text(value!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purple,
            inactiveTrackColor: AppColors.surface2,
          ),
        ],
      ),
    );
  }
}
