import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showSetupUsernamePasswordDialog(BuildContext context) async {
  final supabase = Supabase.instance.client;

  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Complete Account Setup'),
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
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user == null) return;

              await supabase
                  .from('Profile')
                  .update({
                    'username': usernameCtrl.text.trim(),
                    'has_site_password': true,
                  })
                  .eq('profile_id', user.id);

              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
