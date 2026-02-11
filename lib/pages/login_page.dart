import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool _obscurePassword = true;

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // get auth service
  final authService = AuthService();

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
    _controller.dispose();
    super.dispose();
  }

  // login button pressed
  void submit() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    // attempt login..
    try {
      if (_isSignUp) {
        await authService.signUpWithEmailPassword(email, password );
      } else {
        await authService.signInWithEmailPassword(email, password);
      }
    }
    // catch any errors
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
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
                                      // sign in
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isSignUp = false;
                                              _emailController.clear();
                                              _passwordController.clear();
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Sign In",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: !_isSignUp
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: !_isSignUp
                                                      ? Colors.black87
                                                      : Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                height: 2,
                                                width: !_isSignUp ? 55 : 0,
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // register
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isSignUp = true;
                                              _emailController.clear();
                                              _passwordController.clear();
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Sign Up",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: _isSignUp
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: _isSignUp
                                                      ? Colors.black87
                                                      : Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                height: 2,
                                                width: _isSignUp ? 55 : 0,
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ),
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

                                  if (!_isSignUp)
                                    ...[
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
                                      onPressed: submit,
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
                                      child: Text(
                                        _isSignUp ? "Sign Up" : "Login",
                                      ),
                                    ),
                                  ),

                                  if (_isSignUp) ...[
                                    const SizedBox(height: 15),
                                    Row(
                                      children: const [
                                        Expanded(child: Divider()),
                                        Padding(
                                          padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
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
                                      icon: Image.asset('lib/assets/images/google logo.png', height: 20,),
                                      label: const Text("Sign Up with Google"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        minimumSize: const Size.fromHeight(48),
                                        side: const BorderSide(color: Colors.transparent),
                                      ),
                                    )
                                  ]
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
