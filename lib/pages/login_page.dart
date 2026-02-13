import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'dart:math';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

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
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
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
    // prepare data
    final lastname = _lastNameController.text.trim();
    final firstname = _firstNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isSignUp && username.isEmpty)) {
      _showSnack("Please fill all fields");
      return;
    }
    setState(() => _loading = true);

    try {
      // attempt sign up
      if (_isSignUp) {
        await authService.signUpWithEmailPassword(
          email,
          password,
          username,
          lastname,
          firstname,
        );
        _showSnack("Check your email to confirm.");
      }
      // attempt sign in
      else {
        await authService.signInWithEmailPassword(email, password);
        _showSnack("Successfully logged in.");
      }
    } catch (e) {
      if (_isSignUp) {
        _showSnack("Error in signing up. \n ${e.toString()}");
      } else {
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
                final screenHeight = constraints.maxHeight;
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

                return Center(
                  child: SingleChildScrollView(
                    physics: screenHeight > 700
                        ? const NeverScrollableScrollPhysics() // 🔥 disable scroll on large screens
                        : const BouncingScrollPhysics(), // enable scroll on small screens
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //logo
                            Image.asset(
                              'lib/assets/images/popcom logo.png',
                              height: MediaQuery.of(context).size.height * 0.12,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            SizedBox(
                              width: min(
                                MediaQuery.of(context).size.width * 0.85,
                                420,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.06,
                                ),
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
                                        _buildTab(
                                          context,
                                          "Log In",
                                          !_isSignUp,
                                          () {
                                            setState(() {
                                              _isSignUp = false;
                                              _emailController.clear();
                                              _passwordController.clear();
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: min(
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                            420,
                                          ),
                                        ),
                                        _buildTab(
                                          context,
                                          "Sign Up",
                                          _isSignUp,
                                          () {
                                            setState(() {
                                              _isSignUp = true;
                                              _emailController.clear();
                                              _passwordController.clear();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.03,
                                    ),
                                    // last name
                                    if (_isSignUp) ...[
                                      SizedBox(
                                        height: rs(context, 35),
                                        child: TextField(
                                          textAlign: TextAlign.left,
                                          controller: _lastNameController,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: rs(context, 15),
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: rs(context, 5),
                                                  horizontal: rs(context, 15),
                                                ),
                                            labelText: null,
                                            hintText: "Last Name",
                                            hintStyle: TextStyle(
                                              fontSize: rs(context, 15),
                                              color: Colors.black54.withAlpha(
                                                70,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white70
                                                .withOpacity(0.65),
                                            alignLabelWithHint: true,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.black54,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.yellow.shade700,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                    ],

                                    // first name
                                    if (_isSignUp) ...[
                                      SizedBox(
                                        height: rs(context, 35),
                                        child: TextField(
                                          controller: _firstNameController,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: rs(context, 15),
                                          ),
                                          decoration: InputDecoration(
                                            labelText: null,
                                            hintText: "First Name",
                                            hintStyle: TextStyle(
                                              fontSize: rs(context, 15),
                                              color: Colors.black54.withAlpha(
                                                70,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white70
                                                .withOpacity(0.65),
                                            alignLabelWithHint: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: rs(context, 5),
                                                  horizontal: rs(context, 15),
                                                ),
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.black54,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.yellow.shade700,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                    ],

                                    // email
                                    SizedBox(
                                      height: rs(context, 35),
                                      child: TextField(
                                        controller: _emailController,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: rs(context, 15),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: null,
                                          hintText: "Email",
                                          hintStyle: TextStyle(
                                            fontSize: rs(context, 15),
                                            color: Colors.black54.withAlpha(70),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white70.withOpacity(
                                            0.65,
                                          ),
                                          alignLabelWithHint: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: rs(context, 5),
                                            horizontal: rs(context, 15),
                                          ),
                                          labelStyle: TextStyle(
                                            color: Colors.black87,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.yellow.shade700,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.02,
                                    ),

                                    // username
                                    if (_isSignUp) ...[
                                      SizedBox(
                                        height: rs(context, 35),
                                        child: TextField(
                                          controller: _usernameController,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: rs(context, 15),
                                          ),
                                          decoration: InputDecoration(
                                            labelText: null,
                                            hintText: "Username",
                                            hintStyle: TextStyle(
                                              fontSize: rs(context, 15),
                                              color: Colors.black54.withAlpha(
                                                70,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white70
                                                .withOpacity(0.65),
                                            alignLabelWithHint: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: rs(context, 5),
                                                  horizontal: rs(context, 15),
                                                ),
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.black54,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.yellow.shade700,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                    ],

                                    // password
                                    SizedBox(
                                      height: rs(context, 35),
                                      child: TextField(
                                        controller: _passwordController,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: rs(context, 15),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: null,
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                            fontSize: rs(context, 15),
                                            color: Colors.black54.withAlpha(70),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white70.withOpacity(
                                            0.65,
                                          ),
                                          alignLabelWithHint: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: rs(context, 5),
                                            horizontal: rs(context, 15),
                                          ),
                                          labelStyle: TextStyle(
                                            color: Colors.black87,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.yellow.shade700,
                                              width: 2,
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
                                                size: 15,
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
                                    ),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.03,
                                    ),

                                    // login button
                                    SizedBox(
                                      height: rs(context, 50),
                                      width: min(
                                        MediaQuery.of(context).size.width * 0.4,
                                        250,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            height: rs(context, 50),
                                            child: OutlinedButton(
                                              onPressed: _loading
                                                  ? null
                                                  : submit,
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFE61A4B)
                                                        .withAlpha(240)
                                                        .withOpacity(
                                                          0.8,
                                                        ), // button color
                                                foregroundColor: Colors
                                                    .yellow
                                                    .shade500, // text color
                                                side: const BorderSide(
                                                  color: Colors.black87,
                                                  width: 1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                shadowColor: Colors.black,
                                                elevation: 5,
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                child: _loading
                                                    ? SizedBox(
                                                        key: ValueKey(
                                                          "loading",
                                                        ),
                                                        height: rs(context, 22),
                                                        width: rs(context, 22),
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .yellow
                                                                  .shade500,
                                                            ),
                                                      )
                                                    : Text(
                                                        key: const ValueKey(
                                                          "text",
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: rs(
                                                            context,
                                                            16,
                                                          ),
                                                        ),
                                                        _isSignUp
                                                            ? "Sign Up"
                                                            : "Log In",
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 1,
                                            right: 1,
                                            height: rs(context, 6),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (!_isSignUp) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                      Text(
                                        "Forgot password?",
                                        style: TextStyle(
                                          fontSize: rs(context, 14),
                                          color: Colors.black54.withAlpha(95),
                                        ),
                                      ),
                                    ],

                                    if (!_isSignUp) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.03,
                                            ),
                                            child: Text(
                                              "or",
                                              style: TextStyle(
                                                fontSize: rs(context, 14),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),

                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // insert google sign up function here
                                        },
                                        icon: Image.asset(
                                          'lib/assets/images/google logo.png',
                                          height: rs(context, 20),
                                        ),
                                        label: Text(
                                          "Sign In via Google",
                                          style: TextStyle(
                                            color: Colors.black87.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: rs(context, 14),
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size.fromHeight(
                                            48,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (_isSignUp) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: Divider()),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.03,
                                            ),
                                            child: Text(
                                              "or",
                                              style: TextStyle(
                                                fontSize: rs(context, 14),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Divider()),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),

                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // insert google sign up function here
                                        },
                                        icon: Image.asset(
                                          'lib/assets/images/google logo.png',
                                          height: rs(context, 20),
                                        ),
                                        label: Text(
                                          "Sign Up via Google",
                                          style: TextStyle(
                                            color: Colors.black87.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: rs(context, 14),
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size.fromHeight(
                                            48,
                                          ),
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

Widget _buildTab(
  BuildContext context,
  String text,
  bool isActive,
  VoidCallback onTap,
) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: rs(context, 40),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE61A4B).withAlpha(240).withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: isActive
                    ? Colors.yellow.shade500
                    : Colors.black87.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: rs(context, 15),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 1,
            right: 2,
            height: rs(context, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
