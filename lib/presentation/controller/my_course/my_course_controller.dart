import 'dart:convert';

import 'package:flutter/material.dart' hide MaterialType;
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/my_course/learn_lesson_model.dart'
    hide Lesson, LessonType;
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/domain/repositories/my_course/course_progress_repository.dart';

class MyCourseController with ChangeNotifier {
  // Dependencies
  final CourseLessonUseCase _courseLessonUseCase;

  // State variables
  bool _isLoading = true;
  List<CourseChapter> _courseData = [];
  CourseLessonResponse? _courseLessonResponse;
  Map<String, bool> _completedLessons = {};
  List<bool> _expandedChapters = [];

  int _selectedChapterIndex = 0;
  int _selectedLessonIndex = 0;
  bool _showSidebarInMobile = false;
  double _testResult = 0.0;
  Function(Lesson)? _onStartTestCallback;

  // Getters
  bool get isLoading => _isLoading;
  List<CourseChapter> get courseData => _courseData;
  Map<String, bool> get completedLessons => _completedLessons;
  List<bool> get expandedChapters => _expandedChapters;
  int get selectedChapterIndex => _selectedChapterIndex;
  int get selectedLessonIndex => _selectedLessonIndex;
  bool get showSidebarInMobile => _showSidebarInMobile;
  double get testResult => _testResult;
  CourseLessonResponse? get courseLessonResponse => _courseLessonResponse;

  // Constructor with dependency injection
  MyCourseController({CourseLessonUseCase? courseLessonUseCase})
      : _courseLessonUseCase = courseLessonUseCase ?? sl<CourseLessonUseCase>();

  // Initialize controller
  Future<void> initialize(int courseId) async {
    await loadCourseData(courseId);
  }

  // Load course data from API
  Future<void> loadCourseData(int courseId) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu tải dữ liệu khóa học từ API với ID: $courseId');

    try {
      // Lấy accountId từ SharedPrefs
      final accountId = await SharedPrefs.getUserId();

      final courseLessonResponse = await _courseLessonUseCase
          .getCourseLessons(courseId, accountId: accountId);
      _courseLessonResponse = courseLessonResponse;
      print('Đã nhận dữ liệu từ API thành công');

      // Convert API data to local format
      _courseData = _convertApiDataToLocalFormat(courseLessonResponse);
      print('Đã chuyển đổi dữ liệu API: ${_courseData.length} chương');

      // Initialize expanded chapters state
      _expandedChapters =
          List.generate(_courseData.length, (index) => index == 0);

      // Find and select the next incomplete lesson
      _selectNextIncompleteLesson();

      // Kiểm tra trạng thái hoàn thành sau khi tải dữ liệu
      if (_courseData.isNotEmpty &&
          _selectedChapterIndex >= 0 &&
          _selectedLessonIndex >= 0) {
        final currentLesson =
            _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];
        print(
            '🔍 Kiểm tra trạng thái hoàn thành bài học hiện tại sau khi tải dữ liệu:');
        print('   - ID: ${currentLesson.id}');
        print('   - Tiêu đề: ${currentLesson.title}');
        print(
            '   - Đã hoàn thành: ${_completedLessons[currentLesson.id] == true}');
      }
    } catch (e) {
      print('Lỗi tải dữ liệu khóa học: $e');
      // Initialize with empty data to avoid null errors
      _courseData = [];
      _expandedChapters = [];
      _selectedChapterIndex = -1;
      _selectedLessonIndex = -1;
    } finally {
      _isLoading = false;
      print('Đã hoàn thành quá trình tải dữ liệu, isLoading = $_isLoading');
      notifyListeners();
    }
  }

  // Tìm và chọn bài học chưa hoàn thành tiếp theo
  void _selectNextIncompleteLesson() {
    print('🔍 Tìm bài học chưa hoàn thành tiếp theo...');

    if (_courseData.isEmpty) {
      print('❌ Không có dữ liệu khóa học');
      return;
    }

    // Duyệt qua từng chương
    for (int chapterIndex = 0;
        chapterIndex < _courseData.length;
        chapterIndex++) {
      final chapter = _courseData[chapterIndex];

      // Duyệt qua từng bài học trong chương
      for (int lessonIndex = 0;
          lessonIndex < chapter.lessons.length;
          lessonIndex++) {
        final lesson = chapter.lessons[lessonIndex];

        // Kiểm tra nếu bài học chưa hoàn thành
        if (_completedLessons[lesson.id] != true) {
          print('✅ Tìm thấy bài học chưa hoàn thành:');
          print('   - Chương: ${chapter.title}');
          print('   - Bài học: ${lesson.title}');
          print('   - ID: ${lesson.id}');

          // Đặt chỉ số chương và bài học hiện tại
          _selectedChapterIndex = chapterIndex;
          _selectedLessonIndex = lessonIndex;

          // Đảm bảo chương được mở rộng
          if (chapterIndex < _expandedChapters.length) {
            _expandedChapters[chapterIndex] = true;
          }

          return;
        }
      }
    }

    // Nếu tất cả bài học đã hoàn thành, chọn bài học đầu tiên
    print('ℹ️ Tất cả bài học đã hoàn thành, chọn bài học đầu tiên');
    if (_courseData.isNotEmpty && _courseData[0].lessons.isNotEmpty) {
      _selectedChapterIndex = 0;
      _selectedLessonIndex = 0;
      _expandedChapters[0] = true;
    } else {
      _selectedChapterIndex = -1;
      _selectedLessonIndex = -1;
    }
  }

  // Convert API data to local format
  List<CourseChapter> _convertApiDataToLocalFormat(
      CourseLessonResponse apiData) {
    final List<CourseChapter> chapters = [];

    // Khởi tạo lại Map completedLessons - chỉ khởi tạo nếu chưa có dữ liệu
    if (_completedLessons.isEmpty) {
      _completedLessons = {};
    }

    print('🔄 Bắt đầu chuyển đổi dữ liệu API');
    print('   - Số chương: ${apiData.chapters.length}');
    print(
        '   - Trạng thái _completedLessons trước khi chuyển đổi: $_completedLessons');

    for (final apiChapter in apiData.chapters) {
      final List<Lesson> lessons = [];

      print('   - Đang xử lý chương: ${apiChapter.chapterTitle}');
      print('   - Số bài học trong chương: ${apiChapter.lessons.length}');

      // Convert lessons
      for (final apiLesson in apiChapter.lessons) {
        print('     + Đang xử lý bài học: ${apiLesson.lessonTitle}');
        print('     + ID bài học: ${apiLesson.lessonId}');
        print('     + completedLesson từ API: ${apiLesson.completedLesson}');

        // Determine lesson type - prioritize video content if available
        final LessonType lessonType = (apiLesson.video != null &&
                apiLesson.video!.videoUrl != null &&
                apiLesson.video!.videoUrl.isNotEmpty)
            ? LessonType.video
            : (apiLesson.lessonTest != null
                ? LessonType.test
                : LessonType.video);

        // Format duration from seconds to minutes:seconds
        final String duration = _formatDuration(apiLesson.lessonDuration);

        // Create Lesson object
        final lesson = Lesson(
          id: apiLesson.lessonId.toString(),
          title: apiLesson.lessonTitle,
          duration: duration,
          type: lessonType,
          isUnlocked: true, // Assume all lessons are unlocked initially
          questionCount: apiLesson.lessonTest != null ? 10 : null,
          videoUrl: apiLesson.video != null ? apiLesson.video!.videoUrl : null,
          documentUrl:
              apiLesson.video != null ? apiLesson.video!.documentUrl : null,
          testType: apiLesson.lessonTest != null
              ? apiLesson.lessonTest!.testType
              : null,
          testId: apiLesson.lessonTest != null
              ? apiLesson.lessonTest!.testId
              : null,
          videoId: apiLesson.video != null ? apiLesson.video!.videoId : null,
        );

        lessons.add(lesson);

        // Cập nhật trạng thái hoàn thành từ API
        final String lessonId = apiLesson.lessonId.toString();
        if (apiLesson.completedLesson == true) {
          _completedLessons[lessonId] = true;
          print('     ✅ Đánh dấu bài học $lessonId đã hoàn thành');
        } else {
          print('     ❌ Bài học $lessonId chưa hoàn thành');
        }
      }

      // Add chapter test if available
      if (apiChapter.chapterTest != null) {
        final chapterTest = Lesson(
          id: "chapter_test_${apiChapter.chapterId}",
          title: apiChapter.chapterTest!.testTitle,
          duration: "30 phút",
          type: LessonType.test,
          isUnlocked: true,
          questionCount: 15,
          videoUrl: null,
          documentUrl: null,
          testType: apiChapter.chapterTest!.testType,
          testId: apiChapter.chapterTest!.testId,
        );

        lessons.add(chapterTest);

        // Cập nhật trạng thái hoàn thành bài kiểm tra chương từ API
        final String chapterTestId = "chapter_test_${apiChapter.chapterId}";
        if (apiChapter.completedTestChapter == true) {
          _completedLessons[chapterTestId] = true;
          print(
              '     ✅ Đánh dấu bài kiểm tra chương ${apiChapter.chapterId} đã hoàn thành');
        } else {
          print(
              '     ❌ Bài kiểm tra chương ${apiChapter.chapterId} chưa hoàn thành');
        }
      }

      // Create CourseChapter object
      final courseChapter = CourseChapter(
        id: apiChapter.chapterId.toString(),
        title: apiChapter.chapterTitle,
        lessons: lessons,
      );

      chapters.add(courseChapter);
    }

    // In ra toàn bộ danh sách bài học đã hoàn thành để kiểm tra
    print('📋 Danh sách bài học đã hoàn thành:');
    _completedLessons.forEach((key, value) {
      print('   - Bài học ID: $key, Hoàn thành: $value');
    });

    return chapters;
  }

  // Format duration from seconds to minutes:seconds
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get video URL for a specific lesson
  String getVideoUrlForLesson(Lesson? lesson) {
    if (lesson == null || _courseLessonResponse == null) {
      return '';
    }

    // Convert lesson ID to int
    int lessonId;
    try {
      lessonId = int.parse(lesson.id);
    } catch (e) {
      // Handle non-numeric IDs (e.g., "chapter_test_1")
      if (lesson.id.startsWith('chapter_test_')) {
        return '';
      }

      // Try to extract ID from format like "1_1"
      final parts = lesson.id.split('_');
      if (parts.length >= 2) {
        try {
          lessonId = int.parse(parts[1]);
        } catch (e) {
          print('Cannot parse lesson ID: ${lesson.id}');
          return '';
        }
      } else {
        return '';
      }
    }

    // Find lesson in API data
    for (final chapter in _courseLessonResponse!.chapters) {
      for (final apiLesson in chapter.lessons) {
        if (apiLesson.lessonId == lessonId) {
          if (apiLesson.video != null) {
            return apiLesson.video!.videoUrl;
          }
        }
      }
    }

    return '';
  }

  // Get materials for a specific lesson
  List<MaterialItem> getMaterialsForLesson(Lesson? lesson) {
    if (lesson == null || _courseLessonResponse == null) {
      return [];
    }

    List<MaterialItem> materials = [];

    // Convert lesson ID to int
    int lessonId;
    try {
      lessonId = int.parse(lesson.id);
    } catch (e) {
      // Handle non-numeric IDs
      if (lesson.id.startsWith('chapter_test_')) {
        return [];
      }

      final parts = lesson.id.split('_');
      if (parts.length >= 2) {
        try {
          lessonId = int.parse(parts[1]);
        } catch (e) {
          print('Cannot parse lesson ID: ${lesson.id}');
          return [];
        }
      } else {
        return [];
      }
    }

    // Find lesson in API data
    for (final chapter in _courseLessonResponse!.chapters) {
      for (final apiLesson in chapter.lessons) {
        if (apiLesson.lessonId == lessonId) {
          if (apiLesson.video != null && apiLesson.video!.documentUrl != null) {
            // Get document URL
            final String documentUrl = apiLesson.video!.documentUrl!;

            // Determine material type
            MaterialType materialType = _getMaterialTypeFromUrl(documentUrl);

            // Create title and description
            String title = 'Tài liệu của ${apiLesson.lessonTitle}';
            String description = 'Tài liệu bổ sung cho bài học này';

            if (apiLesson.video!.documentShort != null &&
                apiLesson.video!.documentShort!.isNotEmpty) {
              description = apiLesson.video!.documentShort!;
            }

            // Create MaterialItem
            MaterialItem material = MaterialItem(
              title: title,
              description: description,
              type: materialType,
              url: documentUrl,
            );

            materials.add(material);
          }
        }
      }
    }

    return materials;
  }

  // Determine material type based on URL
  MaterialType _getMaterialTypeFromUrl(String url) {
    final String lowercaseUrl = url.toLowerCase();

    if (lowercaseUrl.endsWith('.pdf')) {
      return MaterialType.pdf;
    } else if (lowercaseUrl.endsWith('.doc') ||
        lowercaseUrl.endsWith('.docx')) {
      return MaterialType.document;
    } else if (lowercaseUrl.endsWith('.ppt') ||
        lowercaseUrl.endsWith('.pptx')) {
      return MaterialType.presentation;
    } else if (lowercaseUrl.endsWith('.xls') ||
        lowercaseUrl.endsWith('.xlsx')) {
      return MaterialType.spreadsheet;
    } else if (lowercaseUrl.endsWith('.jpg') ||
        lowercaseUrl.endsWith('.jpeg') ||
        lowercaseUrl.endsWith('.png') ||
        lowercaseUrl.endsWith('.gif')) {
      return MaterialType.image;
    } else if (lowercaseUrl.endsWith('.zip') || lowercaseUrl.endsWith('.rar')) {
      return MaterialType.code;
    } else {
      return MaterialType.other;
    }
  }

  // NAVIGATION METHODS

  // Set selected lesson indexes
  void selectLesson(int chapterIndex, int lessonIndex) {
    _selectedChapterIndex = chapterIndex;
    _selectedLessonIndex = lessonIndex;
    notifyListeners();
  }

  // Toggle sidebar in mobile view
  void toggleSidebarInMobile() {
    _showSidebarInMobile = !_showSidebarInMobile;
    print('Toggled sidebar visibility to: $_showSidebarInMobile');
    notifyListeners();
  }

  // Set sidebar visibility in mobile view
  void setSidebarVisibility(bool isVisible) {
    _showSidebarInMobile = isVisible;
    print('Setting sidebar visibility to: $_showSidebarInMobile');
    notifyListeners();
  }

  // Toggle expanded state of a chapter
  void toggleChapterExpanded(int chapterIndex) {
    _expandedChapters[chapterIndex] = !_expandedChapters[chapterIndex];
    notifyListeners();
  }

  // Expand all chapters
  void expandAllChapters() {
    _expandedChapters = List.generate(_courseData.length, (index) => true);
    _showSidebarInMobile = true;
    notifyListeners();
  }

  // Check if can navigate to previous lesson
  bool canNavigateToPreviousLesson() {
    if (_selectedChapterIndex == 0 && _selectedLessonIndex == 0) {
      return false;
    }
    return true;
  }

  // Navigate to previous lesson
  void navigateToPreviousLesson() {
    if (canNavigateToPreviousLesson()) {
      if (_selectedLessonIndex > 0) {
        // Go to previous lesson in same chapter
        _selectedLessonIndex--;
      } else if (_selectedChapterIndex > 0) {
        // Go to last lesson of previous chapter
        _selectedChapterIndex--;
        _selectedLessonIndex =
            _courseData[_selectedChapterIndex].lessons.length - 1;

        // Ensure chapter is expanded
        _expandedChapters[_selectedChapterIndex] = true;
      }
      notifyListeners();
    }
  }

  // Navigate to next lesson
  void navigateToNextLesson() {
    print('🚀 Đang thử chuyển đến bài học tiếp theo...');
    print(
        '🔍 TRƯỚC KHI CHUYỂN: Chương $_selectedChapterIndex, Bài học $_selectedLessonIndex');

    if (canNavigateToNextLesson()) {
      // Lưu thông tin bài học hiện tại để so sánh
      final oldChapterIndex = _selectedChapterIndex;
      final oldLessonIndex = _selectedLessonIndex;

      if (_selectedLessonIndex <
          _courseData[_selectedChapterIndex].lessons.length - 1) {
        // Go to next lesson in same chapter
        _selectedLessonIndex++;
        print(
            '✅ Đã chuyển đến bài học tiếp theo trong cùng chương: $_selectedLessonIndex');
      } else if (_selectedChapterIndex < _courseData.length - 1) {
        // Go to first lesson of next chapter
        _selectedChapterIndex++;
        _selectedLessonIndex = 0;
        print(
            '✅ Đã chuyển đến chương tiếp theo: $_selectedChapterIndex, bài học: $_selectedLessonIndex');

        // Ensure chapter is expanded
        _expandedChapters[_selectedChapterIndex] = true;
      }

      // Kiểm tra xem giá trị đã được cập nhật chưa
      print(
          '🔍 SAU KHI CHUYỂN: Chương $_selectedChapterIndex, Bài học $_selectedLessonIndex');
      print(
          '🔄 Đã thay đổi từ [${oldChapterIndex}:${oldLessonIndex}] sang [${_selectedChapterIndex}:${_selectedLessonIndex}]');

      // Thông báo UI cập nhật sau khi chuyển bài học
      notifyListeners();
      print('📢 Đã thông báo UI cập nhật');

      // Thêm log để kiểm tra thông tin bài học hiện tại sau khi chuyển
      final currentLesson =
          _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];
      print('📝 Bài học hiện tại: ${currentLesson.title}');
      print('🧪 Có bài kiểm tra: ${currentLesson.testType != null}');
      print('✅ Đã hoàn thành: ${_completedLessons[currentLesson.id] == true}');
    } else {
      print(
          '❌ Không thể chuyển đến bài học tiếp theo - điều kiện không thỏa mãn');
    }
  }

  // Check if can navigate to next lesson
  bool canNavigateToNextLesson() {
    print('🔍 Kiểm tra có thể chuyển đến bài học tiếp theo...');

    // If at the last lesson of the course
    if (_selectedChapterIndex == _courseData.length - 1 &&
        _selectedLessonIndex ==
            _courseData[_selectedChapterIndex].lessons.length - 1) {
      print('❌ Đã ở bài học cuối cùng của khóa học');
      return false;
    }

    // Lấy bài học hiện tại
    final currentLesson =
        _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];

    // Log chi tiết về bài học hiện tại để debug
    print('📊 Thông tin bài học hiện tại:');
    print('   - ID: ${currentLesson.id}');
    print('   - Tên: ${currentLesson.title}');
    print('   - Có bài kiểm tra: ${currentLesson.testType != null}');
    print('   - Đã hoàn thành: ${_completedLessons[currentLesson.id] == true}');

    // Nếu bài học không có bài kiểm tra (testType = null), cho phép chuyển tiếp
    if (currentLesson.testType == null) {
      print('✅ Bài học không có bài kiểm tra - cho phép chuyển tiếp');
      return true;
    }

    // If current lesson is not completed
    if (_completedLessons[currentLesson.id] != true) {
      print('❌ Bài học hiện tại chưa hoàn thành: ${currentLesson.id}');
      return false;
    }

    // If next lesson is locked
    if (_selectedLessonIndex <
        _courseData[_selectedChapterIndex].lessons.length - 1) {
      // Next lesson in the same chapter
      final nextLesson =
          _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex + 1];
      if (!nextLesson.isUnlocked) {
        print(
            '❌ Bài học tiếp theo trong cùng chương bị khóa: ${nextLesson.id}');
        return false;
      }
    } else if (_selectedChapterIndex < _courseData.length - 1) {
      // First lesson of next chapter
      final nextLesson = _courseData[_selectedChapterIndex + 1].lessons[0];
      if (!nextLesson.isUnlocked) {
        print(
            '❌ Bài học đầu tiên của chương tiếp theo bị khóa: ${nextLesson.id}');
        return false;
      }
    }

    print('✅ Có thể chuyển đến bài học tiếp theo');
    return true;
  }

  // LESSON COMPLETION METHODS

  // Mark a lesson as completed
  void onLessonCompleted(String lessonId) {
    print('🔄 onLessonCompleted: Đánh dấu hoàn thành bài học $lessonId');
    _completedLessons[lessonId] = true;
    print(
        '  ✅ Đã đặt _completedLessons[$lessonId] = ${_completedLessons[lessonId]}');

    // Kiểm tra lại giá trị sau khi cập nhật
    print(
        '  🔍 Kiểm tra lại giá trị: _completedLessons[$lessonId] = ${_completedLessons[lessonId]}');
    print('  🔍 Kiểu dữ liệu của lessonId: ${lessonId.runtimeType}');

    // In ra toàn bộ danh sách bài học đã hoàn thành để kiểm tra
    print('  📋 Danh sách bài học đã hoàn thành sau khi cập nhật:');
    _completedLessons.forEach((key, value) {
      print('    - Bài học ID: $key (${key.runtimeType}), Hoàn thành: $value');
    });

    // Tìm thông tin về bài học và chương học
    int chapterId = 0;
    int lessonIdInt = 0;
    Lesson? completedLesson;

    try {
      // Chuyển đổi lessonId từ String sang int
      lessonIdInt = int.parse(lessonId);
    } catch (e) {
      print('  ❌ Lỗi chuyển đổi lessonId sang int: $e');
    }

    // Tìm chương chứa bài học
    for (final chapter in _courseData) {
      for (final lesson in chapter.lessons) {
        if (lesson.id == lessonId) {
          completedLesson = lesson;
          try {
            chapterId = int.parse(chapter.id);
          } catch (e) {
            print('  ❌ Lỗi chuyển đổi chapterId sang int: $e');
          }
          break;
        }
      }
      if (completedLesson != null) break;
    }

    print(
        '  📝 Bài học hoàn thành: ${completedLesson?.title ?? "không tìm thấy"}');
    print('  🧪 Có bài kiểm tra: ${completedLesson?.testType != null}');

    // Gọi API để cập nhật trạng thái hoàn thành bài học trên server
    if (chapterId > 0 && lessonIdInt > 0) {
      _updateLessonCompletionOnServer(chapterId, lessonIdInt);
    }

    // Unlock next lesson
    _unlockNextLesson(lessonId);

    // Nếu có callback và bài học có bài kiểm tra, gọi callback
    if (_onStartTestCallback != null &&
        completedLesson != null &&
        completedLesson.testType != null) {
      print('  🧪 Chuẩn bị gọi callback bài kiểm tra');
      Future.delayed(const Duration(milliseconds: 500), () {
        _onStartTestCallback!(completedLesson!);
      });
    } else {
      // Nếu không có bài kiểm tra, tự động chọn bài học chưa hoàn thành tiếp theo
      print('  🔍 Tự động chọn bài học chưa hoàn thành tiếp theo');
      _selectNextIncompleteLesson();
    }

    notifyListeners();
    print('  📢 Đã thông báo cập nhật UI');
  }

  // Cập nhật trạng thái hoàn thành bài học trên server
  Future<void> _updateLessonCompletionOnServer(
      int chapterId, int lessonId) async {
    try {
      // Lấy accountId từ SharedPrefs
      final accountId = await SharedPrefs.getUserId();

      if (_courseLessonResponse == null ||
          _courseLessonResponse!.courseId == 0) {
        print('  ❌ Không có thông tin khóa học để cập nhật trạng thái bài học');
        return;
      }

      final courseId = _courseLessonResponse!.courseId;

      print('  🔄 Gọi API cập nhật trạng thái hoàn thành bài học:');
      print('    - accountId: $accountId');
      print('    - courseId: $courseId');
      print('    - chapterId: $chapterId');
      print('    - lessonId: $lessonId');

      // Sử dụng CourseProgressRepository để gọi API
      final courseProgressRepository = sl<CourseProgressRepository>();
      final response = await courseProgressRepository.unlockNextLesson(
          accountId.toString(), courseId, chapterId, lessonId);

      print('  ✅ Cập nhật trạng thái bài học thành công: ${response.message}');
    } catch (e) {
      print('  ❌ Lỗi khi cập nhật trạng thái bài học trên server: $e');
    }
  }

  // Unlock the next lesson after completing current one
  void _unlockNextLesson(String completedLessonId) {
    // Find current chapter and lesson
    int chapterIndex = -1;
    int lessonIndex = -1;

    for (int i = 0; i < _courseData.length; i++) {
      for (int j = 0; j < _courseData[i].lessons.length; j++) {
        if (_courseData[i].lessons[j].id == completedLessonId) {
          chapterIndex = i;
          lessonIndex = j;
          break;
        }
      }
      if (chapterIndex != -1) break;
    }

    if (chapterIndex != -1 && lessonIndex != -1) {
      // If not the last lesson in the chapter
      if (lessonIndex < _courseData[chapterIndex].lessons.length - 1) {
        _courseData[chapterIndex].lessons[lessonIndex + 1].isUnlocked = true;
      }
      // If it's the last lesson in the chapter and there's a next chapter
      else if (chapterIndex < _courseData.length - 1) {
        _courseData[chapterIndex + 1].lessons[0].isUnlocked = true;
      }
    }
  }

  // TEST RELATED METHODS

  // Set test result
  void setTestResult(double result) {
    _testResult = result;

    // If test is passed, find and select the next incomplete lesson
    if (isTestPassed()) {
      print('🎉 Bài kiểm tra đạt yêu cầu, tìm bài học tiếp theo');

      // Delay a bit to ensure UI updates properly
      Future.delayed(const Duration(milliseconds: 500), () {
        _selectNextIncompleteLesson();
      });
    }

    notifyListeners();
  }

  // Calculate if test is passed
  bool isTestPassed() {
    return _testResult >= 7.0;
  }

  // Get current chapter and lesson
  CourseChapter? get currentChapter => _courseData.isNotEmpty &&
          _selectedChapterIndex >= 0 &&
          _selectedChapterIndex < _courseData.length
      ? _courseData[_selectedChapterIndex]
      : null;

  Lesson? get currentLesson {
    if (_courseData.isEmpty ||
        _selectedChapterIndex < 0 ||
        _selectedChapterIndex >= _courseData.length) {
      return null;
    }

    final chapter = _courseData[_selectedChapterIndex];

    if (chapter.lessons.isEmpty ||
        _selectedLessonIndex < 0 ||
        _selectedLessonIndex >= chapter.lessons.length) {
      return null;
    }

    return chapter.lessons[_selectedLessonIndex];
  }

  // Phương thức để lấy icon phù hợp cho bài học dựa vào loại bài học
  IconData getLessonIcon(Lesson lesson) {
    if (lesson.testType != null) {
      return Icons.quiz;
    } else if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
      return Icons.play_arrow;
    } else if (lesson.documentUrl != null && lesson.documentUrl!.isNotEmpty) {
      return Icons.description;
    } else {
      // Mặc định
      return lesson.type == LessonType.video ? Icons.play_arrow : Icons.quiz;
    }
  }

  // Setter cho callback bài kiểm tra
  set onStartTest(Function(Lesson) callback) {
    _onStartTestCallback = callback;
  }
}
