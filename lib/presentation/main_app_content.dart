import 'dart:io';
import 'package:chashview/presentation/screens/summary/summary_screen.dart';
import 'package:flutter/material.dart';

import 'widgets/bottom_nav_bar.dart';

// Screens
import 'screens/home/home_screen.dart';
import 'screens/income/income_screen.dart';
import 'screens/expense/expense_screen.dart';
import 'screens/chart/chart_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainAppContent extends StatefulWidget {
  const MainAppContent({super.key});

  @override
  State<MainAppContent> createState() => _MainAppContentState();
}

class _MainAppContentState extends State<MainAppContent> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    IncomeScreen(),
    ExpenseScreen(),
    ChartScreen(),
    SummaryScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSystemBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  void _handleSystemBack() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    } else {
      exit(0);
    }
  }
}