class DayStreakResponse {
  final int status;
  final String message;
  final DayStreakData data;

  DayStreakResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DayStreakResponse.fromJson(Map<String, dynamic> json) {
    return DayStreakResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: DayStreakData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Model chứa thông tin chuỗi ngày học của người dùng
class DayStreakData {
  /// ID của người dùng
  final int userId;

  /// Chuỗi ngày học hiện tại
  final int currentStreak;

  /// Chuỗi ngày học dài nhất
  final int maxStreak;

  /// Tổng số ngày đã học
  final int totalActiveDays;

  /// Danh sách các ngày đã học (định dạng yyyy-MM-dd)
  final List<String> activeDates;

  /// Constructor
  DayStreakData({
    required this.userId,
    required this.currentStreak,
    required this.maxStreak,
    required this.totalActiveDays,
    required this.activeDates,
  });

  /// Tạo đối tượng từ JSON
  factory DayStreakData.fromJson(Map<String, dynamic> json) {
    final activeDates = List<String>.from(json['activeDates'] ?? []);

    return DayStreakData(
      userId: json['userId'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      totalActiveDays: activeDates.length,
      activeDates: activeDates,
    );
  }

  /// Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'totalActiveDays': totalActiveDays,
      'activeDates': activeDates,
    };
  }

  /// Chuyển đổi chuỗi ngày thành đối tượng DateTime
  List<DateTime> getActiveDateTimes() {
    return activeDates.map((dateString) => DateTime.parse(dateString)).toList();
  }

  /// Kiểm tra xem một ngày cụ thể có phải là ngày hoạt động không
  bool isActiveDate(DateTime date) {
    final dateString =
        date.toString().split(' ')[0]; // Lấy phần ngày YYYY-MM-DD
    return activeDates.contains(dateString);
  }

  /// Lấy số ngày hoạt động trong tháng
  int getActiveCountInMonth(int month, int year) {
    final dateTimes = getActiveDateTimes();
    return dateTimes
        .where((date) => date.month == month && date.year == year)
        .length;
  }

  /// Lấy số ngày hoạt động trong tuần
  int getActiveCountInWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateTimes = getActiveDateTimes();

    return dateTimes
        .where((date) =>
            date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekEnd.add(const Duration(days: 1))))
        .length;
  }
}
