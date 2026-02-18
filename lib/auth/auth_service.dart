import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password

  Future<AuthResponse> signInWithUsernamePassword(
    String username,
    String password,
  ) async {
    final email =
        await _supabase.rpc(
              'get_email_by_username',
              params: {'input_username': username},
            )
            as String?;

    if (email == null || email.isEmpty) {
      throw Exception('User not found');
    }

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  bool _oauthInProgress = false;

  Future<void> signInWithGoogle() async {
    if (_oauthInProgress) return;

    _oauthInProgress = true;

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.popcom.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: {'prompt': 'select_account'},
      );
    } finally {
      _oauthInProgress = false;
    }
  }

  //Sign up with email, username, and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String username,
    String lastname,
    String firstname,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'lastname': lastname,
        'firstname': firstname,
      },
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<String?> getAccountType() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('Profile')
        .select('account_type')
        .eq('profile_id', user.id)
        .single();

    return response['account_type'] as String?;
  }
}
