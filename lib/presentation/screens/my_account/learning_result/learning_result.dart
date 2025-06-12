import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/my_account/learning_result/course_result.dart';
import 'package:tms_app/presentation/screens/my_account/learning_result/test_result_detail.dart';
import 'package:tms_app/data/models/my_test/test_result_model.dart';
import 'package:tms_app/domain/usecases/my_test/my_test_list_usecase.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'certificate.dart';
import 'package:tms_app/domain/usecases/my_course/content_test_usecase.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/take_test.dart';

class LearningResultScreen extends StatefulWidget {
  const LearningResultScreen({Key? key}) : super(key: key);

  @override
  State<LearningResultScreen> createState() => _LearningResultScreenState();
}

class _LearningResultScreenState extends State<LearningResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MyTestListUseCase _myTestListUseCase = GetIt.instance<MyTestListUseCase>();
  final ContentTestUseCase _contentTestUseCase = GetIt.instance<ContentTestUseCase>();
  
  // Trạng thái cho tab kết quả bài thi
  bool _isLoadingTestResults = false;
  TestResultPaginatedData? _testResultData;
  List<TestResultItem>? _testResultItems;
  String _errorMessage = '';
  int _accountId = 8; // ID mặc định, thay thế bằng ID thực từ hệ thống
  
  // Biến state kiểm soát việc sắp xếp
  bool _isSortedByCompletion = false;

  // Biến state để vô hiệu hóa nút khi đang làm lại bài thi
  bool _isLoadingRetryTest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTestResults();
    
    // Lắng nghe sự kiện thay đổi tab để tải lại dữ liệu nếu cần
    _tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    if (_tabController.index == 1 && _testResultItems == null && !_isLoadingTestResults) {
      _fetchTestResults();
    }
  }

  // Lấy dữ liệu kết quả bài thi từ API
  Future<void> _fetchTestResults() async {
    if (_isLoadingTestResults) return;
    
    setState(() {
      _isLoadingTestResults = true;
      _errorMessage = '';
    });
    
    try {
      final result = await _myTestListUseCase.getTestResultsByAccountExam(
        _accountId,
        page: 0,
        size: 20,
      );
      
      setState(() {
        _testResultData = result;
        _testResultItems = List<TestResultItem>.from(result.content);
        _isLoadingTestResults = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu kết quả bài thi: $e';
        _isLoadingTestResults = false;
      });
    }
  }
  
  // Xem chi tiết kết quả thi
  void _viewTestResultDetails(TestResultItem result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultDetailScreen(
          testId: result.testId,
          accountId: _accountId,
          testTitle: result.testTitle,
        ),
      ),
    );
  }
  
  // Sắp xếp kết quả bài thi theo phần trăm hoàn thành
  void _sortByCompletion() {
    if (_testResultData == null) return;
    
    setState(() {
      _isSortedByCompletion = !_isSortedByCompletion;
      
      if (_isSortedByCompletion) {
        // Sử dụng phương thức từ UseCase để sắp xếp
        _testResultItems = _myTestListUseCase.sortTestResultsByCompletion(_testResultData!);
      } else {
        // Khôi phục thứ tự ban đầu
        _testResultItems = List<TestResultItem>.from(_testResultData!.content);
      }
    });
  }

  // Phương thức để làm lại bài thi
  Future<void> _retryTest(TestResultItem result) async {
    // Hiển thị hộp thoại xác nhận
    final bool startTest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          result.testTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn làm lại bài kiểm tra này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    ) ?? false;

    if (!startTest || !mounted) return;

    // Bắt đầu lấy nội dung bài kiểm tra
    setState(() {
      _isLoadingRetryTest = true;
    });

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );

    try {
      // Lấy nội dung bài kiểm tra từ API
      final contentTest = await _contentTestUseCase.getContentTest(result.testId);

      // Đóng dialog loading
      if (mounted) Navigator.pop(context);

      // Điều hướng đến màn hình làm bài kiểm tra
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakeTestScreen(
              contentTest: contentTest,
              contentTestUseCase: _contentTestUseCase,
              onTestCompleted: (score) {
                // Callback khi hoàn thành bài kiểm tra
                debugPrint('Làm lại bài thi, điểm số: $score');
                // Tải lại danh sách kết quả
                _fetchTestResults();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Đóng dialog loading
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải nội dung bài kiểm tra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRetryTest = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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
    // Hiển thị loading khi đang tải dữ liệu
    if (_isLoadingTestResults) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Hiển thị thông báo lỗi nếu có
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTestResults,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    // Hiển thị thông báo nếu không có dữ liệu
    if (_testResultItems == null || _testResultItems!.isEmpty) {
      return const Center(
        child: Text('Không có kết quả bài thi nào'),
      );
    }

    // Danh sách kết quả bài thi
    return RefreshIndicator(
      onRefresh: _fetchTestResults,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testResultItems!.length,
        itemBuilder: (context, index) {
          final result = _testResultItems![index];
          return _buildTestResultCard(result);
        },
      ),
    );
  }
  
  Widget _buildTestResultCard(TestResultItem result) {
    // Tính toán trạng thái đạt/không đạt dựa vào hoàn thành
    final bool isPassed = result.completedPercentage >= 50;
    final String status = isPassed ? 'Đạt' : 'Không đạt';
    
    // Format ngày tháng
    final dateTime = result.createdAt;
    final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    
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
                    result.testTitle,
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
                _buildCircularProgress(result.completedPercentage),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Điểm số:", "${result.maxScore}"),
                      _buildInfoRow("Ngày thi:", formattedDate),
                      _buildInfoRow("Mã bài thi:", "#${result.testResultId}"),
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
                  onPressed: () => _viewTestResultDetails(result),
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
                  onPressed: _isLoadingRetryTest ? null : () => _retryTest(result),
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
