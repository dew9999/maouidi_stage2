// lib/nav_bar_page.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/index.dart';
import '/flutter_flow/nav/nav.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    super.key,
    this.initialPage,
    this.page,
  });

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'HomePage';
  late Widget? _currentPage;
  final AppStateNotifier _appStateNotifier = AppStateNotifier.instance;

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
    _appStateNotifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appStateNotifier.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final userRole = _appStateNotifier.userRole;

    if (_appStateNotifier.loggedIn && userRole == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final Map<String, Widget> tabs;
    final List<GButton> navBarButtons;

    if (userRole == 'Medical Partner') {
      tabs = {
        'HomePage': const HomePageWidget(),
        'PartnerDashboardPage':
            PartnerDashboardPageWidget(partnerId: currentUserUid),
        'SettingsPage': const SettingsPageWidget(),
      };
      navBarButtons = const [
        GButton(icon: Icons.home_outlined, text: 'Home'),
        GButton(icon: Icons.dashboard_outlined, text: 'Dashboard'),
        GButton(icon: Icons.settings_outlined, text: 'Settings'),
      ];
    } else {
      tabs = {
        'HomePage': const HomePageWidget(),
        'PatientDashboard': const PatientDashboardWidget(),
        'SettingsPage': const SettingsPageWidget(),
      };
      navBarButtons = const [
        GButton(icon: Icons.home_outlined, text: 'Home'),
        GButton(icon: Icons.calendar_today_outlined, text: 'Appointments'),
        GButton(icon: Icons.settings_outlined, text: 'Settings'),
      ];
    }

    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          boxShadow: [
            BoxShadow(
                blurRadius: 4,
                color: theme.primaryBackground,
                offset: const Offset(0, -2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: GNav(
            selectedIndex: currentIndex,
            onTabChange: (i) {
              setState(() {
                _currentPage = null;
                _currentPageName = tabs.keys.toList()[i];
              });
            },
            backgroundColor: theme.secondaryBackground,
            color: theme.secondaryText,
            activeColor: theme.primary,
            tabBackgroundColor: theme.primaryBackground,
            gap: 8,
            padding: const EdgeInsets.all(12),
            tabs: navBarButtons,
          ),
        ),
      ),
    );
  }
}
