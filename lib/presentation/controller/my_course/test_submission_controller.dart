import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/my_course/test_submission_model.dart';
import 'package:tms_app/domain/usecases/my_course/test_submission_usecase.dart';

/// Controller xử lý việc gửi câu trả lời bài kiểm tra
class TestSubmissionController with ChangeNotifier {
  /// UseCase xử lý việc gửi câu trả lời bài kiểm tra
  final TestSubmissionUseCase _testSubmissionUseCase;

  /// Trạng thái đang tải
  bool _isLoading = false;

  /// Kết quả bài kiểm tra thông thường
  TestSubmissionResponse? _lessonTestResult;

  /// Kết quả bài kiểm tra chương
  ChapterTestSubmissionResponse? _chapterTestResult;

  /// Có lỗi xảy ra không
  bool _hasError = false;

  /// Thông báo lỗi
  String _errorMessage = '';

  /// Constructor
  TestSubmissionController({TestSubmissionUseCase? testSubmissionUseCase})
      : _testSubmissionUseCase =
            testSubmissionUseCase ?? sl<TestSubmissionUseCase>();

  /// Getter cho trạng thái đang tải
  bool get isLoading => _isLoading;

  /// Getter cho kết quả bài kiểm tra thông thường
  TestSubmissionResponse? get lessonTestResult => _lessonTestResult;

  /// Getter cho kết quả bài kiểm tra chương
  ChapterTestSubmissionResponse? get chapterTestResult => _chapterTestResult;

  /// Getter cho trạng thái lỗi
  bool get hasError => _hasError;

  /// Getter cho thông báo lỗi
  String get errorMessage => _errorMessage;

  /// Gửi câu trả lời bài kiểm tra thông thường
  Future<TestSubmissionResponse?> submitLessonTest({
    required int testId,
    required int totalQuestion,
    required String questionTypes,
    required int durationTest,
    required int courseId,
    required int chapterId,
    required List<QuestionAnswer> answers,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Lấy accountId từ SharedPrefs
      final accountId = await SharedPrefs.getUserId();

      print('🧪 Đang gửi câu trả lời bài kiểm tra thông thường...');
      print('   - TestId: $testId');
      print('   - CourseId: $courseId');
      print('   - ChapterId: $chapterId');
      print('   - TotalQuestion: $totalQuestion');
      print('   - AccountId: $accountId');

      // Tạo request
      final request = TestSubmissionRequest(
        testId: testId,
        totalQuestion: totalQuestion,
        type: questionTypes,
        durationTest: durationTest,
        courseId: courseId,
        accountId: accountId,
        chapterId: chapterId,
        isChapterTest: false,
        questionResponsiveList: answers,
      );

      // Gửi câu trả lời
      final result = await _testSubmissionUseCase.submitLessonTest(request);
      _lessonTestResult = result;

      print('✅ Đã gửi câu trả lời bài kiểm tra thông thường thành công');
      print('📊 Điểm số: ${result.data?.score}');
      print('📋 Kết quả: ${result.data?.resultTest}');

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      print('❌ Lỗi khi gửi câu trả lời bài kiểm tra thông thường: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Gửi câu trả lời bài kiểm tra chương
  Future<ChapterTestSubmissionResponse?> submitChapterTest({
    required int testId,
    required int totalQuestion,
    required String questionTypes,
    required int durationTest,
    required int courseId,
    required int chapterId,
    required List<QuestionAnswer> answers,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Lấy accountId từ SharedPrefs
      final accountId = await SharedPrefs.getUserId();

      print('🧪 Đang gửi câu trả lời bài kiểm tra chương...');
      print('   - TestId: $testId');
      print('   - CourseId: $courseId');
      print('   - ChapterId: $chapterId');
      print('   - TotalQuestion: $totalQuestion');
      print('   - AccountId: $accountId');

      // Tạo request
      final request = TestSubmissionRequest(
        testId: testId,
        totalQuestion: totalQuestion,
        type: questionTypes,
        durationTest: durationTest,
        courseId: courseId,
        accountId: accountId,
        chapterId: chapterId,
        isChapterTest: true,
        questionResponsiveList: answers,
      );

      // Gửi câu trả lời
      final result = await _testSubmissionUseCase.submitChapterTest(request);
      _chapterTestResult = result;

      print('✅ Đã gửi câu trả lời bài kiểm tra chương thành công');
      print('📋 Kết quả: ${result.message}');

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      print('❌ Lỗi khi gửi câu trả lời bài kiểm tra chương: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Reset trạng thái lỗi
  void resetError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Reset kết quả
  void resetResults() {
    _lessonTestResult = null;
    _chapterTestResult = null;
    notifyListeners();
  }
}
