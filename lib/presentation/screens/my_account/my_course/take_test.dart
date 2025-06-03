import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tms_app/data/models/my_course/test/content_test_model.dart';
import 'package:tms_app/domain/usecases/my_course/content_test_usecase.dart';

class TakeTestScreen extends StatefulWidget {
  final ContentTestModel contentTest;
  final ContentTestUseCase contentTestUseCase;
  final Function? onNextLesson; // Callback khi chuyển đến bài học tiếp theo
  final Function(double)?
      onTestCompleted; // Callback khi hoàn thành bài kiểm tra

  const TakeTestScreen({
    Key? key,
    required this.contentTest,
    required this.contentTestUseCase,
    this.onNextLesson,
    this.onTestCompleted,
  }) : super(key: key);

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  // Thời gian còn lại (tính bằng giây)
  late int _timeRemaining;
  Timer? _timer;

  // Câu hỏi hiện tại
  int _currentQuestionIndex = 0;

  // Controller cho PageView
  late PageController _pageController;

  // Lưu câu trả lời của người dùng
  late List<dynamic> _userAnswers;

  // Trạng thái đã nộp bài
  bool _isSubmitted = false;

  // Điểm số khi nộp bài
  double _score = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo thời gian còn lại từ phút sang giây
    _timeRemaining = widget.contentTest.duration;

    // Kiểm tra danh sách câu hỏi trước khi khởi tạo
    if (widget.contentTest.questionList.isEmpty) {
      _userAnswers = [];
      _isSubmitted = true; // Đánh dấu là đã nộp bài để tránh timer
      _timer?.cancel(); // Ngừng đếm ngược ngay lập tức
      return;
    }

    // Khởi tạo danh sách câu trả lời trống
    _userAnswers =
        List<dynamic>.filled(widget.contentTest.questionList.length, null);

    // Khởi tạo PageController với cấu hình cơ bản
    _pageController = PageController(initialPage: 0);

    // Bắt đầu đếm ngược thời gian
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Hàm bắt đầu đếm ngược thời gian
  void _startTimer() {
    // Không bắt đầu timer nếu danh sách câu hỏi trống
    if (widget.contentTest.questionList.isEmpty) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          if (!_isSubmitted) {
            _submitTest();
          }
        }
      });
    });
  }

  // Hàm nộp bài thi
  void _submitTest() {
    if (_isSubmitted) return;

    // Kiểm tra xem còn câu hỏi chưa trả lời không
    final unansweredCount = _userAnswers.where((a) => a == null).length;

    if (unansweredCount > 0) {
      // Tìm chỉ số của câu hỏi đầu tiên chưa được trả lời
      int firstUnansweredIndex = _userAnswers.indexOf(null);

      // Hiển thị dialog xác nhận nếu còn câu hỏi chưa trả lời
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận nộp bài',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Còn $unansweredCount câu chưa được trả lời.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nếu nộp bài bây giờ, các câu chưa trả lời sẽ bị tính là không có điểm.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn có muốn:',
              ),
            ],
          ),
          actions: [
            // Nút quay lại câu hỏi chưa làm đầu tiên
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Chuyển đến câu hỏi đầu tiên chưa làm
                setState(() {
                  _currentQuestionIndex = firstUnansweredIndex;
                });
                _pageController.jumpToPage(firstUnansweredIndex);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Quay lại làm tiếp'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),

            // Nút nộp bài ngay
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizeSubmission();
              },
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Nộp bài ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    } else {
      // Nếu đã trả lời hết, nộp bài ngay
      _finalizeSubmission();
    }
  }

  // Hoàn tất quá trình nộp bài sau khi đã xác nhận
  void _finalizeSubmission() {
    setState(() {
      _isSubmitted = true;
      _timer?.cancel();
      _calculateScore();
    });

    // Hiển thị kết quả
    _showResultDialog();
  }

  // Tính điểm bài thi
  void _calculateScore() {
    double totalPoints = widget.contentTest.questionList.length.toDouble();
    double earnedPoints = 0;

    for (int i = 0; i < widget.contentTest.questionList.length; i++) {
      final question = widget.contentTest.questionList[i];
      final userAnswer = _userAnswers[i];

      if (userAnswer == null) continue;

      // Kiểm tra câu trả lời dựa vào loại câu hỏi
      try {
        switch (question.type) {
          case 'multiple-choice':
            if (widget.contentTestUseCase
                .checkMultipleChoiceAnswer(question, userAnswer)) {
              earnedPoints += 1;
            }
            break;

          case 'checkbox':
            if (userAnswer is String &&
                widget.contentTestUseCase
                    .checkCheckboxAnswer(question, userAnswer)) {
              earnedPoints += 1;
            }
            break;

          case 'fill-in-the-blank':
            if (userAnswer is String &&
                widget.contentTestUseCase
                    .checkFillInTheBlankAnswer(question, userAnswer)) {
              earnedPoints += 1;
            }
            break;

          case 'essay':
            // Câu tự luận luôn được tính là đúng nếu có nội dung
            if (userAnswer is String && userAnswer.trim().isNotEmpty) {
              earnedPoints += 1;
            }
            break;
        }
      } catch (e) {
        // Xử lý ngoại lệ khi kiểm tra đáp án
        debugPrint('Lỗi khi kiểm tra đáp án: $e');
      }
    }

    // Tính điểm trên thang điểm 10
    _score = earnedPoints / totalPoints * 10;
  }

  // Hiển thị dialog kết quả
  void _showResultDialog() {
    final bool isPassed = _score >= 7.0; // Điểm đạt thường là 7.0/10
    final correctCount = _getCorrectAnswersCount();
    final totalQuestions = widget.contentTest.questionList.length;
    final correctPercentage = (correctCount / totalQuestions * 100).round();

    // Gọi callback khi hoàn thành bài kiểm tra
    if (widget.onTestCompleted != null) {
      debugPrint('📊 Gọi callback onTestCompleted với điểm: $_score');
      widget.onTestCompleted!(_score);
    } else {
      debugPrint('⚠️ Callback onTestCompleted chưa được cung cấp!');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.error,
              color: isPassed ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              isPassed ? 'Hoàn thành!' : 'Chưa đạt',
              style: TextStyle(
                color: isPassed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiển thị điểm số
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isPassed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_score.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(
                        '/10',
                        style: TextStyle(
                          fontSize: 16,
                          color: isPassed ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Thông báo kết quả
              Text(
                isPassed
                    ? 'Chúc mừng! Bạn đã vượt qua bài kiểm tra.'
                    : 'Bạn chưa vượt qua bài kiểm tra. Hãy xem lại bài học và thử lại.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),

              // Thông tin chi tiết
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildResultItem(
                      icon: Icons.question_answer,
                      label: 'Số câu đúng:',
                      value:
                          '$correctCount/$totalQuestions ($correctPercentage%)',
                    ),
                    const Divider(),
                    _buildResultItem(
                      icon: Icons.timer,
                      label: 'Thời gian làm bài:',
                      value: _formatTimeUsed(),
                    ),
                    const Divider(),
                    _buildResultItem(
                      icon: Icons.psychology,
                      label: 'Mức độ bài kiểm tra:',
                      value: widget.contentTest.isChapterTest
                          ? 'Kiểm tra chương'
                          : (widget.contentTest.type.contains('essay')
                              ? 'Tự luận'
                              : 'Trắc nghiệm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Nút trở về bài học hiện tại
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(
                  context, _score); // Trở về màn hình trước với kết quả
            },
            child: const Text('Trở về bài học'),
          ),

          // Nút xem chi tiết kết quả
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              // Hiển thị chi tiết bài làm
              _showDetailedResults();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Xem chi tiết'),
          ),

          // Nút chuyển đến bài học tiếp theo - chỉ hiển thị khi đạt đủ điểm
          if (isPassed)
            ElevatedButton(
              onPressed: () {
                // Gọi phương thức để chuyển đến bài học tiếp theo trước
                _navigateToNextLesson();

                // Sau đó đóng dialog và trở về màn hình trước
                Navigator.pop(context); // Đóng dialog
                Navigator.pop(
                    context, _score); // Trở về màn hình trước với kết quả
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Bài học tiếp theo'),
            ),
        ],
      ),
    );
  }

  // Phương thức để chuyển đến bài học tiếp theo
  void _navigateToNextLesson() {
    debugPrint('🔄 _navigateToNextLesson được gọi');

    // Gọi callback để chuyển đến bài học tiếp theo nếu được cung cấp
    if (widget.onNextLesson != null) {
      debugPrint('✅ Gọi callback onNextLesson');
      widget.onNextLesson!();
    } else {
      debugPrint('❌ Callback onNextLesson chưa được cung cấp!');
    }
  }

  // Widget hiển thị mục thông tin trong bảng kết quả
  Widget _buildResultItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Đếm số câu đúng
  int _getCorrectAnswersCount() {
    int count = 0;
    for (int i = 0; i < widget.contentTest.questionList.length; i++) {
      final question = widget.contentTest.questionList[i];
      final userAnswer = _userAnswers[i];

      if (userAnswer == null) continue;

      try {
        switch (question.type) {
          case 'multiple-choice':
            if (widget.contentTestUseCase
                .checkMultipleChoiceAnswer(question, userAnswer)) {
              count++;
            }
            break;

          case 'checkbox':
            if (userAnswer is String &&
                widget.contentTestUseCase
                    .checkCheckboxAnswer(question, userAnswer)) {
              count++;
            }
            break;

          case 'fill-in-the-blank':
            if (userAnswer is String &&
                widget.contentTestUseCase
                    .checkFillInTheBlankAnswer(question, userAnswer)) {
              count++;
            }
            break;

          case 'essay':
            // Câu tự luận luôn được tính là đúng nếu có nội dung
            if (userAnswer is String && userAnswer.trim().isNotEmpty) {
              count++;
            }
            break;
        }
      } catch (e) {
        debugPrint('Lỗi khi đếm câu đúng: $e');
      }
    }
    return count;
  }

  // Hiển thị chi tiết kết quả
  void _showDetailedResults() {
    // Trong thực tế sẽ điều hướng đến một màn hình khác
    // Hiển thị danh sách câu hỏi với câu trả lời của người dùng và đáp án đúng
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Tiêu đề
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Chi tiết kết quả',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Danh sách câu hỏi
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: widget.contentTest.questionList.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final question = widget.contentTest.questionList[index];
                      final userAnswer = _userAnswers[index];
                      bool isCorrect = false;

                      try {
                        switch (question.type) {
                          case 'multiple-choice':
                            isCorrect = widget.contentTestUseCase
                                .checkMultipleChoiceAnswer(
                                    question, userAnswer);
                            break;
                          case 'checkbox':
                            isCorrect = userAnswer is String &&
                                widget.contentTestUseCase
                                    .checkCheckboxAnswer(question, userAnswer);
                            break;
                          case 'fill-in-the-blank':
                            isCorrect = userAnswer is String &&
                                widget.contentTestUseCase
                                    .checkFillInTheBlankAnswer(
                                        question, userAnswer);
                            break;
                          case 'essay':
                            // Tự luận không đánh giá đúng/sai
                            isCorrect = true;
                            break;
                        }
                      } catch (e) {
                        // Xử lý ngoại lệ
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: userAnswer == null
                              ? Colors.grey
                              : (isCorrect ? Colors.green : Colors.red),
                          child: Icon(
                            userAnswer == null
                                ? Icons.question_mark
                                : (isCorrect ? Icons.check : Icons.close),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Câu ${index + 1}: ${question.content.length > 50 ? question.content.substring(0, 50) + '...' : question.content}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: userAnswer == null
                            ? const Text('Không có câu trả lời',
                                style: TextStyle(color: Colors.grey))
                            : Text(
                                'Câu trả lời của bạn: $userAnswer',
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          // Hiển thị chi tiết câu hỏi và đáp án
                          _showQuestionDetail(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hiển thị chi tiết của một câu hỏi
  void _showQuestionDetail(int index) {
    final question = widget.contentTest.questionList[index];
    final userAnswer = _userAnswers[index];

    // Định dạng lại đáp án hiển thị dựa vào loại câu hỏi
    String formattedUserAnswer = '';
    String formattedCorrectAnswer = '';

    if (question.type == 'checkbox') {
      // Xử lý hiển thị đáp án cho câu hỏi checkbox
      if (userAnswer != null) {
        final selectedOptions = (userAnswer as String)
            .split('-')
            .where((e) => e.isNotEmpty)
            .toList();
        formattedUserAnswer = selectedOptions.join(', ');
      } else {
        formattedUserAnswer = 'Không có câu trả lời';
      }

      // Xử lý hiển thị đáp án đúng
      if (question.resultCheck != null) {
        final correctOptions = question.resultCheck!
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList();
        formattedCorrectAnswer = correctOptions.join(', ');
      } else {
        formattedCorrectAnswer = 'Không có đáp án';
      }
    } else {
      // Các loại câu hỏi khác
      formattedUserAnswer = userAnswer?.toString() ?? 'Không có câu trả lời';
      formattedCorrectAnswer = question.result ?? 'Không có đáp án';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Câu ${index + 1}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question.content,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Câu trả lời của bạn:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(formattedUserAnswer),
              ),
              const SizedBox(height: 16),
              const Text('Đáp án đúng:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(formattedCorrectAnswer),
              ),
              if (question.instruction != null &&
                  question.instruction!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Hướng dẫn:'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Text(question.instruction!),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Định dạng thời gian còn lại
  String get _formattedTimeRemaining {
    final minutes = (_timeRemaining / 60).floor();
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Hiển thị tổng thời gian bài kiểm tra theo định dạng phù hợp
  String get _formattedTotalTime {
    final minutes = (widget.contentTest.duration / 60).floor();
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}:${remainingMinutes.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:00';
    }
  }

  // Định dạng thời gian đã sử dụng để làm bài
  String _formatTimeUsed() {
    final totalSeconds = widget.contentTest.duration - _timeRemaining;
    final minutes = (totalSeconds / 60).floor();
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Chuyển đến câu hỏi tiếp theo
  void _nextQuestion() {
    debugPrint(
        '📌 _nextQuestion được gọi, chỉ số hiện tại: $_currentQuestionIndex');
    if (_currentQuestionIndex < widget.contentTest.questionList.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });

      // Cập nhật PageView - tách ra khỏi setState để đảm bảo hoạt động đúng
      _pageController.jumpToPage(_currentQuestionIndex);

      debugPrint('📌 Đã chuyển đến câu hỏi: $_currentQuestionIndex');
    }
  }

  // Trở về câu hỏi trước
  void _previousQuestion() {
    debugPrint(
        '📌 _previousQuestion được gọi, chỉ số hiện tại: $_currentQuestionIndex');
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });

      // Cập nhật PageView - tách ra khỏi setState để đảm bảo hoạt động đúng
      _pageController.jumpToPage(_currentQuestionIndex);

      debugPrint('📌 Đã chuyển đến câu hỏi: $_currentQuestionIndex');
    }
  }

  // Lưu câu trả lời của người dùng
  void _saveAnswer(dynamic answer) {
    debugPrint('💾 Lưu câu trả lời cho câu $_currentQuestionIndex: $answer');

    // Kiểm tra nếu giá trị không thay đổi thì không cần setState
    if (_userAnswers[_currentQuestionIndex] == answer) {
      return;
    }

    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });

    // Hiển thị số câu đã trả lời để debug
    int answeredCount = _userAnswers.where((a) => a != null).length;
    debugPrint(
        '💾 Tổng số câu đã trả lời: $answeredCount/${_userAnswers.length}');
  }

  // Hiển thị dialog xác nhận trước khi thoát
  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận thoát',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn thoát? Bài làm của bạn sẽ không được lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ở lại'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🔄 build được gọi, chỉ số câu hỏi hiện tại: $_currentQuestionIndex');

    // Kiểm tra danh sách câu hỏi trống
    if (widget.contentTest.questionList.isEmpty) {
      // Hiển thị thông báo nếu không có câu hỏi
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            widget.contentTest.testTitle,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không có câu hỏi trong bài kiểm tra này',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bài kiểm tra "${widget.contentTest.testTitle}" chưa có câu hỏi nào.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại bài học'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion =
        widget.contentTest.questionList[_currentQuestionIndex];
    debugPrint(
        '🔄 Hiển thị câu hỏi: ${currentQuestion.content.substring(0, min(30, currentQuestion.content.length))}...');

    return WillPopScope(
      onWillPop: () async {
        // Hiển thị xác nhận trước khi thoát nếu chưa nộp bài
        if (!_isSubmitted) {
          return await _showExitConfirmation();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            widget.contentTest.testTitle,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            // Hiển thị thời gian còn lại
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: _timeRemaining < 60
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: _timeRemaining < 60 ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTimeRemaining,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining < 60 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Thanh tiến trình câu hỏi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Thông tin câu hỏi hiện tại và tiến trình
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Số câu hiện tại / tổng số câu
                      Text(
                        'Câu ${_currentQuestionIndex + 1}/${widget.contentTest.questionList.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Thông tin đã trả lời / chưa trả lời
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Đã làm: ${_userAnswers.where((a) => a != null).length}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Chưa làm: ${_userAnswers.where((a) => a == null).length}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Thanh tiến trình
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) /
                          widget.contentTest.questionList.length,
                      backgroundColor: Colors.grey[200],
                      color: Colors.orange,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung câu hỏi
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Tắt vuốt ngang
                itemCount: widget.contentTest.questionList.length,
                onPageChanged: (index) {
                  debugPrint('🔄 PageView onPageChanged: $index');
                  if (_currentQuestionIndex != index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  final question = widget.contentTest.questionList[index];
                  return Container(
                    key: ValueKey('question_content_$index'),
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nội dung câu hỏi
                          _buildQuestionContent(question),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Điều hướng
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút quay lại - chỉ hiển thị icon
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          _currentQuestionIndex > 0 ? _previousQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nút nộp bài - cải thiện giao diện
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      onPressed: _isSubmitted ? null : _submitTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        elevation: 2,
                        shadowColor: Colors.green.withOpacity(0.5),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text('NỘP BÀI'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Nút câu tiếp theo - chỉ hiển thị icon
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentQuestionIndex <
                              widget.contentTest.questionList.length - 1
                          ? _nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                      child: const Icon(Icons.arrow_forward, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Xây dựng nội dung câu hỏi
  Widget _buildQuestionContent(QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề câu hỏi
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Số thứ tự câu hỏi
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _userAnswers[_currentQuestionIndex] != null
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  '${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nội dung câu hỏi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Loại câu hỏi và độ khó
                  Row(
                    children: [
                      _buildQuestionTypeChip(question.type),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(question.level)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mức độ: ${_getLevelText(question.level)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getDifficultyColor(question.level),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (question.instruction != null &&
                      question.instruction!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Hướng dẫn:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.instruction!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Phần câu trả lời tùy theo loại câu hỏi
        switch (question.type) {
          'multiple-choice' => _buildMultipleChoiceQuestion(question),
          'checkbox' => _buildCheckboxQuestion(question),
          'fill-in-the-blank' => _buildFillBlankQuestion(question),
          'essay' => _buildEssayQuestion(question),
          _ => const Text('Loại câu hỏi không hỗ trợ'),
        },
      ],
    );
  }

  // Widget hiển thị loại câu hỏi
  Widget _buildQuestionTypeChip(String type) {
    IconData icon;
    String label;
    Color color;

    switch (type) {
      case 'multiple-choice':
        icon = Icons.radio_button_checked;
        label = 'Trắc nghiệm';
        color = Colors.blue;
        break;
      case 'checkbox':
        icon = Icons.check_box;
        label = 'Nhiều đáp án';
        color = Colors.purple;
        break;
      case 'fill-in-the-blank':
        icon = Icons.text_fields;
        label = 'Điền khuyết';
        color = Colors.teal;
        break;
      case 'essay':
        icon = Icons.edit_note;
        label = 'Tự luận';
        color = Colors.deepOrange;
        break;
      default:
        icon = Icons.help;
        label = 'Không xác định';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Lấy màu dựa trên độ khó
  Color _getDifficultyColor(String level) {
    switch (level) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Chuyển đổi cấp độ từ số sang text
  String _getLevelText(String level) {
    switch (level) {
      case '1':
        return 'Dễ';
      case '2':
        return 'Trung bình';
      case '3':
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  // Xây dựng câu hỏi trắc nghiệm (chọn 1 đáp án)
  Widget _buildMultipleChoiceQuestion(QuestionModel question) {
    final options = [
      if (question.optionA != null) question.optionA!,
      if (question.optionB != null) question.optionB!,
      if (question.optionC != null) question.optionC!,
      if (question.optionD != null) question.optionD!,
    ];
    final optionLabels = ['A', 'B', 'C', 'D'];
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.radio_button_checked, size: 16, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Chọn một đáp án đúng:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (index) {
          final optionValue = optionLabels[index];
          final optionText = options[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              value: optionValue,
              groupValue: currentAnswer,
              title: Text('$optionValue. $optionText'),
              onChanged: _isSubmitted
                  ? null
                  : (value) {
                      _saveAnswer(value);
                    },
              activeColor: Colors.orange,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: currentAnswer == optionValue
                      ? Colors.orange
                      : Colors.grey[300]!,
                  width: currentAnswer == optionValue ? 2 : 1,
                ),
              ),
              tileColor: currentAnswer == optionValue
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey[50],
              dense: false,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
      ],
    );
  }

  // Xây dựng câu hỏi checkbox (chọn nhiều đáp án)
  Widget _buildCheckboxQuestion(QuestionModel question) {
    final options = [
      if (question.optionA != null) question.optionA!,
      if (question.optionB != null) question.optionB!,
      if (question.optionC != null) question.optionC!,
      if (question.optionD != null) question.optionD!,
    ];
    final optionLabels = ['1', '2', '3', '4'];
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String? ?? '';
    final selectedOptions =
        currentAnswer.split('-').where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_box, size: 16, color: Colors.purple),
            SizedBox(width: 8),
            Text(
              'Chọn một hoặc nhiều đáp án đúng:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (index) {
          final optionValue = optionLabels[index];
          final optionText = options[index];
          final isSelected = selectedOptions.contains(optionValue);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CheckboxListTile(
              value: isSelected,
              title: Text('$optionValue. $optionText'),
              onChanged: _isSubmitted
                  ? null
                  : (bool? checked) {
                      List<String> newSelectedOptions =
                          List.from(selectedOptions);

                      if (checked == true) {
                        if (!newSelectedOptions.contains(optionValue)) {
                          newSelectedOptions.add(optionValue);
                        }
                      } else {
                        newSelectedOptions.remove(optionValue);
                      }

                      // Sắp xếp các lựa chọn theo thứ tự và tạo chuỗi định dạng "1-2-3-4"
                      newSelectedOptions.sort();
                      _saveAnswer(newSelectedOptions.join('-'));
                    },
              activeColor: Colors.purple,
              checkColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.purple : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              tileColor:
                  isSelected ? Colors.purple.withOpacity(0.1) : Colors.grey[50],
              dense: false,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
      ],
    );
  }

  // Xây dựng câu hỏi điền khuyết
  Widget _buildFillBlankQuestion(QuestionModel question) {
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String? ?? '';
    final TextEditingController textController =
        TextEditingController(text: currentAnswer);

    // Đảm bảo vị trí con trỏ ở cuối văn bản
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.text_fields, size: 16, color: Colors.teal),
            SizedBox(width: 8),
            Text(
              'Điền vào ô trống:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hiển thị câu hỏi với định dạng rõ ràng hơn
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoàn thành câu sau:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                question.content,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Nhập câu trả lời của bạn...',
            labelText: 'Câu trả lời',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            prefixIcon: const Icon(Icons.edit, color: Colors.teal),
          ),
          maxLines: 1,
          enabled: !_isSubmitted,
          onChanged: (value) {
            _saveAnswer(value);
          },
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Text(
          'Lưu ý: Nhập chính xác cú pháp, chú ý các ký tự viết hoa/thường và dấu cách.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),

        // Hiển thị gợi ý nếu có
        if (question.instruction != null && question.instruction!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.instruction!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Xây dựng câu hỏi tự luận
  Widget _buildEssayQuestion(QuestionModel question) {
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit_note, size: 16, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text(
              'Trả lời câu hỏi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: currentAnswer),
          decoration: InputDecoration(
            hintText: 'Nhập câu trả lời chi tiết của bạn...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 8,
          minLines: 5,
          enabled: !_isSubmitted,
          onChanged: (value) {
            _saveAnswer(value);
          },
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        const Text(
          'Gợi ý: Viết chi tiết, đầy đủ và cung cấp ví dụ minh họa nếu có thể.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (currentAnswer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Độ dài: ${currentAnswer.length} ký tự',
              style: TextStyle(
                fontSize: 12,
                color: currentAnswer.length < 20 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
