import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/my_account/learning_result/course_result.dart';
import 'certificate.dart';

class LearningResultScreen extends StatefulWidget {
  const LearningResultScreen({Key? key}) : super(key: key);

  @override
  State<LearningResultScreen> createState() => _LearningResultScreenState();
}

class _LearningResultScreenState extends State<LearningResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kết quả học tập",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: [
            _buildTab("Khóa học", Icons.school),
            _buildTab("Bài thi", Icons.quiz),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCourseResultTab(),
          _buildExamResultTab(),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseResultTab() {
    // Dữ liệu mẫu cho kết quả khóa học
    final courseResults = [
      {
        'name': 'Lập trình Flutter cơ bản',
        'completion': 85,
        'score': 8.5,
        'certificate': true,
        'completion_date': '22/05/2023',
      },
      {
        'name': 'Lập trình ReactJS',
        'completion': 100,
        'score': 9.2,
        'certificate': true,
        'completion_date': '15/04/2023',
      },
      {
        'name': 'Tiếng Anh giao tiếp',
        'completion': 65,
        'score': 7.0,
        'certificate': false,
        'completion_date': '30/05/2023',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseResults.length,
      itemBuilder: (context, index) {
        final course = courseResults[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày hoàn thành: ${course['completion_date'] as String}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (course['completion'] as int) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                course['completion'] == 100 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiến độ: ${course['completion']}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseResultDetailScreen(
                            courseName: course['name'] as String,
                            completion:
                                (course['completion'] as int).toDouble(),
                            completionDate: course['completion_date'] as String,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xem kết quả'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (course['completion'] as int) == 100
                        ? () {
                            // Mở trang chứng chỉ nếu khóa học đã hoàn thành
                            CertificateGenerator.generateAndShow(
                              context,
                              userName:
                                  "Nguyễn Văn A", // Thay bằng tên người dùng thực tế từ hệ thống
                              courseName: course['name'] as String,
                              completion: course['completion'] as int,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xem chứng chỉ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamResultTab() {
    // Dữ liệu mẫu cho kết quả bài thi
    final examResults = [
      {
        'examName': 'Đề kiểm tra giữa kỳ Flutter',
        'date': '10/05/2023',
        'score': 85,
        'maxScore': 100,
        'time': '45 phút',
        'status': 'Đạt',
      },
      {
        'examName': 'Bài thi ReactJS',
        'date': '02/04/2023',
        'score': 92,
        'maxScore': 100,
        'time': '60 phút',
        'status': 'Đạt',
      },
      {
        'examName': 'Bài thi TOEIC 4 kỹ năng',
        'date': '25/05/2023',
        'score': 650,
        'maxScore': 990,
        'time': '120 phút',
        'status': 'Đạt',
      },
      {
        'examName': 'Kiểm tra JavaScript cơ bản',
        'date': '15/03/2023',
        'score': 65,
        'maxScore': 100,
        'time': '30 phút',
        'status': 'Không đạt',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: examResults.length,
      itemBuilder: (context, index) {
        final exam = examResults[index];
        return _buildExamResultCard(
          examName: exam['examName'] as String,
          date: exam['date'] as String,
          score: exam['score'] as int,
          maxScore: exam['maxScore'] as int,
          time: exam['time'] as String,
          status: exam['status'] as String,
        );
      },
    );
  }

  Widget _buildExamResultCard({
    required String examName,
    required String date,
    required int score,
    required int maxScore,
    required String time,
    required String status,
  }) {
    final bool isPassed = status == 'Đạt';
    final double percentage = score / maxScore * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    examName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPassed ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isPassed
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCircularProgress(percentage),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Điểm số:", "$score/$maxScore"),
                      _buildInfoRow("Ngày thi:", date),
                      _buildInfoRow("Thời gian:", time),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: const Text("Chi tiết"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Làm lại"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double percentage) {
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 60
            ? Colors.blue
            : Colors.orange;

    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            "${percentage.toInt()}%",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
