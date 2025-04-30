import 'dart:async';
import 'package:flutter/material.dart';

enum QuestionType {
  multipleChoice,
  checkboxes,
  fillInBlank,
  essay,
}

class TestQuestion {
  final String questionText;
  final QuestionType type;
  final List<String> options;
  final dynamic
      correctAnswer; // Có thể là int, List<int>, hoặc String tùy theo loại câu hỏi
  final int points;

  TestQuestion({
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });
}

class TakeTestScreen extends StatefulWidget {
  final String testTitle;
  final int questionCount;
  final int timeInMinutes;
  final List<TestQuestion> questions;

  const TakeTestScreen({
    Key? key,
    required this.testTitle,
    required this.questionCount,
    required this.timeInMinutes,
    required this.questions,
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
    _timeRemaining = widget.timeInMinutes * 60;

    // Khởi tạo danh sách câu trả lời trống
    _userAnswers = List<dynamic>.filled(widget.questions.length, null);

    // Bắt đầu đếm ngược thời gian
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Hàm bắt đầu đếm ngược thời gian
  void _startTimer() {
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
    double totalPoints = 0;
    double earnedPoints = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final userAnswer = _userAnswers[i];

      // Lấy điểm tối đa của câu hỏi
      final double maxPoints = question.points.toDouble();
      totalPoints += maxPoints;

      // Kiểm tra câu trả lời dựa vào loại câu hỏi
      switch (question.type) {
        case QuestionType.multipleChoice:
          if (userAnswer == question.correctAnswer) {
            earnedPoints += maxPoints;
          }
          break;

        case QuestionType.checkboxes:
          final correctAnswers = question.correctAnswer as List;
          if (userAnswer != null && userAnswer is List) {
            // Nếu tất cả các lựa chọn đều đúng
            if (userAnswer.length == correctAnswers.length &&
                correctAnswers.every((item) => userAnswer.contains(item))) {
              earnedPoints += maxPoints;
            }
            // Điểm một phần nếu đúng một số
            else if (userAnswer.isNotEmpty) {
              int correctCount = 0;
              for (var answer in userAnswer) {
                if (correctAnswers.contains(answer)) {
                  correctCount++;
                }
              }
              earnedPoints +=
                  maxPoints * (correctCount / correctAnswers.length);
            }
          }
          break;

        case QuestionType.fillInBlank:
          final correctAnswer =
              question.correctAnswer.toString().trim().toLowerCase();
          if (userAnswer != null &&
              userAnswer.toString().trim().toLowerCase() == correctAnswer) {
            earnedPoints += maxPoints;
          }
          break;

        case QuestionType.essay:
          // Điểm tự luận sẽ được chấm sau
          // Tạm tính điểm dựa vào độ dài câu trả lời
          if (userAnswer != null && userAnswer.toString().trim().length > 20) {
            earnedPoints += maxPoints * 0.7; // Tạm tính 70% điểm
          }
          break;
      }
    }

    // Tính điểm trên thang điểm 10
    _score = earnedPoints / totalPoints * 10;
  }

  // Hiển thị dialog kết quả
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả bài kiểm tra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _score >= 5
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${_score.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _score >= 5 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _score >= 5
                  ? 'Chúc mừng! Bạn đã vượt qua bài kiểm tra.'
                  : 'Bạn chưa vượt qua bài kiểm tra.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _score >= 5 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết quả: ${_score.toStringAsFixed(1)}/10 điểm',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Số câu đúng: ${_getCorrectAnswersCount()}/${widget.questions.length}',
            ),
            const SizedBox(height: 8),
            Text(
              'Thời gian làm bài: ${widget.timeInMinutes - (_timeRemaining / 60).floor()} phút',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(
                  context, _score); // Trở về màn hình trước với kết quả
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              // Hiển thị chi tiết bài làm
              _showDetailedResults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }

  // Đếm số câu đúng
  int _getCorrectAnswersCount() {
    int count = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final userAnswer = _userAnswers[i];

      switch (question.type) {
        case QuestionType.multipleChoice:
          if (userAnswer == question.correctAnswer) {
            count++;
          }
          break;

        case QuestionType.checkboxes:
          final correctAnswers = question.correctAnswer as List;
          if (userAnswer != null && userAnswer is List) {
            if (userAnswer.length == correctAnswers.length &&
                correctAnswers.every((item) => userAnswer.contains(item))) {
              count++;
            }
          }
          break;

        case QuestionType.fillInBlank:
          final correctAnswer =
              question.correctAnswer.toString().trim().toLowerCase();
          if (userAnswer != null &&
              userAnswer.toString().trim().toLowerCase() == correctAnswer) {
            count++;
          }
          break;

        case QuestionType.essay:
          // Bỏ qua câu tự luận khi đếm
          break;
      }
    }

    return count;
  }

  // Hiển thị chi tiết kết quả
  void _showDetailedResults() {
    // Trong thực tế sẽ điều hướng đến một màn hình khác
    // Đây chỉ là mô phỏng
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng xem chi tiết đang được phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Định dạng thời gian còn lại
  String get _formattedTimeRemaining {
    final minutes = (_timeRemaining / 60).floor();
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Chuyển đến câu hỏi tiếp theo
  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  // Trở về câu hỏi trước
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Lưu câu trả lời của người dùng
  void _saveAnswer(dynamic answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.testTitle,
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
          // Thông tin bài thi
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Số câu hiện tại / tổng số câu
                Text(
                  'Câu ${_currentQuestionIndex + 1}/${widget.questions.length}',
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
          ),

          // Nội dung câu hỏi
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nội dung câu hỏi
                    _buildQuestionContent(
                        widget.questions[_currentQuestionIndex]),
                  ],
                ),
              ),
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
                // Nút quay lại
                ElevatedButton.icon(
                  onPressed:
                      _currentQuestionIndex > 0 ? _previousQuestion : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Trước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                ),
                // Nút nộp bài
                if (_isSubmitted == false)
                  ElevatedButton(
                    onPressed: _submitTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Nộp bài'),
                  ),
                // Nút câu tiếp theo
                ElevatedButton.icon(
                  onPressed: _currentQuestionIndex < widget.questions.length - 1
                      ? _nextQuestion
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Tiếp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng nội dung câu hỏi
  Widget _buildQuestionContent(TestQuestion question) {
    // Lấy thông tin câu hỏi
    final questionText = question.questionText;
    final questionType = question.type;
    final pointsValue = question.points.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề câu hỏi với điểm
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Số thứ tự câu hỏi
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                    questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${pointsValue.toStringAsFixed(1)} điểm',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
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
        switch (questionType) {
          QuestionType.multipleChoice => _buildMultipleChoiceQuestion(question),
          QuestionType.checkboxes => _buildCheckboxQuestion(question),
          QuestionType.fillInBlank => _buildFillBlankQuestion(question),
          QuestionType.essay => _buildEssayQuestion(question),
          _ => const Text('Loại câu hỏi không hỗ trợ'),
        },
      ],
    );
  }

  // Xây dựng câu hỏi trắc nghiệm (chọn 1 đáp án)
  Widget _buildMultipleChoiceQuestion(TestQuestion question) {
    final options = question.options;
    final currentAnswer = _userAnswers[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn một đáp án đúng:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          final optionValue = option;
          final optionText = option;

          return RadioListTile<dynamic>(
            value: optionValue,
            groupValue: currentAnswer,
            title: Text(optionText),
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
              ),
            ),
            tileColor: currentAnswer == optionValue
                ? Colors.orange.withOpacity(0.1)
                : Colors.grey[50],
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  // Xây dựng câu hỏi checkbox (chọn nhiều đáp án)
  Widget _buildCheckboxQuestion(TestQuestion question) {
    final options = question.options;
    final currentAnswer = _userAnswers[_currentQuestionIndex] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn một hoặc nhiều đáp án đúng:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          final optionValue = option;
          final optionText = option;
          final isSelected =
              currentAnswer is List && currentAnswer.contains(optionValue);

          return CheckboxListTile(
            value: isSelected,
            title: Text(optionText),
            onChanged: _isSubmitted
                ? null
                : (bool? checked) {
                    if (checked == true) {
                      final newAnswer = List<dynamic>.from(currentAnswer);
                      newAnswer.add(optionValue);
                      _saveAnswer(newAnswer);
                    } else {
                      final newAnswer = List<dynamic>.from(currentAnswer);
                      newAnswer.remove(optionValue);
                      _saveAnswer(newAnswer);
                    }
                  },
            activeColor: Colors.orange,
            checkColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
              ),
            ),
            tileColor:
                isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[50],
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  // Xây dựng câu hỏi điền khuyết
  Widget _buildFillBlankQuestion(TestQuestion question) {
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điền vào ô trống:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: currentAnswer),
          decoration: InputDecoration(
            hintText: 'Nhập câu trả lời của bạn...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 1,
          enabled: !_isSubmitted,
          onChanged: (value) {
            _saveAnswer(value);
          },
        ),
      ],
    );
  }

  // Xây dựng câu hỏi tự luận
  Widget _buildEssayQuestion(TestQuestion question) {
    final currentAnswer = _userAnswers[_currentQuestionIndex] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trả lời câu hỏi:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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
              borderSide: const BorderSide(color: Colors.orange),
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
        ),
      ],
    );
  }
}
