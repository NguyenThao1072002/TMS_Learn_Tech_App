import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/ranking/ranking.dart';
import 'package:tms_app/data/models/streak/day_streak_model.dart';
import 'package:tms_app/domain/usecases/day_streak_usecase.dart';
import 'package:tms_app/domain/usecases/ranking_usecase.dart';

/// Controller quản lý dữ liệu chuỗi ngày học (day streak)
class RankingController extends ChangeNotifier {
  final GetRankingsUseCase _getRankingsUseCase;
  final GetCurrentUserRankingUseCase _getCurrentUserRankingUseCase;
  final GetCurrentUserPointsUseCase _getCurrentUserPointsUseCase;

  List<Ranking>? _rankings;
  int? _currentUserRanking;
  int? _currentUserPoints;
  bool _isLoading = false;
  String? _error;

  /// Constructor với dependency injection cho các usecase
  RankingController({
    required GetRankingsUseCase getRankingsUseCase,
    required GetCurrentUserRankingUseCase getCurrentUserRankingUseCase,
    required GetCurrentUserPointsUseCase getCurrentUserPointsUseCase,
  })  : _getRankingsUseCase = getRankingsUseCase,
        _getCurrentUserRankingUseCase = getCurrentUserRankingUseCase,
        _getCurrentUserPointsUseCase = getCurrentUserPointsUseCase;

  /// Getter cho dữ liệu streak
  List<Ranking>? get rankings => _rankings;

  /// Getter cho trạng thái loading
  bool get isLoading => _isLoading;

  /// Getter cho thông báo lỗi
  String? get error => _error;

  /// Getter cho chuỗi ngày học hiện tại
  int get currentUserRanking => _currentUserRanking ?? 0;

  /// Getter cho chuỗi ngày học dài nhất
  int get currentUserPoints => _currentUserPoints ?? 0;

  /// Tải dữ liệu chuỗi ngày học từ API
  Future<void> loadRankings(String periodType) async {
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

      final rankings = await _getRankingsUseCase.execute(
        periodType,
        userId,
      );

      // // Debug log thông tin streak
      // debugPrint(
      //     '✨ Day Streak Data: currentStreak=${data.currentStreak}, maxStreak=${data.maxStreak}');
      // debugPrint('📆 Tổng số ngày hoạt động: ${data.activeDates.length}');
      // if (data.activeDates.isNotEmpty) {
      //   debugPrint('📆 Ngày gần nhất: ${data.activeDates.last}');
      // }

      _rankings = rankings;
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
  Future<void> refreshRankings() async {
    // Reset data
    _rankings = null;
    notifyListeners();

    // Tải lại dữ liệu từ API
    await loadRankings('week');
  }

  /// Kiểm tra xem một ngày cụ thể có phải là ngày hoạt động không
  bool isActiveDate(DateTime date) {
    if (_rankings == null) return false;
    return _rankings!.any((ranking) => ranking.createdAt == date.toIso8601String());
  }

  /// Lấy số ngày hoạt động trong tháng
  int getActiveCountInMonth(int month, int year) {
    if (_rankings == null) return 0;
    return _rankings!.where((ranking) => DateTime.parse(ranking.createdAt).month == month && DateTime.parse(ranking.createdAt).year == year).length;
  }

  /// Lấy số ngày hoạt động trong tuần
  int getActiveCountInWeek(DateTime weekStart) {
    if (_rankings == null) return 0;
    return _rankings!.where((ranking) => DateTime.parse(ranking.createdAt).weekday == weekStart.weekday).length;
  }

  /// Tính toán ngày bắt đầu của tuần từ một ngày bất kỳ
  DateTime getWeekStartDate(DateTime date, {int startWeekDay = 1}) {
    return DateTime(date.year, date.month, date.day - date.weekday + startWeekDay);
  }

  /// Tính tỷ lệ hoàn thành trong khoảng thời gian
  double getCompletionRate({DateTime? startDate, DateTime? endDate}) {
    if (_rankings == null) return 0.0;

    // Mặc định là 30 ngày gần nhất
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 30));

    // Đếm số ngày hoạt động trong khoảng thời gian
    int activeDaysCount = 0;
    for (Ranking ranking in _rankings!) {
      final date = DateTime.parse(ranking.createdAt);
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
