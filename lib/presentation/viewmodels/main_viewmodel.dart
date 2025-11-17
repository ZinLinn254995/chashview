// lib/presentation/viewmodels/main_viewmodel.dart
import 'package:chashview/core/routing/route_names.dart';
import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  String _currentSubRoute = '/';
  String _title = 'Home';
  bool _showBottomNav = true;
  bool _showBackButton = false;

  int get currentIndex => _currentIndex;
  String get currentSubRoute => _currentSubRoute;
  String get title => _title;
  bool get showBottomNav => _showBottomNav;
  bool get showBackButton => _showBackButton;

  /// Change tab and reset to default sub-route
  void setTab(int index) {
    _currentIndex = index;
    _currentSubRoute = _getDefaultRouteForIndex(index);
    _title = _getTitleForIndex(index);
    _showBottomNav = true;
    _showBackButton = false;
    notifyListeners();
  }

  /// Navigate to an extra route inside MainAppContent
  void navigateTo(String route, {String? title, bool hideBottomNav = false, Map<String, dynamic>? arguments}) {
    _currentSubRoute = route;
    _title = title ?? _getTitleForRoute(route);
    _showBottomNav = !hideBottomNav;
    _showBackButton = hideBottomNav;

    // store arguments somewhere if you want, e.g., _currentArguments
    _currentArguments = arguments;

    notifyListeners();
  }

// Add a field to store arguments
  Map<String, dynamic>? _currentArguments;
  Map<String, dynamic>? get currentArguments => _currentArguments;


  /// Go back to the main tab screen
  void goBack() {
    _currentSubRoute = _getDefaultRouteForIndex(_currentIndex);
    _title = _getTitleForIndex(_currentIndex);
    _showBottomNav = true;
    _showBackButton = false;
    notifyListeners();
  }

  /// Handle system back button - returns whether back was handled
  bool handleSystemBack() {
    if (_showBackButton) {
      // If we're in a sub-route, go back to main tab
      goBack();
      return true; // Back was handled
    }
    return false; // Back was not handled, let system handle
  }

  String _getDefaultRouteForIndex(int index) {
    switch (index) {
      case 0: return '/';
      case 1: return '/income';
      case 2: return '/expense';
      case 3: return '/chart';
      case 4: return '/profile';
      default: return '/';
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Income';
      case 2: return 'Expense';
      case 3: return 'Chart';
      case 4: return 'Profile';
      default: return 'App';
    }
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/settings': return 'Settings';
      case '/addExpense': return 'Add Expense';
      case RouteNames.lessonOne: return 'Lesson 1';
      case RouteNames.lessonTwo: return 'Lesson 2';
      case RouteNames.lessonThree: return 'Lesson 3';
      case RouteNames.lessonFour: return 'Lesson 4';
      case RouteNames.category: return 'Categories';
      default: return 'App';
    }
  }
}