import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Available languages
  final List<Map<String, dynamic>> availableLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
  ];
  
  // Current language
  Locale _currentLocale = const Locale('en');
  
  LanguageController() {
    _loadLanguageFromPrefs();
  }
  
  Locale get currentLocale => _currentLocale;
  
  Map<String, dynamic> get currentLanguage {
    return availableLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => availableLanguages.first,
    );
  }
  
  Future<void> _loadLanguageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    
    _currentLocale = Locale(languageCode);
    notifyListeners();
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }
} 