import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/streak/day_streak_model.dart';
import 'package:tms_app/domain/usecases/day_streak_usecase.dart';

/// Controller quản lý dữ liệu chuỗi ngày học (day streak)
class DayStreakController extends ChangeNotifier {
  final GetUserDayStreakUseCase _getUserDayStreakUseCase;
  final IsActiveDateUseCase _isActiveDateUseCase;
  final GetActiveCountInMonthUseCase _getActiveCountInMonthUseCase;
  final GetActiveCountInWeekUseCase _getActiveCountInWeekUseCase;
  final GetWeekStartDateUseCase _getWeekStartDateUseCase;

  DayStreakData? _dayStreakData;
  bool _isLoading = false;
  String? _error;

  /// Constructor với dependency injection cho các usecase
  DayStreakController({
    required GetUserDayStreakUseCase getUserDayStreakUseCase,
    required IsActiveDateUseCase isActiveDateUseCase,
    required GetActiveCountInMonthUseCase getActiveCountInMonthUseCase,
    required GetActiveCountInWeekUseCase getActiveCountInWeekUseCase,
    required GetWeekStartDateUseCase getWeekStartDateUseCase,
  })  : _getUserDayStreakUseCase = getUserDayStreakUseCase,
        _isActiveDateUseCase = isActiveDateUseCase,
        _getActiveCountInMonthUseCase = getActiveCountInMonthUseCase,
        _getActiveCountInWeekUseCase = getActiveCountInWeekUseCase,
        _getWeekStartDateUseCase = getWeekStartDateUseCase;

  /// Getter cho dữ liệu streak
  DayStreakData? get dayStreakData => _dayStreakData;

  /// Getter cho trạng thái loading
  bool get isLoading => _isLoading;

  /// Getter cho thông báo lỗi
  String? get error => _error;

  /// Getter cho chuỗi ngày học hiện tại
  int get currentStreak => _dayStreakData?.currentStreak ?? 0;

  /// Getter cho chuỗi ngày học dài nhất
  int get maxStreak => _dayStreakData?.maxStreak ?? 0;

  /// Getter cho danh sách ngày hoạt động
  List<String> get activeDates => _dayStreakData?.activeDates ?? [];

  /// Tải dữ liệu chuỗi ngày học từ API
  Future<void> loadDayStreak() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId =
          int.tryParse(prefs.getString(SharedPrefs.KEY_USER_ID) ?? '0') ?? 0;
      final token = prefs.getString('jwt') ?? '';

      debugPrint('👤 Đang tải dữ liệu day streak cho userId: $userId');

      if (userId <= 0 || token.isEmpty) {
        _error = 'Không tìm thấy thông tin người dùng';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = await _getUserDayStreakUseCase.execute(
        userId: userId,
        token: token,
      );

      // Debug log thông tin streak
      debugPrint(
          '✨ Day Streak Data: currentStreak=${data.currentStreak}, maxStreak=${data.maxStreak}');
      debugPrint('📆 Tổng số ngày hoạt động: ${data.activeDates.length}');
      if (data.activeDates.isNotEmpty) {
        debugPrint('📆 Ngày gần nhất: ${data.activeDates.last}');
      }

      _dayStreakData = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Lỗi khi tải dữ liệu chuỗi ngày học: $e');
      _error = 'Lỗi khi tải dữ liệu chuỗi ngày học: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu day streak và xóa cache
  Future<void> refreshDayStreak() async {
    // Reset data
    _dayStreakData = null;
    notifyListeners();

    // Tải lại dữ liệu từ API
    await loadDayStreak();
  }

  /// Kiểm tra xem một ngày cụ thể có phải là ngày hoạt động không
  bool isActiveDate(DateTime date) {
    if (_dayStreakData == null) return false;
    return _isActiveDateUseCase.execute(
      date: date,
      activeDates: activeDates,
    );
  }

  /// Lấy số ngày hoạt động trong tháng
  int getActiveCountInMonth(int month, int year) {
    if (_dayStreakData == null) return 0;
    return _getActiveCountInMonthUseCase.execute(
      month: month,
      year: year,
      activeDates: activeDates,
    );
  }

  /// Lấy số ngày hoạt động trong tuần
  int getActiveCountInWeek(DateTime weekStart) {
    if (_dayStreakData == null) return 0;
    return _getActiveCountInWeekUseCase.execute(
      weekStart: weekStart,
      activeDates: activeDates,
    );
  }

  /// Tính toán ngày bắt đầu của tuần từ một ngày bất kỳ
  DateTime getWeekStartDate(DateTime date, {int startWeekDay = 1}) {
    return _getWeekStartDateUseCase.execute(
      date: date,
      startWeekDay: startWeekDay,
    );
  }

  /// Tính tỷ lệ hoàn thành trong khoảng thời gian
  double getCompletionRate({DateTime? startDate, DateTime? endDate}) {
    if (_dayStreakData == null) return 0.0;

    // Mặc định là 30 ngày gần nhất
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 30));

    // Đếm số ngày hoạt động trong khoảng thời gian
    int activeDaysCount = 0;
    for (String dateStr in activeDates) {
      final date = DateTime.parse(dateStr);
      if (date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)))) {
        activeDaysCount++;
      }
    }

    // Tính tổng số ngày trong khoảng thời gian
    final difference = end.difference(start).inDays + 1;

    // Tính tỷ lệ
    return difference > 0 ? (activeDaysCount / difference) * 100 : 0.0;
  }
}
