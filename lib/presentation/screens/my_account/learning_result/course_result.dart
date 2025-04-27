import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'certificate.dart';

class CourseResultDetailScreen extends StatefulWidget {
  final String courseName;
  final double completion;
  final double? score;
  final bool? hasCertificate;
  final String? completionDate;

  const CourseResultDetailScreen({
    Key? key,
    required this.courseName,
    required this.completion,
    this.score = 8.5, // Default value
    this.hasCertificate = false, // Default value
    this.completionDate,
  }) : super(key: key);

  @override
  State<CourseResultDetailScreen> createState() =>
      _CourseResultDetailScreenState();
}

class _CourseResultDetailScreenState extends State<CourseResultDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Dữ liệu mẫu cho biểu đồ tiến độ theo thời gian
  final List<Map<String, dynamic>> _progressData = [
    {'day': 'T2', 'progress': 10.0},
    {'day': 'T3', 'progress': 25.0},
    {'day': 'T4', 'progress': 40.0},
    {'day': 'T5', 'progress': 42.0},
    {'day': 'T6', 'progress': 50.0},
    {'day': 'T7', 'progress': 65.0},
    {'day': 'CN', 'progress': 85.0},
  ];

  // Dữ liệu mẫu cho kết quả kiểm tra
  final List<Map<String, dynamic>> _quizResults = [
    {
      'title': 'Kiểm tra chương 1',
      'date': '05/05/2023',
      'score': 8.5,
      'maxScore': 10.0,
      'status': 'Đạt',
    },
    {
      'title': 'Kiểm tra giữa kỳ',
      'date': '12/05/2023',
      'score': 7.8,
      'maxScore': 10.0,
      'status': 'Đạt',
    },
    {
      'title': 'Bài tập chương 3',
      'date': '18/05/2023',
      'score': 9.0,
      'maxScore': 10.0,
      'status': 'Đạt',
    },
    {
      'title': 'Kiểm tra cuối kỳ',
      'date': '22/05/2023',
      'score': 8.7,
      'maxScore': 10.0,
      'status': 'Đạt',
    },
  ];

  // Dữ liệu mẫu cho các buổi học
  final List<Map<String, dynamic>> _lessonCompletions = [
    {
      'title': 'Bài 1: Giới thiệu tổng quan',
      'duration': '45 phút',
      'date': '03/05/2023',
      'status': 'Hoàn thành',
    },
    {
      'title': 'Bài 2: Cài đặt môi trường',
      'duration': '60 phút',
      'date': '05/05/2023',
      'status': 'Hoàn thành',
    },
    {
      'title': 'Bài 3: Cấu trúc dự án',
      'duration': '90 phút',
      'date': '10/05/2023',
      'status': 'Hoàn thành',
    },
    {
      'title': 'Bài 4: Component cơ bản',
      'duration': '120 phút',
      'date': '15/05/2023',
      'status': 'Hoàn thành',
    },
    {
      'title': 'Bài 5: State và Props',
      'duration': '90 phút',
      'date': '18/05/2023',
      'status': 'Hoàn thành',
    },
    {
      'title': 'Bài 6: Quản lý State',
      'duration': '120 phút',
      'date': '20/05/2023',
      'status': 'Đang học',
    },
    {
      'title': 'Bài 7: Routing',
      'duration': '90 phút',
      'date': '',
      'status': 'Chưa học',
    },
    {
      'title': 'Bài 8: API và fetch dữ liệu',
      'duration': '120 phút',
      'date': '',
      'status': 'Chưa học',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _downloadCertificate() {
    // Chỉ cho phép tải nếu đã hoàn thành 100%
    if (widget.completion < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần hoàn thành 100% khóa học để tải chứng chỉ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sử dụng CertificateGenerator để tạo và hiển thị chứng chỉ
    CertificateGenerator.generateAndShow(
      context,
      userName: "Nguyễn Văn A", // Thay bằng tên người dùng thực tế từ hệ thống
      courseName: widget.courseName,
      completion: widget.completion,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          isScrollable: true,
          tabs: const [
            Tab(text: "Tổng quan"),
            Tab(text: "Bài kiểm tra"),
            Tab(text: "Nội dung học"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildQuizResultsTab(),
          _buildLessonsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 24),
          const Text(
            "Tiến độ học tập theo thời gian",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressChart(),
          const SizedBox(height: 24),
          const Text(
            "Điểm trung bình theo từng phần",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreRadarChart(),
          const SizedBox(height: 24),
          _buildCertificateSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.school,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.courseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Đăng ký: 01/05/2023",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              "Tiến độ hoàn thành:",
              "${widget.completion.toInt()}%",
              Colors.blue,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.completion / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.completion == 100 ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              "Điểm trung bình:",
              "${widget.score}/10",
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              "Thời gian học:",
              "12 giờ 30 phút",
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              "Tỷ lệ tham gia:",
              "90%",
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _progressData.length) {
                    return Text(
                      _progressData[value.toInt()]['day'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: _progressData.length - 1.0,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                _progressData.length,
                (index) => FlSpot(
                  index.toDouble(),
                  _progressData[index]['progress'],
                ),
              ),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRadarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Điểm theo từng kỹ năng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSkillScoreChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillScoreChart() {
    final skills = [
      {'name': 'Lý thuyết', 'score': 8.5},
      {'name': 'Bài tập', 'score': 7.5},
      {'name': 'Quiz', 'score': 9.2},
      {'name': 'Dự án', 'score': 8.8},
      {'name': 'Thuyết trình', 'score': 7.8},
    ];

    return ListView.builder(
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final score = skill['score'] as double;
        final percent = (score / 10) * 100;

        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 100, child: Text(skill['name'] as String)),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForScore(score),
                    ),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getColorForScore(score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 8.5) return Colors.green;
    if (score >= 7.0) return Colors.blue;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCertificateSection() {
    final canDownload = widget.completion == 100;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chứng chỉ khóa học",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: canDownload ? Colors.amber : Colors.grey,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canDownload
                            ? "Chứng chỉ đã sẵn sàng"
                            : "Hoàn thành khóa học để nhận chứng chỉ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              canDownload ? Colors.green : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        canDownload
                            ? "Bạn đã hoàn thành khóa học và đạt yêu cầu để nhận chứng chỉ"
                            : "Bạn cần hoàn thành 100% khóa học để nhận chứng chỉ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canDownload ? _downloadCertificate : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download, size: 18),
                label:
                    Text(canDownload ? "Tải chứng chỉ" : "Chưa đủ điều kiện"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canDownload ? Colors.green : Colors.grey,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (canDownload) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Hiển thị xem trước chứng chỉ
                    CertificateGenerator.generateAndShow(
                      context,
                      userName:
                          "Nguyễn Văn A", // Thay bằng tên người dùng thực tế từ hệ thống
                      courseName: widget.courseName,
                      completion: widget.completion,
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("Xem trước chứng chỉ"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResultsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizResults.length,
      itemBuilder: (context, index) {
        final quiz = _quizResults[index];
        final score = quiz['score'] as double;
        final maxScore = quiz['maxScore'] as double;
        final percentage = (score / maxScore) * 100;

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
                        quiz['title'] as String,
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
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quiz['status'] as String,
                        style: TextStyle(
                          color: Colors.green.shade800,
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
                          _buildInfoRow("Điểm số:",
                              "${score.toString()}/${maxScore.toString()}"),
                          _buildInfoRow("Ngày làm:", quiz['date'] as String),
                          _buildInfoRow("Thời gian:", "30 phút"),
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
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text("Xem lại bài làm"),
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
      },
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessonCompletions.length,
      itemBuilder: (context, index) {
        final lesson = _lessonCompletions[index];
        final status = lesson['status'] as String;

        Color statusColor;
        IconData statusIcon;

        switch (status) {
          case 'Hoàn thành':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'Đang học':
            statusColor = Colors.blue;
            statusIcon = Icons.play_circle_filled;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.lock;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: status == 'Chưa học' ? 1 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              lesson['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == 'Chưa học' ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      lesson['duration'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (status != 'Chưa học') ...[
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        lesson['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: status == 'Hoàn thành'
                ? IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {},
                  )
                : status == 'Đang học'
                    ? IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.blue),
                        onPressed: () {},
                      )
                    : null,
          ),
        );
      },
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
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            "${percentage.toInt()}%",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
