import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:popcom/pages/login_page.dart';
import 'package:popcom/pages/mainshell.dart';
import 'package:popcom/widgets/setup_username_password_dialog.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  bool _setupDialogOpen = false;
  int _checkNonce = 0; // forces FutureBuilder refresh after dialog closes

  Future<bool> _needsSetup() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final profile = await supabase
          .from('Profile')
          .select('username, has_site_password')
          .eq('profile_id', user.id)
          .maybeSingle();

      final username = (profile?['username'] ?? '').toString().trim();
      final hasPassword = profile?['has_site_password'] == true;

      return username.isEmpty || !hasPassword;
    } catch (e) {
      // 🔥 If RLS blocks select, you’ll see it here instead of “stuck”
      debugPrint('AuthGate _needsSetup ERROR: $e');
      rethrow;
    }
  }

  Future<void> _openSetupDialogOnce() async {
    if (_setupDialogOpen) return;
    _setupDialogOpen = true;

    try {
      await showSetupUsernamePasswordDialog(context);
    } finally {
      _setupDialogOpen = false;
      if (mounted) setState(() => _checkNonce++); // re-check profile after save
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session == null) return const LoginPage();

        return FutureBuilder<bool>(
          // nonce forces re-run after dialog closes
          future: _needsSetup().then((v) => (_checkNonce >= 0 ? v : v)),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snap.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    "Setup check failed:\n${snap.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final needsSetup = snap.data == true;

            if (needsSetup) {
              // ✅ schedule dialog ONCE, not every build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openSetupDialogOnce();
              });

              return const Scaffold(
                body: Center(child: Text("Completing account setup...")),
              );
            }

            return const MainShell();
          },
        );
      },
    );
  }
}
