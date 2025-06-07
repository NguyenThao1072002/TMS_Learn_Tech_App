import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Default locale is Vietnamese
  Locale _currentLocale = const Locale('vi', '');
  
  // Available languages with their display names and flags
  final List<Map<String, dynamic>> availableLanguages = [
    {
      'name': 'English',
      'code': 'en',
      'flag': '🇺🇸',
    },
    {
      'name': 'Tiếng Việt',
      'code': 'vi',
      'flag': '🇻🇳',
    },
  ];
  
  LanguageController() {
    _loadSavedLanguage();
  }
  
  Locale get currentLocale => _currentLocale;
  
  // Load saved language preference
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage, '');
      } else {
        // If no saved language, set Vietnamese as default
        _currentLocale = const Locale('vi', '');
        // Save the default language
        await prefs.setString(_languageKey, 'vi');
      }
      notifyListeners();
    } catch (e) {
      print('Error loading language: $e');
    }
  }
  
  // Set language and save preference
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    
    _currentLocale = Locale(languageCode, '');
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }
  
  // Get the display name of the current language
  String getCurrentLanguageName() {
    final currentLanguage = availableLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => availableLanguages.where((lang) => lang['code'] == 'vi').first,
    );
    
    return currentLanguage['name'] ?? 'Tiếng Việt';
  }
  
  // Get the flag of the current language
  String getCurrentLanguageFlag() {
    final currentLanguage = availableLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => availableLanguages.where((lang) => lang['code'] == 'vi').first,
    );
    
    return currentLanguage['flag'] ?? '🇻🇳';
  }
} 