import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:popcom/pages/mainshell.dart';
import 'package:popcom/widgets/setup_username_password_dialog.dart';

class SetupDialogHost extends StatefulWidget {
  const SetupDialogHost({super.key});

  @override
  State<SetupDialogHost> createState() => _SetupDialogHostState();
}

class _SetupDialogHostState extends State<SetupDialogHost> {
  final supabase = Supabase.instance.client;
  bool _shown = false;

  Future<bool> _needsSetup() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final profile = await supabase
        .from('Profile')
        .select('username, has_site_password')
        .eq('profile_id', user.id)
        .maybeSingle();

    final username = (profile?['username'] ?? '').toString().trim();
    final hasPassword = profile?['has_site_password'] == true;

    return username.isEmpty || !hasPassword;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_shown) return;
      _shown = true;

      final needs = await _needsSetup();
      if (!needs) {
        _goHome();
        return;
      }

      await showSetupUsernamePasswordDialog(context);

      final stillNeeds = await _needsSetup();
      if (!stillNeeds) {
        _goHome();
      } else {
        _shown = false; // force dialog again if user cancels
      }
    });
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
