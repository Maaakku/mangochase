import 'package:flutter/material.dart';
import 'home_dashboard.dart';
import 'schedule_page.dart';
import 'scan_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'ai_page.dart';
import '../core/business_mode.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Global key for accessing MainScreenState from other pages
  static final GlobalKey<MainScreenState> globalKey =
      GlobalKey<MainScreenState>();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _currentPage = 'home';

  // Track tab history
  final List<int> _history = [0];

  // Allow other pages to navigate back to Home
  void navigateToHome({bool addToHistory = true}) {
    setState(() {
      _selectedIndex = 0; // go to Home tab
      _currentPage = 'home';
      if (addToHistory) {
        _history.add(0);
      }
    });
  }

  // Handle hardware back button
  Future<bool> _onWillPop() async {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _selectedIndex = _history.last;
        _currentPage =
            _getPageForIndex(_selectedIndex, BusinessMode.enabled.value);
      });
      return false; // prevent app exit
    }
    return true; // allow app exit if history empty
  }

  // Map logical pages to indices depending on business mode
  int _getIndexForPage(String page, bool businessEnabled) {
    switch (page) {
      case 'home':
        return 0;
      case 'schedule':
        return 1;
      case 'scan':
        return 2;
      case 'stats':
        return businessEnabled ? 3 : -1;
      case 'settings':
        return businessEnabled ? 4 : 3;
      case 'ai':
        return businessEnabled ? 5 : 4;
      default:
        return 0;
    }
  }

  // Map index back to logical page
  String _getPageForIndex(int index, bool businessEnabled) {
    if (businessEnabled) {
      switch (index) {
        case 0:
          return 'home';
        case 1:
          return 'schedule';
        case 2:
          return 'scan';
        case 3:
          return 'stats';
        case 4:
          return 'settings';
        case 5:
          return 'ai';
        default:
          return 'home';
      }
    } else {
      switch (index) {
        case 0:
          return 'home';
        case 1:
          return 'schedule';
        case 2:
          return 'scan';
        case 3:
          return 'settings';
        case 4:
          return 'ai';
        default:
          return 'home';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BusinessMode.enabled,
      builder: (context, businessEnabled, _) {
        final List<Widget> pages = [
          const HomeDashboard(),
          const SchedulePage(),
          const ScanPage(),
          if (businessEnabled) const StatisticsPage(),
          const SettingsPage(),
          const AIPage(),
        ];

        final List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Scan'),
          if (businessEnabled)
            const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Stats'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
          const BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'AI'),
        ];

        // Recompute index based on mode
        int newIndex = _getIndexForPage(_currentPage, businessEnabled);

        if (newIndex == -1) {
          // If page not valid in this mode, fallback to home
          newIndex = 0;
          _currentPage = 'home';
        }

        // Fix index if needed
        if (_selectedIndex != newIndex) {
          _selectedIndex = newIndex;
        }

        return WillPopScope(
          onWillPop: _onWillPop, // intercept back button
          child: Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              items: items,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _currentPage = _getPageForIndex(index, businessEnabled);
                  // Update history stack
                  if (_history.isEmpty || _history.last != index) {
                    _history.add(index);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}
