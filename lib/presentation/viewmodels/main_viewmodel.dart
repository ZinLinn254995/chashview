// lib/presentation/viewmodels/main_viewmodel.dart
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
  void navigateTo(String route, {String? title, bool hideBottomNav = false}) {
    _currentSubRoute = route;
    _title = title ?? _getTitleForRoute(route);
    _showBottomNav = !hideBottomNav;
    _showBackButton = hideBottomNav;
    notifyListeners();
  }

  /// Go back to the main tab screen
  void goBack() {
    _currentSubRoute = _getDefaultRouteForIndex(_currentIndex);
    _title = _getTitleForIndex(_currentIndex);
    _showBottomNav = true;
    _showBackButton = false;
    notifyListeners();
  }

  String _getDefaultRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/income';
      case 2:
        return '/expense';
      case 3:
        return '/chart';
      case 4:
        return '/profile';
      default:
        return '/';
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Income';
      case 2:
        return 'Expense';
      case 3:
        return 'Chart';
      case 4:
        return 'Profile';
      default:
        return 'App';
    }
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/settings':
        return 'Settings';
      case '/addExpense':
        return 'Add Expense';
      default:
        return 'App';
    }
  }
}
