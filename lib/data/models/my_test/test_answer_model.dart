/// Model đại diện cho phản hồi API từ lấy câu trả lời của một bài thi
class TestAnswerResponse {
  /// Danh sách câu trả lời
  final List<TestAnswer> data;

  TestAnswerResponse({
    required this.data,
  });

  /// Factory constructor để tạo TestAnswerResponse từ JSON
  factory TestAnswerResponse.fromJson(dynamic json) {
    // Kiểm tra nếu json là List<dynamic>
    if (json is List<dynamic>) {
      return TestAnswerResponse(
        data: json.map((item) => TestAnswer.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } 
    // Nếu json là Map<String, dynamic> chứa trường data
    else if (json is Map<String, dynamic> && json.containsKey('data')) {
      final dataList = json['data'] as List<dynamic>;
      
      return TestAnswerResponse(
        data: dataList.map((item) => TestAnswer.fromJson(item as Map<String, dynamic>)).toList(),
      );
    }
    // Trường hợp khác, trả về danh sách rỗng
    else {
      return TestAnswerResponse(data: []);
    }
  }

  /// Chuyển đổi TestAnswerResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model đại diện cho câu trả lời của một câu hỏi trong bài thi
class TestAnswer {
  /// ID của câu hỏi
  final int id;
  
  /// Nội dung câu hỏi
  final String question;
  
  /// Loại câu hỏi (ví dụ: multiple-choice)
  final String type;
  
  /// Các lựa chọn câu trả lời
  final List<String> options;
  
  /// Đáp án đúng
  final String correctAnswer;
  
  /// Câu trả lời của người dùng
  final String userAnswer;

  TestAnswer({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
  });

  /// Factory constructor để tạo TestAnswer từ JSON
  factory TestAnswer.fromJson(Map<String, dynamic> json) {
    // Xử lý danh sách các lựa chọn
    List<String> options = [];
    if (json['options'] != null) {
      options = (json['options'] as List<dynamic>).map((option) {
        return option?.toString() ?? '';
      }).toList();
    }

    return TestAnswer(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      type: json['type'] as String? ?? 'multiple-choice',
      options: options,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
    );
  }

  /// Chuyển đổi TestAnswer thành Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
    };
  }
  
  /// Kiểm tra xem người dùng đã trả lời đúng hay không
  bool get isCorrect => userAnswer == correctAnswer;
} 