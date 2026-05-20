import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/folio_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cl = Cl.of(context);
    final userAsync = ref.watch(currentUserProfileStreamProvider);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.value;

    final user = userAsync.value;
    final displayName = user?.displayName ?? firebaseUser?.displayName ?? 'User';
    final email = user?.email ?? firebaseUser?.email ?? '';
    final isPro = user?.isPro ?? false;
    final credits = user?.credits ?? 0;

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: const EyebrowText('Profile'),
              right: const EyebrowText('Settings'),
            ),
            Expanded(
              child: RefreshIndicator(
                color: cl.accent,
                backgroundColor: cl.surface,
                onRefresh: () async {
                  ref.invalidate(currentUserProfileStreamProvider);
                  await ref.read(settingsProvider.notifier).reload();
                },
                child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  const SizedBox(height: 20),

                  // User card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cl.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: cl.cardShadow,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: Container(
                            width: 56, height: 56,
                            color: cl.accentDim,
                            child: firebaseUser?.photoURL != null
                                ? Image.network(firebaseUser!.photoURL!, fit: BoxFit.cover)
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 24, fontWeight: FontWeight.w700, color: cl.accent,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 18, fontWeight: FontWeight.w600, color: cl.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(email, style: GoogleFonts.dmSans(fontSize: 13, color: cl.inkMuted)),
                            ],
                          ),
                        ),
                        if (isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cl.legendary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: cl.legendary, width: 0.5),
                            ),
                            child: Text(
                              'PRO',
                              style: GoogleFonts.dmSans(
                                fontSize: 11, letterSpacing: 1.2,
                                fontWeight: FontWeight.w700, color: cl.legendary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _SectionHeader('Account'),
                  const SizedBox(height: 8),
                  _SettingsCard(children: [
                    _SettingsRow(
                      label: 'Credits', value: '$credits',
                      accent: true, onTap: () => context.push('/paywall'),
                    ),
                    _Divider(),
                    _SettingsRow(
                      label: 'Subscription',
                      value: isPro ? 'Pro' : 'Free plan',
                      onTap: () => context.push('/paywall'),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionHeader('Appearance'),
                  const SizedBox(height: 8),
                  _SettingsCard(children: [
                    _ToggleRow(
                      label: 'Dark mode',
                      icon: Icons.dark_mode_rounded,
                      value: settings.darkMode,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionHeader('Preferences'),
                  const SizedBox(height: 8),
                  _SettingsCard(children: [
                    _ToggleRow(
                      label: 'Notifications',
                      icon: Icons.notifications_rounded,
                      value: settings.notificationsEnabled,
                      onChanged: (v) async {
                        if (v) {
                          final notifSettings = await FirebaseMessaging.instance
                              .requestPermission(alert: true, badge: true, sound: true);
                          final granted =
                              notifSettings.authorizationStatus == AuthorizationStatus.authorized ||
                              notifSettings.authorizationStatus == AuthorizationStatus.provisional;
                          if (granted) {
                            await ref.read(settingsProvider.notifier).setNotifications(true);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Permission denied. Enable notifications in device settings.',
                                  style: GoogleFonts.dmSans(fontSize: 13)),
                              backgroundColor: cl.scoreDown,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        } else {
                          await ref.read(settingsProvider.notifier).setNotifications(false);
                        }
                      },
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Save scan history',
                      icon: Icons.history_rounded,
                      value: settings.saveHistory,
                      onChanged: (v) async {
                        ref.read(settingsProvider.notifier).setSaveHistory(v);
                        final authUser = ref.read(authStateProvider).value;
                        if (authUser != null && !authUser.isAnonymous) {
                          await ref.read(firestoreServiceProvider).updateSaveHistory(authUser.uid, v);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionHeader('Legal'),
                  const SizedBox(height: 8),
                  _SettingsCard(children: [
                    _SettingsRow(
                      label: 'Privacy Policy',
                      onTap: () => _showPrivacyPolicy(context),
                    ),
                    _Divider(),
                    _SettingsRow(
                      label: 'CCPA / Data Rights',
                      onTap: () => _showCCPA(context),
                    ),
                    _Divider(),
                    _SettingsRow(
                      label: 'Delete my data',
                      danger: true,
                      onTap: () => _confirmDelete(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/auth');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: cl.scoreDown.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: cl.scoreDown.withValues(alpha: 0.4), width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Sign out',
                        style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w600, color: cl.scoreDown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),  // RefreshIndicator
            FolioNav(
              currentIndex: 3,
              onTap: (i) {
                final routes = ['/', '/history', '/pokedex', '/settings'];
                if (i < routes.length) context.go(routes[i]);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) => _showLegalSheet(
        context,
        title: 'Privacy Policy',
        lastUpdated: 'May 2026',
        sections: [
          _LegalSection('What We Collect', [
            'Account info — email and display name via Google or email sign-in.',
            'Scan images — photos you submit are processed by our AI and are not stored after analysis.',
            'Scan results — your scores, features, and history stored in your account.',
            'Usage data — basic analytics used only to improve the app.',
          ]),
          _LegalSection('How We Use Your Data', [
            'To run face analysis and return results to you.',
            'To maintain your scan history and track progress over time.',
            'To personalise your experience (archetype, glow-up tips, celebrity match).',
            'We never use your data for advertising.',
          ]),
          _LegalSection('Data Sharing', [
            'We do not sell your personal data — ever.',
            'Scan images are processed by our AI provider (Anthropic Claude) and are not retained after the response.',
            'Account and results data is stored on Firebase (Google Cloud), governed by Google\'s data processing terms.',
          ]),
          _LegalSection('Data Retention & Deletion', [
            'Your data is kept as long as your account exists.',
            'You can permanently delete all your data at any time via Settings → Delete my data.',
            'Deletion is immediate and irreversible.',
          ]),
          _LegalSection('Security', [
            'All data is encrypted in transit via HTTPS.',
            'Firebase security rules ensure only you can access your own data.',
          ]),
          _LegalSection('Contact', [
            'For privacy questions or requests: abhinavsinghiitkanpur@gmail.com',
            'We aim to respond within 5 business days.',
          ]),
        ],
      );

  void _showCCPA(BuildContext context) => _showLegalSheet(
        context,
        title: 'CCPA / Data Rights',
        lastUpdated: 'May 2026',
        sections: [
          _LegalSection('Your Rights', [
            'Right to Know — request a copy of the personal data we hold about you.',
            'Right to Delete — delete all your data instantly via Settings → Delete my data.',
            'Right to Opt-Out of Sale — we do not sell personal data, so no opt-out is needed.',
            'Right to Non-Discrimination — exercising any right will never affect your access to the app.',
          ]),
          _LegalSection('Categories of Data We Collect', [
            'Identifiers: name and email address.',
            'Biometric-adjacent data: face images processed transiently (not stored).',
            'Inferences: archetype, feature scores, and glow-up tips derived from your scan.',
            'Usage data: in-app interactions used for product improvement only.',
          ]),
          _LegalSection('How to Exercise Your Rights', [
            'Delete all data: Settings → Delete my data (takes effect immediately).',
            'Data access request: email abhinavsinghiitkanpur@gmail.com with subject "Data Access Request".',
            'We verify and fulfil requests within 45 days as required by law.',
          ]),
          _LegalSection('Contact', [
            'Data controller: Mirror App',
            'Email: abhinavsinghiitkanpur@gmail.com',
          ]),
        ],
      );

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String lastUpdated,
    required List<_LegalSection> sections,
  }) {
    final cl = Cl.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: cl.canvas,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.large)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cl.inkWhisper,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cl.ink,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cl.surfaceH,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: cl.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.5, color: cl.rule),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  children: [
                    Text(
                      'Last updated: $lastUpdated',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: cl.inkMuted),
                    ),
                    const SizedBox(height: 20),
                    ...sections.map((s) => _LegalSectionWidget(
                        section: s)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cl = Cl.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cl.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        title: Text(
          'Delete all data?',
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: cl.ink),
        ),
        content: Text(
          'This will permanently delete your account, all scans, and data. This cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: cl.inkMuted)),
          ),
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
            child: Text('Delete',
              style: GoogleFonts.dmSans(color: cl.scoreDown, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 1.4, color: cl.inkMuted,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: cl.subtleShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: cl.rule,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool accent;
  final bool danger;

  const _SettingsRow({
    required this.label,
    this.value,
    this.onTap,
    this.accent = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final labelColor = danger ? cl.scoreDown : cl.ink;
    final valueColor = accent ? cl.accent : cl.inkMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                style: GoogleFonts.dmSans(fontSize: 15, color: labelColor)),
            ),
            if (value != null) ...[
              Text(value!,
                style: GoogleFonts.dmSans(
                  fontSize: 15, color: valueColor, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
            ],
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 18, color: cl.inkWhisper),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cl.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.dmSans(fontSize: 15, color: cl.ink)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cl.accent,
            activeTrackColor: cl.accentDim,
          ),
        ],
      ),
    );
  }
}

// ── Legal sheet data model ─────────────────────────────────────────────
class _LegalSection {
  final String heading;
  final List<String> bullets;
  const _LegalSection(this.heading, this.bullets);
}

// ── Legal section widget ───────────────────────────────────────────────
class _LegalSectionWidget extends StatelessWidget {
  final _LegalSection section;
  const _LegalSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cl.ink,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          ...section.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cl.inkWhisper,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: cl.inkMuted,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
