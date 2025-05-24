import 'package:tms_app/data/models/streak/day_streak_model.dart';
import 'package:tms_app/data/services/day_streak_service.dart';
import 'package:tms_app/domain/repositories/day_streak_repository.dart';

/// Implementation của DayStreakRepository
class DayStreakRepositoryImpl implements DayStreakRepository {
  final DayStreakService dayStreakService;

  /// Constructor với dependency injection cho service
  DayStreakRepositoryImpl({required this.dayStreakService});

  @override
  Future<DayStreakData> getUserDayStreak({
    required int userId,
    required String token,
  }) async {
    try {
      return await dayStreakService.getUserDayStreak(
        userId: userId,
        token: token,
      );
    } catch (e) {
      // Xử lý lỗi và trả về lỗi phù hợp
      rethrow;
    }
  }

  @override
  bool isActiveDate(DateTime date, List<String> activeDates) {
    // Chuyển đổi DateTime thành chuỗi yyyy-MM-dd
    final dateString = date.toIso8601String().split('T')[0];

    // Kiểm tra xem ngày này có trong danh sách activeDates không
    return activeDates.contains(dateString);
  }

  @override
  int getActiveCountInMonth(int month, int year, List<String> activeDates) {
    int count = 0;

    // Lặp qua tất cả các ngày hoạt động
    for (String dateStr in activeDates) {
      try {
        final date = DateTime.parse(dateStr);

        // Kiểm tra xem ngày này có trong tháng và năm được chỉ định không
        if (date.month == month && date.year == year) {
          count++;
        }
      } catch (e) {
        // Bỏ qua các ngày có định dạng không hợp lệ
        continue;
      }
    }

    return count;
  }

  @override
  int getActiveCountInWeek(DateTime weekStart, List<String> activeDates) {
    // Tính ngày kết thúc tuần (6 ngày sau ngày bắt đầu)
    final weekEnd = weekStart.add(const Duration(days: 6));
    int count = 0;

    // Lặp qua tất cả các ngày hoạt động
    for (String dateStr in activeDates) {
      try {
        final date = DateTime.parse(dateStr);

        // Kiểm tra xem ngày này có trong khoảng thời gian của tuần không
        if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekEnd.add(const Duration(days: 1)))) {
          count++;
        }
      } catch (e) {
        // Bỏ qua các ngày có định dạng không hợp lệ
        continue;
      }
    }

    return count;
  }
}
