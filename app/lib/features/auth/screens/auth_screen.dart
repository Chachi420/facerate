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
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final authService = ref.read(authServiceProvider);
    try {
      if (_isSignUp) {
        final cred = await authService.signUpWithEmail(
          _emailController.text.trim(), _passwordController.text);
        await _createUserDoc(cred.user?.uid ?? '', _emailController.text.trim(), '');
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(), _passwordController.text);
      }
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = _friendlyError(e.toString()); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

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

  Future<void> _guestSignIn() async {
    setState(() { _loading = true; _error = null; });
    final authService = ref.read(authServiceProvider);
    try {
      await authService.signInAnonymously();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = 'Could not sign in as guest. Please try again.'; });
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
        uid: uid, email: email, displayName: displayName, createdAt: DateTime.now()));
    }
  }

  String _friendlyError(String e) {
    if (e.contains('user-not-found') || e.contains('wrong-password'))
      return 'Incorrect email or password.';
    if (e.contains('email-already-in-use')) return 'This email is already registered.';
    if (e.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (e.contains('invalid-email')) return 'Please enter a valid email address.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 48),

              // Sign in / Sign up toggle chips
              Container(
                decoration: BoxDecoration(
                  color: cl.surfaceH,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'Sign in',
                      active: !_isSignUp,
                      cl: cl,
                      onTap: () => setState(() => _isSignUp = false),
                    ),
                    _TabChip(
                      label: 'Create account',
                      active: _isSignUp,
                      cl: cl,
                      onTap: () => setState(() => _isSignUp = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              _Field(
                controller: _emailController,
                hint: 'Email address',
                keyboardType: TextInputType.emailAddress,
                cl: cl,
              ),
              const SizedBox(height: 12),

              // Password field
              _Field(
                controller: _passwordController,
                hint: 'Password',
                obscure: true,
                cl: cl,
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
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
              ],
              const SizedBox(height: 20),

              // Primary CTA button
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _loading ? cl.surfaceH : cl.accent,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: _loading ? null : cl.buttonShadow,
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isSignUp ? 'Create account →' : 'Sign in →',
                          style: GoogleFonts.dmSans(
                            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Google button
              GestureDetector(
                onTap: _loading ? null : _googleSignIn,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: cl.surface,
                    border: Border.all(color: cl.rule, width: 1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: cl.subtleShadow,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/google_g.png', width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text('Continue with Google',
                        style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w500, color: cl.ink,
                        )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 0.5, color: cl.rule)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or',
                      style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted)),
                  ),
                  Expanded(child: Container(height: 0.5, color: cl.rule)),
                ],
              ),
              const SizedBox(height: 20),

              // Guest
              Center(
                child: GestureDetector(
                  onTap: _loading ? null : _guestSignIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: cl.rule, width: 1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Continue as guest',
                      style: GoogleFonts.dmSans(fontSize: 13, color: cl.inkMuted),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab chip (sign in / create account toggle) ─────────────────────────────
class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final Cl cl;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.cl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? cl.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
            boxShadow: active ? cl.subtleShadow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? cl.ink : cl.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Rounded text field ─────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Cl cl;

  const _Field({
    required this.controller,
    required this.hint,
    required this.cl,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(fontSize: 15, color: cl.ink),
      cursorColor: cl.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 15, color: cl.inkWhisper),
        filled: true,
        fillColor: cl.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cl.rule, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cl.rule, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cl.accent, width: 2),
        ),
      ),
    );
  }
}
