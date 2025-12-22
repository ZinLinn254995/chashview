// presentation/viewmodels/theme_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = "theme_mode";
  ThemeMode _themeMode = ThemeMode.system;

  ThemeViewModel() {
    _loadTheme(); // App စဖွင့်ချိန်မှာ သိမ်းထားတာကို ပြန်ဖတ်မယ်
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // ရွေးချယ်မှုကို သိမ်းထားမယ်
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (e) => e.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }
}