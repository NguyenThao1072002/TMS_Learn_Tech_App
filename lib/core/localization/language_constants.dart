import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LANGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String VIETNAMESE = 'vi';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LANGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(LANGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, '');
    case VIETNAMESE:
      return const Locale(VIETNAMESE, '');
    default:
      return const Locale(ENGLISH, '');
  }
}

String getTranslatedLanguageName(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return 'English';
    case VIETNAMESE:
      return 'Tiếng Việt';
    default:
      return 'English';
  }
} 