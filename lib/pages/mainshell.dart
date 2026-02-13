import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'package:popcom/pages/home_page.dart';

enum AppPage { home, statistics, pageSettings, accountSettings }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final AuthService _authService = AuthService();

  String? _accountType;
  bool _loadingAccountType = true;

  AppPage _currentPage = AppPage.home;

  late final Map<AppPage, Widget> _pages = {
    AppPage.home: const HomePage(key: ValueKey('home')),
    // AppPage.statistics: const StatisticsPage(),
  };

  @override
  void initState() {
    super.initState();
    _loadAccountType();
  }

  Future<void> _loadAccountType() async {
    final type = await _authService.getAccountType();

    if (!mounted) return;

    setState(() {
      _accountType = type;
      _loadingAccountType = false;
    });
  }

  void _logout() async {
    await _authService.signOut();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (_loadingAccountType) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      endDrawer: _buildDrawer(),
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
              child: _pages[_currentPage],
            ),
          ),
        ],
      ),
    );
  }

  // ================= AppBar =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 5),
                    child: Image.asset(
                      'lib/assets/images/popcom logo with text.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    child: Builder(
                      builder: (context) => IconButton(
                        onPressed: Scaffold.of(context).openEndDrawer,
                        icon: const Icon(Icons.menu),
                        iconSize: 35,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= Drawer =================

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.red.shade500,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('lib/assets/images/popcom logo.png', height: 90),
            const SizedBox(height: 30),

            _drawerItem(Icons.home, 'Home', AppPage.home),

            if (_accountType == 'ADMIN')
              _drawerItem(Icons.bar_chart, 'Statistics', AppPage.statistics),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white, size: 35),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, AppPage page) {
    final isActive = _currentPage == page;

    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.yellow : Colors.white70,
          size: 35,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.yellow : Colors.white70,
            fontSize: 25,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (page == AppPage.statistics && _accountType != 'ADMIN') {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Access denied')));
            return;
          }

          Navigator.pop(context);
          setState(() => _currentPage = page);
        },
      ),
    );
  }
}

// ================= Animated Background =================

class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
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
        );
      },
    );
  }
}
