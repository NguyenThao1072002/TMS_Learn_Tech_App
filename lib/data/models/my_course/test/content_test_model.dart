// Mô hình dữ liệu cho nội dung bài kiểm tra
// API: /api/questions/test-mobile/{testId}

import 'package:equatable/equatable.dart';

// Mô hình chính cho nội dung bài kiểm tra
class ContentTestModel extends Equatable {
  final int testId;
  final String testTitle;
  final String? lessonTitle;
  final String? description;
  final int totalQuestion;
  final String
      type; // Các loại câu hỏi trong bài kiểm tra (multiple-choice, essay, fill-in-the-blank, checkbox)
  final int duration; // Thời gian làm bài (giây)
  final String format; // Định dạng: "exam" hoặc "test"
  final bool isChapterTest; // Bài kiểm tra chương hay bài kiểm tra thường
  final int courseId;
  final int? lessonId;
  final List<QuestionModel> questionList;

  const ContentTestModel({
    required this.testId,
    required this.testTitle,
    this.lessonTitle,
    this.description,
    required this.totalQuestion,
    required this.type,
    required this.duration,
    required this.format,
    required this.isChapterTest,
    required this.courseId,
    this.lessonId,
    required this.questionList,
  });

  // Tạo từ JSON
  factory ContentTestModel.fromJson(Map<String, dynamic> json) {
    return ContentTestModel(
      testId: json['testId'] as int,
      testTitle: json['testTitle'] as String,
      lessonTitle: json['lessonTitle'] as String?,
      description: json['description'] as String?,
      totalQuestion: json['totalQuestion'] as int,
      type: json['type'] as String,
      duration: json['duration'] as int,
      format: json['format'] as String,
      isChapterTest: json['isChapterTest'] as bool,
      courseId: json['courseId'] as int,
      lessonId: json['lessonId'] as int?,
      questionList: (json['questionList'] as List<dynamic>)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testTitle': testTitle,
      'lessonTitle': lessonTitle,
      'description': description,
      'totalQuestion': totalQuestion,
      'type': type,
      'duration': duration,
      'format': format,
      'isChapterTest': isChapterTest,
      'courseId': courseId,
      'lessonId': lessonId,
      'questionList': questionList.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        testId,
        testTitle,
        lessonTitle,
        description,
        totalQuestion,
        type,
        duration,
        format,
        isChapterTest,
        courseId,
        lessonId,
        questionList,
      ];
}

// Mô hình cho câu hỏi trong bài kiểm tra
class QuestionModel extends Equatable {
  final int questionId;
  final String content; // Nội dung câu hỏi
  final String? optionA; // Lựa chọn A (null với essay)
  final String? optionB; // Lựa chọn B (null với essay)
  final String? optionC; // Lựa chọn C (null với essay)
  final String? optionD; // Lựa chọn D (null với essay)
  final String? result; // Kết quả hiển thị
  final String? resultCheck; // Kết quả để kiểm tra đáp án
  final String? instruction; // Hướng dẫn có thể null
  final String level; // Độ khó (1: dễ, 2: trung bình, 3: khó)
  final String
      type; // Loại câu hỏi (multiple-choice, essay, fill-in-the-blank, checkbox)
  final String topic; // Chủ đề câu hỏi
  final int courseId; // ID khóa học
  final int accountId; // ID giáo viên

  const QuestionModel({
    required this.questionId,
    required this.content,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.result,
    this.resultCheck,
    this.instruction, // Không bắt buộc phải có giá trị
    required this.level,
    required this.type,
    required this.topic,
    required this.courseId,
    required this.accountId,
  });

  // Tạo từ JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionId: json['questionId'] as int,
      content: json['content'] as String,
      optionA: json['optionA'] as String?,
      optionB: json['optionB'] as String?,
      optionC: json['optionC'] as String?,
      optionD: json['optionD'] as String?,
      result: json['result'] as String?,
      resultCheck: json['resultCheck'] as String?,
      instruction: json['instruction'] as String?, // Xử lý giá trị có thể null
      level: json['level'] as String,
      type: json['type'] as String,
      topic: json['topic'] as String,
      courseId: json['courseId'] as int,
      accountId: json['accountId'] as int,
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'content': content,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'result': result,
      'resultCheck': resultCheck,
      'instruction': instruction,
      'level': level,
      'type': type,
      'topic': topic,
      'courseId': courseId,
      'accountId': accountId,
    };
  }

  @override
  List<Object?> get props => [
        questionId,
        content,
        optionA,
        optionB,
        optionC,
        optionD,
        result,
        resultCheck,
        instruction,
        level,
        type,
        topic,
        courseId,
        accountId,
      ];
}

// Mô hình cho API response
class ContentTestResponse {
  final int status;
  final String message;
  final ContentTestModel data;

  ContentTestResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ContentTestResponse.fromJson(Map<String, dynamic> json) {
    return ContentTestResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: ContentTestModel.fromJson(json['data'] as Map<String, dynamic>),
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
