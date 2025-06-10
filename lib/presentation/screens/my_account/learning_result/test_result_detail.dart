import 'package:flutter/material.dart';
import 'package:tms_app/data/models/my_test/test_result_detail_model.dart';
import 'package:tms_app/data/models/my_test/test_answer_model.dart';
import 'package:tms_app/domain/usecases/my_test/my_test_list_usecase.dart';
import 'package:get_it/get_it.dart';

class TestResultDetailScreen extends StatefulWidget {
  final int testId;
  final int accountId;
  final String testTitle;

  const TestResultDetailScreen({
    Key? key,
    required this.testId,
    required this.accountId,
    required this.testTitle,
  }) : super(key: key);

  @override
  State<TestResultDetailScreen> createState() => _TestResultDetailScreenState();
}

class _TestResultDetailScreenState extends State<TestResultDetailScreen> {
  final MyTestListUseCase _myTestListUseCase = GetIt.instance<MyTestListUseCase>();

  bool _isLoading = false;
  String _errorMessage = '';
  List<TestResultDetail> _testResults = [];

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _myTestListUseCase.getTestResultsByTest(
        widget.testId,
        accountId: widget.accountId,
      );

      setState(() {
        _testResults = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu chi tiết bài thi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết kết quả: ${widget.testTitle}",
          style: const TextStyle(
            fontSize: 18,
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (_testResults.isEmpty) {
      return const Center(
        child: Text('Không có kết quả bài thi nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTestResults,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testResults.length,
        itemBuilder: (context, index) {
          final result = _testResults[index];
          return _buildTestResultDetailCard(result);
        },
      ),
    );
  }

  Widget _buildTestResultDetailCard(TestResultDetail result) {
    // Tính toán tỷ lệ đúng
    final correctPercentage = result.correctPercentage;
    
    // Định dạng thời gian
    final completedAt = result.completedAt;
    final formattedDate = '${completedAt.day}/${completedAt.month}/${completedAt.year}';
    final formattedTime = '${completedAt.hour}:${completedAt.minute.toString().padLeft(2, '0')}';

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
                    "Mã thi #${result.id}",
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
                    color: result.result == "Pass"
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.result == "Pass" ? "Đạt" : "Không đạt",
                    style: TextStyle(
                      color: result.result == "Pass"
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
                _buildCircularProgress(correctPercentage),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Điểm số:", "${result.score}"),
                      _buildInfoRow("Ngày thi:", formattedDate),
                      _buildInfoRow("Giờ thi:", formattedTime),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildProgressRow("Câu đúng:", "${result.correctAnswers} / ${result.totalQuestions}"),
            const SizedBox(height: 8),
            _buildProgressRow("Câu sai:", "${result.incorrectAnswers} / ${result.totalQuestions}"),
            const SizedBox(height: 8),
            _buildProgressRow("Chưa làm:", "${result.totalQuestions - result.correctAnswers - result.incorrectAnswers} / ${result.totalQuestions}"),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _viewTestAnswerDetails(result);
              },
              icon: const Icon(Icons.article_outlined, size: 18),
              label: const Text("Xem chi tiết từng câu"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to view test answer details
  Future<void> _viewTestAnswerDetails(TestResultDetail result) async {
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Gọi API để lấy chi tiết câu trả lời
      final response = await _myTestListUseCase.getTestAnswers(
        accountId: widget.accountId,
        testId: widget.testId,
        testResultId: result.id,
      );

      // Đóng dialog loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Kiểm tra nếu không có dữ liệu hoặc danh sách trống
      if (!context.mounted || response.data.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có dữ liệu chi tiết câu trả lời'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Hiển thị chi tiết câu trả lời
      if (!mounted) return;
      
      // Navigate to test answer detail screen or show dialog
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _buildTestAnswerDetails(response.data),
      );

    } catch (e) {
      // Đóng dialog loading nếu context vẫn còn
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Hiển thị thông báo lỗi
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải chi tiết câu trả lời: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget hiển thị chi tiết câu trả lời
  Widget _buildTestAnswerDetails(List<TestAnswer> answers) {
    try {
      // Filter out any problematic answers
      final validAnswers = answers.where((answer) => 
        answer.question.isNotEmpty && 
        answer.options.isNotEmpty).toList();
      
      // Calculate stats based on valid answers
      final stats = _myTestListUseCase.evaluateTestAnswers(validAnswers);
      final correctCount = stats['correctCount'] as int;
      final totalQuestions = stats['totalQuestions'] as int;
      final correctRate = stats['correctRate'] as double;

      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chi tiết câu trả lời',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Số câu đúng: $correctCount/$totalQuestions (${correctRate.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // List câu trả lời
              Expanded(
                child: validAnswers.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, 
                          size: 64, 
                          color: Colors.orange.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có dữ liệu chi tiết câu trả lời',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: validAnswers.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final answer = validAnswers[index];
                      return _buildAnswerItem(answer, index);
                    },
                  ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error building test answer details: $e');
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Không thể hiển thị chi tiết câu trả lời',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Widget hiển thị một câu trả lời
  Widget _buildAnswerItem(TestAnswer answer, int index) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Số thứ tự và trạng thái đúng/sai
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: answer.isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                answer.isCorrect ? 'Đúng' : 'Sai',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: answer.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          
          // Câu hỏi
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 8, bottom: 16),
            child: Text(
              answer.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Các lựa chọn
          ...List.generate(
            answer.options.length,
            (i) {
              try {
                // Xác định label cho các lựa chọn (A, B, C, D...)
                final optionLabel = String.fromCharCode(65 + i);
                
                // Kiểm tra xem lựa chọn này có phải đáp án đúng không
                final isCorrectOption = answer.correctAnswer.isNotEmpty && 
                    optionLabel == answer.correctAnswer;
                
                // Kiểm tra xem người dùng có chọn lựa chọn này không
                final isUserChoice = answer.userAnswer.isNotEmpty && 
                    optionLabel == answer.userAnswer;
                
                // Xác định màu nền cho lựa chọn
                Color? backgroundColor;
                if (isCorrectOption) {
                  backgroundColor = Colors.green.withOpacity(0.1);
                } else if (isUserChoice) {
                  backgroundColor = Colors.red.withOpacity(0.1);
                }
                
                return Container(
                  margin: const EdgeInsets.only(left: 32, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrectOption
                          ? Colors.green
                          : isUserChoice
                              ? Colors.red
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCorrectOption
                                ? Colors.green
                                : isUserChoice
                                    ? Colors.red
                                    : Colors.grey.shade500,
                          ),
                          color: isUserChoice ? Colors.white : null,
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCorrectOption
                                  ? Colors.green
                                  : isUserChoice
                                      ? Colors.red
                                      : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          answer.options[i],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                // Xử lý lỗi khi hiển thị lựa chọn
                print('Error displaying option $i: $e');
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      );
    } catch (e) {
      // Xử lý lỗi khi hiển thị câu trả lời
      print('Error displaying answer $index: $e');
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'Không thể hiển thị chi tiết câu hỏi này',
          style: TextStyle(color: Colors.orange),
        ),
      );
    }
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