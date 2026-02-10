import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // get auth service
  final authService = AuthService();

  //logout button pressed
  void logout() async {
    await authService.signOut();
  }

  final List<Widget> pages = const [

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0), 
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          )),
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'lib/assets/images/popcom logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),

        centerTitle: true,
        actions: [
          // logout button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
}
