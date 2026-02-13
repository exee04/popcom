import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';
import 'package:popcom/pages/account_settings_page.dart';
import 'package:popcom/pages/account_status_page.dart';
import 'package:popcom/pages/home_page.dart';
import 'package:popcom/pages/page_settings_page.dart';
import 'dart:ui';
import 'package:popcom/pages/statistics_page.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

enum AppPage { home, statistics, accountStatus, pageSettings, accountSettings }

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

  Widget _headerForCurrentPage(BuildContext context) {
    switch (currentPage) {
      case AppPage.home:
        return Center(
          child: Image.asset(
            'lib/assets/images/popcom logo with text.png',
            height: rs(context, 80),
            width: rs(context, 190),
            fit: BoxFit.contain,
          ),
        );
      case AppPage.statistics:
        return Center(
          child: Text(
            "Statistics",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: rs(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case AppPage.accountStatus:
        return Center(
          child: Text(
            "Account Status",
            style: TextStyle(
              color: Colors.black87,
              fontSize: rs(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case AppPage.accountSettings:
        return Center(
          child: Text(
            "Account Settings",
            style: TextStyle(
              color: Colors.black87,
              fontSize: rs(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case AppPage.pageSettings:
        return Center(
          child: Text(
            "Page Settings",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: rs(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  AppPage currentPage = AppPage.home;
  final Map<AppPage, Widget> pages = {
    AppPage.home: const HomePage(key: ValueKey('home')),
    AppPage.statistics: const StatisticsPage(key: ValueKey('statistics')),
    AppPage.accountStatus: const AccountStatusPage(
      key: ValueKey('accountStatus'),
    ),
    AppPage.pageSettings: const PageSettingsPage(key: ValueKey('pageSettings')),
    AppPage.accountSettings: const AccountSettingsPage(
      key: ValueKey('accountSettings'),
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: rs(context, 70),
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
                  height: rs(context, kToolbarHeight),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(
                          left: rs(context, 10),
                          bottom: rs(context, 5),
                        ),
                        child: SizedBox(
                          height: rs(context, 100),
                          child: _headerForCurrentPage(context),
                        ),
                      ),
                      Positioned(
                        right: rs(context, 15),
                        top: rs(context, (kToolbarHeight - 40) / 2),
                        bottom: rs(context, (kToolbarHeight - 30) / 2),
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
                height: rs(context, 70),
                fit: BoxFit.contain,
              ),
              SizedBox(height: rs(context, 30)),
              _drawerItem(Icons.home, "Home", AppPage.home),
              SizedBox(height: rs(context, 12)),
              _drawerItem(Icons.bar_chart, "Statistics", AppPage.statistics),
              SizedBox(height: rs(context, 12)),
              _drawerItem(
                Icons.person_search_rounded,
                "Account Status",
                AppPage.accountStatus,
              ),

              SizedBox(height: rs(context, 12)),
              _drawerItem(
                Icons.manage_accounts,
                "Account Settings",
                AppPage.accountSettings,
              ),
              SizedBox(height: rs(context, 12)),
              _drawerItem(
                Icons.settings,
                "Page Settings",
                AppPage.pageSettings,
              ),
              const Spacer(),

              // logout button
              Padding(
                padding: EdgeInsetsGeometry.only(left: rs(context, 10)),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white70,
                    size: rs(context, 25),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    logout();
                  },
                ),
              ),
              SizedBox(height: rs(context, 20)),
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
      padding: EdgeInsetsGeometry.only(left: rs(context, 15)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.yellow : Colors.white70,
          size: rs(context, 25),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: rs(context, 5)),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: rs(context, 15),
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
          icon: Icon(icon, color: Colors.black87, size: rs(context, 18)),
          onPressed: onTap,
        ),
      );
    },
  );
}
