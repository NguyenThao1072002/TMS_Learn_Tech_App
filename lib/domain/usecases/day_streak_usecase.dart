import 'package:tms_app/data/models/streak/day_streak_model.dart';
import 'package:tms_app/domain/repositories/day_streak_repository.dart';

/// Usecase để lấy thông tin chuỗi ngày học của người dùng
class GetUserDayStreakUseCase {
  final DayStreakRepository _repository;

  GetUserDayStreakUseCase(this._repository);

  /// Thực thi usecase
  ///
  /// [userId]: ID của người dùng cần lấy thông tin
  /// [token]: JWT token để xác thực
  ///
  /// Trả về [DayStreakData] chứa thông tin chuỗi ngày học
  /// Có thể throw Exception nếu có lỗi
  Future<DayStreakData> execute({
    required int userId,
    required String token,
  }) async {
    return await _repository.getUserDayStreak(
      userId: userId,
      token: token,
    );
  }
}

/// Usecase để kiểm tra một ngày có phải là ngày hoạt động không
class IsActiveDateUseCase {
  final DayStreakRepository _repository;

  IsActiveDateUseCase(this._repository);

  /// Thực thi usecase
  ///
  /// [date]: Ngày cần kiểm tra
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về true nếu là ngày hoạt động, false nếu không phải
  bool execute({
    required DateTime date,
    required List<String> activeDates,
  }) {
    final dateStr = _formatDate(date);
    return activeDates.contains(dateStr);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

/// Usecase để lấy số ngày hoạt động trong một tháng
class GetActiveCountInMonthUseCase {
  final DayStreakRepository _repository;

  GetActiveCountInMonthUseCase(this._repository);

  /// Thực thi usecase
  ///
  /// [month]: Tháng cần đếm (1-12)
  /// [year]: Năm của tháng cần đếm
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về số ngày hoạt động trong tháng đó
  int execute({
    required int month,
    required int year,
    required List<String> activeDates,
  }) {
    return activeDates.where((dateStr) {
      final date = DateTime.parse(dateStr);
      return date.month == month && date.year == year;
    }).length;
  }
}

/// Usecase để lấy số ngày hoạt động trong một tuần
class GetActiveCountInWeekUseCase {
  final DayStreakRepository _repository;

  GetActiveCountInWeekUseCase(this._repository);

  /// Thực thi usecase
  ///
  /// [weekStart]: Ngày bắt đầu của tuần (thường là thứ Hai)
  /// [activeDates]: Danh sách các ngày hoạt động
  ///
  /// Trả về số ngày hoạt động trong tuần đó
  int execute({
    required DateTime weekStart,
    required List<String> activeDates,
  }) {
    final weekEndDate = weekStart.add(const Duration(days: 6));

    return activeDates.where((dateStr) {
      final date = DateTime.parse(dateStr);
      return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEndDate.add(const Duration(days: 1)));
    }).length;
  }
}

/// Usecase để lấy ngày đầu tuần từ một ngày bất kỳ
class GetWeekStartDateUseCase {
  /// Thực thi usecase
  ///
  /// [date]: Ngày bất kỳ trong tuần
  /// [startWeekDay]: Ngày bắt đầu tuần (1 = Thứ Hai, 7 = Chủ Nhật)
  ///
  /// Trả về ngày bắt đầu của tuần chứa ngày được chỉ định
  DateTime execute({
    required DateTime date,
    int startWeekDay = 1,
  }) {
    // Lấy ngày đầu tuần (mặc định là thứ 2 - startWeekDay = 1)
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - startWeekDay));
  }
}
