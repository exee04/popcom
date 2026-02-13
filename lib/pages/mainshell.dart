import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'package:popcom/pages/home_page.dart';
import 'dart:ui';

enum AppPage { home, statistics, pageSettings, accountSettings }

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

  AppPage currentPage = AppPage.home;
  final Map<AppPage, Widget> pages = {
    AppPage.home: const HomePage(key: ValueKey('home')),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyActions: false,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.55),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsGeometry.only(
                          left: 10,
                          bottom: 5,
                        ),
                        child: SizedBox(
                          height: 100,
                          child: Image.asset(
                            'lib/assets/images/popcom logo with text.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: (kToolbarHeight - 45) / 2,
                        bottom: (kToolbarHeight - 35) / 2,
                        // menu button
                        child: Builder(
                          builder: (context) => _actionButton(
                            onTap: Scaffold.of(context).openEndDrawer,
                            icon: Icons.menu,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ), 
      // side menu drawer
      endDrawer: Drawer(
        child: Container(
          color: Colors.red.shade500,
          child: Column(
            children: [
              Image.asset(
                'lib/assets/images/popcom logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              _drawerItem(Icons.home, "Home", AppPage.home),
              const Spacer(), // logout button
              Padding(
                padding: EdgeInsetsGeometry.only(left: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 35,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    logout();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            top: false,
            child: AnimatedSwitcher(
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
              child: pages[currentPage],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, AppPage page) {
    final isActive = currentPage == page;
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 15),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.yellow : Colors.white70,
          size: 35,
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 25,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() => currentPage = page);
        },
      ),
    );
  }
}

class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});
  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFFE61A4B), Color(0xFFFFEA21)],
        ),
      ),
    );
  }
}

// reusable button template
Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 45),
        width: rs(context, 45),
        decoration: BoxDecoration(
          color: const Color(0xFFFDC62D).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.black87, size: 22),
          onPressed: onTap,
        ),
      );
    },
  );
}
