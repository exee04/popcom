import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showSetupUsernamePasswordDialog(BuildContext context) async {
  final supabase = Supabase.instance.client;

  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    loading = true;

    // ✅ Save to your Profile table (most reliable)
    await supabase
        .from('Profile')
        .update({'username': username, 'has_site_password': true})
        .eq('profile_id', user.id);

    // OPTIONAL: if you *actually* want to create an email/password login
    // for a Google user, Supabase does NOT let you "set password" directly
    // on an OAuth account client-side. You need a server-side flow for that.
    // So for now, treat "site password" as an app-level password only.

    if (context.mounted) Navigator.of(context).pop();
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Complete your account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Site Password'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () async => await save(),
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
