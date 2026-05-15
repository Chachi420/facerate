import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_profile.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
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
          _emailController.text.trim(),
          _passwordController.text,
        );
        await _createUserDoc(cred.user?.uid ?? '', _emailController.text.trim(), '');
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
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
          cred.user?.uid ?? '',
          cred.user?.email ?? '',
          cred.user?.displayName ?? '',
        );
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
        uid: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      ));
    }
  }

  String _friendlyError(String e) {
    if (e.contains('user-not-found') || e.contains('wrong-password')) {
      return 'Incorrect email or password.';
    }
    if (e.contains('email-already-in-use')) return 'This email is already registered.';
    if (e.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (e.contains('invalid-email')) return 'Please enter a valid email address.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'face', style: TextStyle(color: AppColors.textPrimary)),
                    TextSpan(text: 'rate', style: TextStyle(color: AppColors.purple)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('AI Face Analysis', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 48),
              Row(
                children: [
                  _TabButton(label: 'Sign In', active: !_isSignUp, onTap: () => setState(() => _isSignUp = false)),
                  const SizedBox(width: 8),
                  _TabButton(label: 'Sign Up', active: _isSignUp, onTap: () => setState(() => _isSignUp = true)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Email address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loading ? null : _googleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      SizedBox(width: 10),
                      Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _loading ? null : _guestSignIn,
                child: const Text(
                  'Continue as guest',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.purple : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
