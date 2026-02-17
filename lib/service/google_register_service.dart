import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> showSetupUsernamePasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _SetupUsernamePasswordDialog(),
  );
}

class _SetupUsernamePasswordDialog extends StatefulWidget {
  const _SetupUsernamePasswordDialog();

  @override
  State<_SetupUsernamePasswordDialog> createState() =>
      _SetupUsernamePasswordDialogState();
}

class _SetupUsernamePasswordDialogState
    extends State<_SetupUsernamePasswordDialog> {
  final usernameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool isLoading = false;
  bool obscure1 = true;
  bool obscure2 = true;
  String? errorText;

  String normalizeUsername(String s) => s.trim().toLowerCase();

  bool isValidUsername(String u) {
    if (u.length < 3 || u.length > 20) return false;
    return RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(u);
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isLoading) return;

    final username = normalizeUsername(usernameCtrl.text);
    final pass = passCtrl.text;
    final pass2 = pass2Ctrl.text;

    if (!isValidUsername(username)) {
      setState(
        () => errorText =
            'Username must be 3–20 chars and only letters, numbers, dot, underscore, hyphen.',
      );
      return;
    }
    if (pass.length < 8) {
      setState(() => errorText = 'Password must be at least 8 characters.');
      return;
    }
    if (pass != pass2) {
      setState(() => errorText = 'Passwords do not match.');
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => errorText = 'Not logged in.');
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      // ✅ Metadata-only username (since you said Profile.username doesn't exist)
      await supabase.auth.updateUser(
        UserAttributes(password: pass, data: {'username': username}),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => errorText = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => errorText = 'Something went wrong: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete setup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a username and a site password.'),
            const SizedBox(height: 12),

            TextField(
              controller: usernameCtrl,
              enabled: !isLoading,
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (_) {
                if (errorText != null) setState(() => errorText = null);
              },
            ),
            const SizedBox(height: 8),

            TextField(
              controller: passCtrl,
              enabled: !isLoading,
              obscureText: obscure1,
              decoration: InputDecoration(
                labelText: 'Site password',
                suffixIcon: IconButton(
                  onPressed: isLoading
                      ? null
                      : () => setState(() => obscure1 = !obscure1),
                  icon: Icon(
                    obscure1 ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: pass2Ctrl,
              enabled: !isLoading,
              obscureText: obscure2,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  onPressed: isLoading
                      ? null
                      : () => setState(() => obscure2 = !obscure2),
                  icon: Icon(
                    obscure2 ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),

            if (errorText != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : submit,
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
