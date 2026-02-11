import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // get auth service
  final authService = AuthService();

  bool _obscurePassword = true;
  bool _loading = false;

  // text controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // animation controller
  late AnimationController _controller;

  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // login button pressed
  Future<void> submit() async {
    if (_loading) return;

    setState(() => _loading = true);
    // prepare data
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isSignUp && username.isEmpty)) {
      _showSnack("Please fill all fields");
      return;
    }

    try {
      // attempt sign in
      if (_isSignUp) {
        await authService.signUpWithEmailPassword(email, password, username);
        _showSnack("Check your email to confirm.");
      }
      // attempt sign up
      else {
        await authService.signInWithEmailPassword(email, password);
        _showSnack("Successfully logged in.");
      }
    } catch (e) {
      if(_isSignUp) {
      _showSnack("Error in signing up. \n ${e.toString()}");
      }
      else {
        _showSnack("Error in signing in. \n${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  cos(_controller.value * 2 * pi),
                  sin(_controller.value * 2 * pi),
                ),
                end: Alignment(
                  -cos(_controller.value * 2 * pi),
                  -sin(_controller.value * 2 * pi),
                ),
                colors: const [Color(0xFFE61A4B), Color(0xFFFFEA21)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //logo
                          Image.asset(
                            'lib/assets/images/popcom logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 50),
                          SizedBox(
                            width: 300,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withAlpha(240)
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 25,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      _buildTab("Sign In", !_isSignUp, () {
                                        setState(() {
                                          _isSignUp = false;
                                          _emailController.clear();
                                          _passwordController.clear();
                                        });
                                      }),
                                      _buildTab("Sign Up", _isSignUp, () {
                                        setState(() {
                                          _isSignUp = true;
                                          _emailController.clear();
                                          _passwordController.clear();
                                        });
                                      }),
                                    ],
                                  ),
                                  // email
                                  TextField(
                                    controller: _emailController,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: null,
                                      hintText: "Email",
                                      hintStyle: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54.withAlpha(75),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.black87,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black54,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.yellow.shade700,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // username
                                  if (_isSignUp) ...[
                                    TextField(
                                      controller: _usernameController,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: null,
                                        hintText: "Username",
                                        hintStyle: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black54.withAlpha(75),
                                        ),
                                        labelStyle: TextStyle(
                                          color: Colors.black87,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black54,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.yellow.shade700,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 15),

                                  // password
                                  TextField(
                                    controller: _passwordController,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: null,
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54.withAlpha(75),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.black87,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black54,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.yellow.shade700,
                                          width: 1,
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.black54,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                  ),
                                  const SizedBox(height: 15),

                                  if (!_isSignUp) ...[
                                    Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54.withAlpha(85),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 15),
                                  // login button
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withAlpha(240)
                                            .withOpacity(0.8), // button color
                                        foregroundColor:
                                            Colors.black87, // text color
                                        minimumSize: const Size.fromHeight(
                                          48,
                                        ), // button size
                                        side: const BorderSide(
                                          color: Colors.black87,
                                          width: 1,
                                        ),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                key: ValueKey("loading"),
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.black87,
                                                    ),
                                              )
                                            : Text(
                                                key: const ValueKey("text"),
                                                _isSignUp
                                                    ? "Sign Up"
                                                    : "Sign In",
                                              ),
                                      ),
                                    ),
                                  ),

                                  if (_isSignUp) ...[
                                    const SizedBox(height: 15),
                                    Row(
                                      children: const [
                                        Expanded(child: Divider()),
                                        Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text("or"),
                                        ),
                                        Expanded(child: Divider()),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // insert google sign up function here
                                      },
                                      icon: Image.asset(
                                        'lib/assets/images/google logo.png',
                                        height: 20,
                                      ),
                                      label: const Text("Sign Up with Google"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        minimumSize: const Size.fromHeight(48),
                                        side: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2,
            width: isActive ? 55 : 0,
            color: Colors.black87,
          ),
        ],
      ),
    ),
  );
}
