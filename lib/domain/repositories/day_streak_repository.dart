import 'package:tms_app/data/models/streak/day_streak_model.dart';

/// Interface cho repository xử lý dữ liệu chuỗi ngày học
abstract class DayStreakRepository {
  /// Lấy thông tin chuỗi ngày học của người dùng
  ///
  /// [userId]: ID của người dùng cần lấy thông tin
  /// [token]: JWT token để xác thực
  ///
  /// Trả về [DayStreakData] chứa thông tin chuỗi ngày học
  Future<DayStreakData> getUserDayStreak({
    required int userId,
    required String token,
  });

  /// Kiểm tra xem một ngày cụ thể có phải là ngày hoạt động không
  ///
  /// [date]: Ngày cần kiểm tra
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về true nếu là ngày hoạt động, false nếu không phải
  bool isActiveDate(DateTime date, List<String> activeDates);

  /// Lấy số ngày hoạt động trong tháng
  ///
  /// [month]: Tháng cần đếm (1-12)
  /// [year]: Năm của tháng cần đếm
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về số ngày hoạt động trong tháng đó
  int getActiveCountInMonth(int month, int year, List<String> activeDates);

  /// Lấy số ngày hoạt động trong tuần
  ///
  /// [weekStart]: Ngày bắt đầu của tuần (thường là thứ Hai)
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về số ngày hoạt động trong tuần đó
  int getActiveCountInWeek(DateTime weekStart, List<String> activeDates);
}
