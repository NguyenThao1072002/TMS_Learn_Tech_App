import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // Định nghĩa các key hằng số
  static const String KEY_JWT_TOKEN = 'jwt';
  static const String KEY_REFRESH_TOKEN = 'refreshToken';
  static const String KEY_USER_EMAIL = 'user_email';
  static const String KEY_USER_PHONE = 'user_phone';
  static const String KEY_USER_ID = 'userId';
  static const String KEY_USER_FULLNAME = 'user_fullname';
  static const String KEY_USER_IMAGE = 'user_image';

  static Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_JWT_TOKEN, token);
  }

  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_JWT_TOKEN);
  }

  static Future<void> removeJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_JWT_TOKEN);
  }
}
