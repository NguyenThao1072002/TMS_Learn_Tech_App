import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeController() {
    _loadThemeFromPrefs();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themeKey);
      
      if (themeValue != null) {
        _themeMode = themeValue == 'dark' 
            ? ThemeMode.dark 
            : (themeValue == 'system' ? ThemeMode.system : ThemeMode.light);
      } else {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.dark 
          ? 'dark' 
          : (mode == ThemeMode.system ? 'system' : 'light');
      await prefs.setString(_themeKey, value);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
