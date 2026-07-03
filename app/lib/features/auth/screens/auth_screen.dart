import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../../../widgets/eyebrow_text.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    final authService = ref.read(authServiceProvider);
    try {
      final cred = await authService.signInWithGoogle();
      if (cred != null) {
        await _createUserDoc(
          cred.user?.uid ?? '', cred.user?.email ?? '', cred.user?.displayName ?? '');
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() { _error = 'Google sign-in failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _createUserDoc(String uid, String email, String displayName) async {
    if (uid.isEmpty) return;
    final firestore = ref.read(firestoreServiceProvider);
    final existing = await firestore.getUser(uid);
    if (existing == null) {
      await firestore.createUser(UserProfile(
        uid: uid, email: email, displayName: displayName,
        credits: 5, createdAt: DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              // Wordmark
              Text(
                'mirror.',
                style: GoogleFonts.dmSans(
                  fontSize: 38,
                  color: cl.ink,
                  letterSpacing: -0.02 * 38,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              EyebrowText.muted('Face intelligence'),

              const Spacer(),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cl.scoreDown.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: cl.scoreDown.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Text(
                    _error!,
                    style: GoogleFonts.dmSans(fontSize: 13, color: cl.scoreDown),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Google button — the only way in
              GestureDetector(
                onTap: _loading ? null : _googleSignIn,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: cl.surface,
                    border: Border.all(color: cl.rule, width: 1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: cl.subtleShadow,
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(color: cl.ink, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/google_g.png', width: 20, height: 20),
                            const SizedBox(width: 10),
                            Text('Continue with Google',
                              style: GoogleFonts.dmSans(
                                fontSize: 15, fontWeight: FontWeight.w600, color: cl.ink,
                              )),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Sign in with your Google account to continue',
                  style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
