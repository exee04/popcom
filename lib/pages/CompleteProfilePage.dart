import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mainshell.dart';

class CompleteProfilePage extends StatefulWidget {
  final VoidCallback onProfileCreated;

  const CompleteProfilePage({super.key, required this.onProfileCreated});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _supabase = Supabase.instance.client;

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _saveProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (username.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      setState(() => _error = "All fields are required.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final existing = await _supabase
          .from('Profile')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        setState(() {
          _loading = false;
          _error = "Username already taken.";
        });
        return;
      }

      await _supabase.from('Profile').insert({
        'profile_id': user.id,
        'email': user.email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'has_site_password': false,
      });
      widget.onProfileCreated();

      // 🔥 IMPORTANT: turn loading off
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      // DO NOT manually navigate
      // AuthGate will rebuild automatically
    } catch (e, stackTrace) {
      print("INSERT PROFILE ERROR: $e");
      print(stackTrace);

      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Almost there 👀",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Please complete your profile to continue."),
            const SizedBox(height: 30),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            ElevatedButton(
              onPressed: _loading ? null : _saveProfile,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
