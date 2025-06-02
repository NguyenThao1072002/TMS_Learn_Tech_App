import 'package:tms_app/data/models/my_course/test/content_test_model.dart';
import 'package:tms_app/domain/repositories/my_course/content_test_repository.dart';

/// UseCase xử lý các tác vụ liên quan đến nội dung bài kiểm tra
class ContentTestUseCase {
  final ContentTestRepository _contentTestRepository;

  ContentTestUseCase(this._contentTestRepository);

  /// Lấy nội dung bài kiểm tra theo testId
  ///
  /// [testId] là ID của bài kiểm tra cần lấy
  Future<ContentTestModel> getContentTest(int testId) async {
    return await _contentTestRepository.getContentTest(testId);
  }

  /// Kiểm tra loại câu hỏi
  ///
  /// Trả về true nếu câu hỏi thuộc loại được chỉ định
  bool isQuestionType(QuestionModel question, String type) {
    return question.type == type;
  }

  /// Lấy danh sách câu hỏi theo loại
  ///
  /// [contentTest] là nội dung bài kiểm tra
  /// [type] là loại câu hỏi cần lọc
  List<QuestionModel> getQuestionsByType(
      ContentTestModel contentTest, String type) {
    return contentTest.questionList
        .where((question) => question.type == type)
        .toList();
  }

  /// Lấy danh sách câu hỏi theo độ khó
  ///
  /// [contentTest] là nội dung bài kiểm tra
  /// [level] là độ khó cần lọc (1: dễ, 2: trung bình, 3: khó)
  List<QuestionModel> getQuestionsByLevel(
      ContentTestModel contentTest, String level) {
    return contentTest.questionList
        .where((question) => question.level == level)
        .toList();
  }

  /// Kiểm tra đáp án cho câu hỏi trắc nghiệm
  ///
  /// [question] là câu hỏi cần kiểm tra
  /// [answer] là đáp án người dùng chọn (A, B, C, D)
  /// Trả về true nếu đáp án đúng
  bool checkMultipleChoiceAnswer(QuestionModel question, String answer) {
    if (question.type != 'multiple-choice') {
      throw Exception('Câu hỏi không phải loại trắc nghiệm');
    }

    return question.resultCheck == answer;
  }

  /// Kiểm tra đáp án cho câu hỏi checkbox
  ///
  /// [question] là câu hỏi cần kiểm tra
  /// [answers] là danh sách đáp án người dùng chọn (1-2-3-4)
  /// Trả về true nếu đáp án đúng
  bool checkCheckboxAnswer(QuestionModel question, String answers) {
    if (question.type != 'checkbox') {
      throw Exception('Câu hỏi không phải loại checkbox');
    }

    return question.resultCheck == answers;
  }

  /// Kiểm tra đáp án cho câu hỏi điền khuyết
  ///
  /// [question] là câu hỏi cần kiểm tra
  /// [answer] là đáp án người dùng nhập
  /// Trả về true nếu đáp án đúng
  bool checkFillInTheBlankAnswer(QuestionModel question, String answer) {
    if (question.type != 'fill-in-the-blank') {
      throw Exception('Câu hỏi không phải loại điền khuyết');
    }

    return question.resultCheck?.toLowerCase() == answer.toLowerCase();
  }
}
