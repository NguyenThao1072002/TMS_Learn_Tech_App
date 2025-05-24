import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/streak/day_streak_model.dart';

/// Service để gọi API liên quan đến Day Streak (chuỗi ngày học liên tục)
class DayStreakService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  /// Constructor với dependency injection cho Dio
  DayStreakService({required this.dio});

  /// Lấy thông tin chuỗi ngày học của người dùng
  ///
  /// [userId]: ID của người dùng cần lấy thông tin
  /// [token]: JWT token để xác thực
  ///
  /// Trả về [DayStreakData] chứa thông tin chuỗi ngày học
  Future<DayStreakData> getUserDayStreak({
    required int userId,
    required String token,
  }) async {
    try {
      // Cấu hình headers API request
      _configureHeaders(token);

      // Gọi API
      final response = await dio.get('$baseUrl/activity/streak/$userId');

      // Kiểm tra response
      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['data'] != null) {
          // Parse dữ liệu và tính toán streak
          return _processStreakData(data['data'], userId);
        } else {
          throw Exception('Dữ liệu trả về không hợp lệ');
        }
      } else {
        throw Exception(
            'Lỗi khi lấy dữ liệu chuỗi ngày học: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi gọi API day streak: $e');

      // Nếu lỗi kết nối, sử dụng dữ liệu mẫu
      if (_isConnectionError(e)) {
        return _getMockDayStreakData(userId);
      }

      // Nếu không phải lỗi kết nối, throw lại exception
      rethrow;
    }
  }

  /// Cấu hình headers cho API request
  void _configureHeaders(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Cache-Control'] = 'no-cache';
  }

  /// Kiểm tra xem có phải lỗi kết nối không
  bool _isConnectionError(dynamic error) {
    final errorMsg = error.toString().toLowerCase();
    return errorMsg.contains('socketexception') ||
        errorMsg.contains('connection refused') ||
        errorMsg.contains('connection timed out');
  }

  /// Xử lý dữ liệu streak từ API response
  DayStreakData _processStreakData(
      Map<String, dynamic> streakData, int userId) {
    // Lấy danh sách các ngày hoạt động
    final activeDates = List<String>.from(streakData['activeDates'] ?? []);
    final totalActiveDays = activeDates.length;

    // Lấy currentStreak từ API
    int apiCurrentStreak = streakData['currentStreak'] ?? 0;
    final int maxStreak = streakData['maxStreak'] ?? 0;

    // Nếu API trả về currentStreak = 0 nhưng có activeDates, tự tính lại
    if (apiCurrentStreak == 0 && activeDates.isNotEmpty) {
      int calculatedStreak = _calculateCurrentStreak(activeDates);

      // Sử dụng giá trị tính toán nếu hợp lý
      if (calculatedStreak > 0) {
        debugPrint(
            '📈 Sử dụng currentStreak được tính lại: $calculatedStreak (thay cho API: 0)');
        apiCurrentStreak = calculatedStreak;
      }
    }

    return DayStreakData(
      userId: userId,
      currentStreak: apiCurrentStreak,
      maxStreak: maxStreak,
      totalActiveDays: totalActiveDays,
      activeDates: activeDates,
    );
  }

  /// Tính toán chuỗi ngày học hiện tại dựa trên danh sách ngày hoạt động
  int _calculateCurrentStreak(List<String> activeDates) {
    if (activeDates.isEmpty) return 0;

    // Sắp xếp theo thứ tự giảm dần để bắt đầu từ ngày gần nhất
    List<String> sortedDates = List.from(activeDates);
    sortedDates.sort((a, b) => b.compareTo(a));

    // Lấy ngày hiện tại và hôm qua theo định dạng yyyy-MM-dd
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final today = _formatDate(now);
    final yesterdayStr = _formatDate(yesterday);

    // Ngày hoạt động gần nhất
    final latestActiveDate = sortedDates[0];

    // Kiểm tra xem ngày gần nhất có phải là hôm nay hoặc hôm qua không
    if (latestActiveDate != today && latestActiveDate != yesterdayStr) {
      return 0; // Chuỗi đã bị đứt
    }

    // Đếm số ngày liên tiếp
    int streak = 1;
    DateTime currentDate = DateTime.parse(latestActiveDate);

    for (int i = 1; i < sortedDates.length; i++) {
      DateTime prevDate = DateTime.parse(sortedDates[i]);

      // Tính số ngày chênh lệch
      int dayDiff = currentDate.difference(prevDate).inDays;

      if (dayDiff == 1) {
        // Nếu là ngày liên tiếp, tăng streak
        streak++;
        currentDate = prevDate;
      } else if (dayDiff > 1) {
        // Nếu có khoảng cách, chuỗi bị đứt
        break;
      }
    }

    return streak;
  }

  /// Định dạng DateTime thành chuỗi yyyy-MM-dd
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Tạo dữ liệu mẫu cho môi trường phát triển khi không kết nối được API
  DayStreakData _getMockDayStreakData(int userId) {
    debugPrint('🔄 Sử dụng dữ liệu mẫu cho day streak');

    // Tạo danh sách ngày hoạt động trong 30 ngày gần nhất
    final now = DateTime.now();
    final List<String> activeDates = [];

    // Tạo chuỗi ngày hiện tại (5 ngày liên tiếp)
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      activeDates.add(_formatDate(date));
    }

    // Thêm một số ngày hoạt động ngẫu nhiên trong quá khứ
    for (int i = 6; i < 30; i++) {
      // 70% khả năng là ngày hoạt động
      if (i % 3 != 0) {
        final date = now.subtract(Duration(days: i));
        activeDates.add(_formatDate(date));
      }
    }

    return DayStreakData(
      userId: userId,
      currentStreak: 5,
      maxStreak: 12,
      totalActiveDays: activeDates.length,
      activeDates: activeDates,
    );
  }
}
