import 'dart:io'; // For exit(0)
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
    HomeScreen(), // Index 0
    IncomeScreen(), // Index 1
    ExpenseScreen(), // Index 2
    ChartScreen(), // Index 3
    SummaryScreen(),
    ProfileScreen(), // Index 4
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

  // Android Back Button Logic
  void _handleSystemBack() {
    if (_currentIndex != 0) {
      // Home Tab မဟုတ်ရင် Home ကိုပြန်ပို့
      setState(() {
        _currentIndex = 0;
      });
    } else {
      // Home ရောက်နေရင် App ကနေ ထွက်
      exit(0);
    }
  }
}
