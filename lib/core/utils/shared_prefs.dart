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

  // Phương thức để lấy instance SharedPreferences
  static Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

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

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_USER_ID, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Thử lấy dưới dạng int
    final intId = prefs.getInt(KEY_USER_ID);
    if (intId != null) {
      return intId;
    }

    // Nếu không có, thử lấy dưới dạng String và chuyển đổi
    final stringId = prefs.getString(KEY_USER_ID);
    if (stringId != null) {
      return int.tryParse(stringId);
    }

    return null;
  }
}
