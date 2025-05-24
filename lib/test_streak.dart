import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streak Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StreakTestScreen(),
    );
  }
}

class StreakTestScreen extends StatefulWidget {
  const StreakTestScreen({Key? key}) : super(key: key);

  @override
  State<StreakTestScreen> createState() => _StreakTestScreenState();
}

class _StreakTestScreenState extends State<StreakTestScreen> {
  // Dữ liệu mẫu từ API
  final Map<String, dynamic> apiResponse = {
    "status": 200,
    "message": "Thống kê chuỗi học thành công",
    "data": {
      "currentStreak": 0,
      "maxStreak": 6,
      "activeDates": [
        "2025-04-26",
        "2025-04-27",
        "2025-04-29",
        "2025-04-30",
        "2025-05-11",
        "2025-05-12",
        "2025-05-13",
        "2025-05-14",
        "2025-05-15",
        "2025-05-20",
        "2025-05-21",
        "2025-05-22",
        "2025-05-23",
        "2025-05-24",
        "2025-05-25"
      ]
    }
  };

  int calculatedCurrentStreak = 0;
  int calculatedMaxStreak = 0;
  String today = '';
  String yesterday = '';
  String lastActiveDate = '';
  bool shouldHaveStreak = false;

  @override
  void initState() {
    super.initState();
    _analyzeStreak();
  }

  void _analyzeStreak() {
    // Lấy ngày hiện tại và hôm qua
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    this.today = _formatDate(now);
    this.yesterday = _formatDate(yesterday);

    // Lấy danh sách ngày hoạt động từ API
    final List<String> activeDates =
        List<String>.from(apiResponse['data']['activeDates']);

    // Sắp xếp theo thứ tự tăng dần
    activeDates.sort();

    // Lấy ngày hoạt động gần nhất
    if (activeDates.isNotEmpty) {
      lastActiveDate = activeDates.last;
    }

    // Kiểm tra xem có nên có streak không
    shouldHaveStreak = lastActiveDate == today || lastActiveDate == yesterday;

    // Tính currentStreak
    calculatedCurrentStreak = _calculateCurrentStreak(activeDates);

    // Tính maxStreak
    calculatedMaxStreak = _calculateMaxStreak(activeDates);
  }

  int _calculateCurrentStreak(List<String> activeDates) {
    if (activeDates.isEmpty) return 0;

    // Sắp xếp theo thứ tự giảm dần để bắt đầu từ ngày gần nhất
    activeDates.sort((a, b) => b.compareTo(a));

    // Kiểm tra xem ngày gần nhất có phải là hôm nay hoặc hôm qua không
    if (activeDates[0] != today && activeDates[0] != yesterday) {
      return 0; // Nếu không phải, chuỗi đã bị đứt
    }

    // Đếm số ngày liên tiếp
    int streak = 1;
    DateTime currentDate = DateTime.parse(activeDates[0]);

    for (int i = 1; i < activeDates.length; i++) {
      DateTime prevDate = DateTime.parse(activeDates[i]);

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

  int _calculateMaxStreak(List<String> activeDates) {
    if (activeDates.isEmpty) return 0;

    // Sắp xếp theo thứ tự tăng dần
    activeDates.sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < activeDates.length; i++) {
      DateTime currentDate = DateTime.parse(activeDates[i]);
      DateTime prevDate = DateTime.parse(activeDates[i - 1]);

      // Tính số ngày chênh lệch
      int dayDiff = currentDate.difference(prevDate).inDays;

      if (dayDiff == 1) {
        // Nếu là ngày liên tiếp, tăng streak hiện tại
        currentStreak++;
        // Cập nhật max streak nếu cần
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (dayDiff > 1) {
        // Nếu có khoảng cách, reset streak
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày hiện tại: $today',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Ngày hôm qua: $yesterday',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Dữ liệu từ API:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('currentStreak: ${apiResponse['data']['currentStreak']}'),
            Text('maxStreak: ${apiResponse['data']['maxStreak']}'),
            Text('Ngày hoạt động gần nhất: $lastActiveDate'),
            const SizedBox(height: 8),
            const Text('Phân tích:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Nên có streak: $shouldHaveStreak'),
            Text('currentStreak tính toán: $calculatedCurrentStreak'),
            Text('maxStreak tính toán: $calculatedMaxStreak'),
            const SizedBox(height: 16),
            const Text('Danh sách ngày hoạt động:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate(
              apiResponse['data']['activeDates'].length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                    '${index + 1}. ${apiResponse['data']['activeDates'][index]}'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _analyzeStreak();
                });
              },
              child: const Text('Phân tích lại'),
            ),
          ],
        ),
      ),
    );
  }
}
