import 'package:flutter/material.dart';
import 'package:popcom/pages/CompleteProfilePage.dart';
import 'package:popcom/pages/mainshell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _ProfileGate extends StatefulWidget {
  final String userId;
  const _ProfileGate({required this.userId});

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  final _supabase = Supabase.instance.client;

  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    return await _supabase
        .from('Profile')
        .select()
        .eq('profile_id', widget.userId)
        .maybeSingle();
  }

  void refresh() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return CompleteProfilePage(onProfileCreated: refresh);
        }

        return const MainShell();
      },
    );
  }
}
