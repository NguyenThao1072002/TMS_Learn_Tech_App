import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_progress_model.dart';
import 'package:tms_app/data/models/my_course/completed_lession_model.dart';
import 'package:tms_app/domain/usecases/my_course/course_progress_usecase.dart';

/// Controller quản lý tiến trình học tập
class CourseProgressController extends ChangeNotifier {
  final AddCourseProgressUseCase _addCourseProgressUseCase;
  final UnlockNextLessonUseCase _unlockNextLessonUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  CourseProgressModel? _currentProgress;

  /// Constructor
  CourseProgressController({
    required AddCourseProgressUseCase addCourseProgressUseCase,
    required UnlockNextLessonUseCase unlockNextLessonUseCase,
  })  : _addCourseProgressUseCase = addCourseProgressUseCase,
        _unlockNextLessonUseCase = unlockNextLessonUseCase;

  /// Getter cho trạng thái loading
  bool get isLoading => _isLoading;

  /// Getter cho thông báo lỗi
  String? get errorMessage => _errorMessage;

  /// Getter cho tiến trình hiện tại
  CourseProgressModel? get currentProgress => _currentProgress;

  /// Thêm tiến trình mới khi người dùng bắt đầu học khóa học
  Future<CourseProgressModel?> addCourseProgress(
      int accountId, int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print(
          '🔄 CourseProgressController: Đang thêm tiến trình mới cho accountId=$accountId, courseId=$courseId');
      final response =
          await _addCourseProgressUseCase.execute(accountId, courseId);
      _currentProgress = response.data;

      _isLoading = false;
      notifyListeners();

      print('✅ CourseProgressController: Thêm tiến trình thành công');
      return _currentProgress;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể thêm tiến trình: $e';
      notifyListeners();

      print('❌ CourseProgressController: Lỗi khi thêm tiến trình: $e');
      return null;
    }
  }

  /// Mở khóa bài học tiếp theo khi người dùng hoàn thành bài học hiện tại
  Future<CourseProgressModel?> unlockNextLesson(
      String accountId, int courseId, int chapterId, int lessonId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print(
          '🔄 CourseProgressController: Đang mở khóa bài học tiếp theo cho accountId=$accountId, courseId=$courseId, chapterId=$chapterId, lessonId=$lessonId');
      final response = await _unlockNextLessonUseCase.execute(
          accountId, courseId, chapterId, lessonId);
      _currentProgress = response.data.progress;

      _isLoading = false;
      notifyListeners();

      print('✅ CourseProgressController: Mở khóa bài học tiếp theo thành công');
      return _currentProgress;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể mở khóa bài học tiếp theo: $e';
      notifyListeners();

      print(
          '❌ CourseProgressController: Lỗi khi mở khóa bài học tiếp theo: $e');
      return null;
    }
  }

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
