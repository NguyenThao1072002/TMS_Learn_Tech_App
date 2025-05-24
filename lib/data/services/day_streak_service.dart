import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/streak/day_streak_model.dart';

/// Service để gọi API liên quan đến Day Streak
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
      // Cấu hình header với token
      dio.options.headers['Authorization'] = 'Bearer $token';

      // Thêm headers có thể cần thiết (tương tự Postman)
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Cache-Control'] = 'no-cache';

      // Log URL để debug
      debugPrint('🔍 Gọi API Day Streak: $baseUrl/activity/streak/$userId');
      debugPrint('🔑 Token: ${token.substring(0, 20)}...');
      debugPrint('📤 Headers: ${dio.options.headers}');

      // Gọi API
      final response = await dio.get(
        '$baseUrl/activity/streak/$userId',
      );

      // Kiểm tra response
      if (response.statusCode == 200) {
        final data = response.data;

        // Log toàn bộ response để debug
        debugPrint('✅ API Day Streak response: ${response.data}');

        // Kiểm tra dữ liệu trả về
        if (data != null && data['data'] != null) {
          // Parse dữ liệu thành model
          final streakData = data['data'];

          // Log thông tin streak để debug
          debugPrint(
              '📊 currentStreak: ${streakData['currentStreak']}, maxStreak: ${streakData['maxStreak']}');

          // Tính toán totalActiveDays từ activeDates
          final activeDates =
              List<String>.from(streakData['activeDates'] ?? []);
          final totalActiveDays = activeDates.length;

          // Log danh sách activeDates
          debugPrint('📅 Số ngày hoạt động: $totalActiveDays');
          debugPrint(
              '📅 Ngày hoạt động gần nhất: ${activeDates.isNotEmpty ? activeDates.last : "Không có"}');

          // Tự tính toán currentStreak nếu giá trị từ API là 0 nhưng có activeDates
          int apiCurrentStreak = streakData['currentStreak'] ?? 0;
          if (apiCurrentStreak == 0 && activeDates.isNotEmpty) {
            // Tính lại currentStreak theo thuật toán của test_streak.dart
            int calculatedStreak = _calculateCurrentStreak(activeDates);
            debugPrint(
                '📈 Tự tính lại currentStreak: $calculatedStreak (API: $apiCurrentStreak)');

            // Nếu tính toán ra giá trị khác 0, sử dụng giá trị tính toán
            if (calculatedStreak > 0) {
              apiCurrentStreak = calculatedStreak;
              debugPrint('📈 Đã ghi đè currentStreak = $apiCurrentStreak');
            }
          }

          return DayStreakData(
            userId: userId,
            currentStreak: apiCurrentStreak,
            maxStreak: streakData['maxStreak'] ?? 0,
            totalActiveDays: totalActiveDays,
            activeDates: activeDates,
          );
        } else {
          debugPrint('❌ Dữ liệu trả về không hợp lệ: $data');
          throw Exception('Dữ liệu trả về không hợp lệ');
        }
      } else {
        debugPrint(
            '❌ Lỗi khi lấy dữ liệu chuỗi ngày học: ${response.statusCode}');
        throw Exception(
            'Lỗi khi lấy dữ liệu chuỗi ngày học: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi gọi API day streak: $e');

      // Tạo dữ liệu mẫu cho môi trường phát triển
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timed out')) {
        debugPrint('🔄 Sử dụng dữ liệu mẫu cho day streak');
        return _getMockDayStreakData(userId);
      }

      // Nếu không phải lỗi kết nối, throw lại exception
      rethrow;
    }
  }

  /// Tính toán chuỗi ngày học hiện tại
  int _calculateCurrentStreak(List<String> activeDates) {
    if (activeDates.isEmpty) return 0;

    // Sắp xếp theo thứ tự giảm dần để bắt đầu từ ngày gần nhất
    List<String> sortedDates = List.from(activeDates);
    sortedDates.sort((a, b) => b.compareTo(a));

    // Lấy ngày hiện tại và hôm qua
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final yesterdayStr =
        "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

    debugPrint('📅 Ngày hiện tại: $today, Hôm qua: $yesterdayStr');
    debugPrint('📅 Ngày hoạt động gần nhất: ${sortedDates[0]}');

    // Kiểm tra xem ngày gần nhất có phải là hôm nay hoặc hôm qua không
    if (sortedDates[0] != today && sortedDates[0] != yesterdayStr) {
      debugPrint(
          '❌ Chuỗi đã bị đứt vì ngày gần nhất không phải hôm nay hoặc hôm qua');
      return 0; // Nếu không phải, chuỗi đã bị đứt
    }

    // Đếm số ngày liên tiếp
    int streak = 1;
    DateTime currentDate = DateTime.parse(sortedDates[0]);

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

  /// Tạo dữ liệu mẫu cho môi trường phát triển
  DayStreakData _getMockDayStreakData(int userId) {
    // Tạo danh sách ngày hoạt động trong 30 ngày gần nhất
    final now = DateTime.now();
    final List<String> activeDates = [];

    // Tạo chuỗi ngày hiện tại (5 ngày liên tiếp)
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      activeDates.add(date.toIso8601String().split('T')[0]);
    }

    // Thêm một số ngày hoạt động ngẫu nhiên trong quá khứ
    for (int i = 6; i < 30; i++) {
      // 70% khả năng là ngày hoạt động
      if (i % 3 != 0) {
        final date = now.subtract(Duration(days: i));
        activeDates.add(date.toIso8601String().split('T')[0]);
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
