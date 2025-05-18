import 'package:flutter/material.dart' hide MaterialType;
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/my_course/learn_lesson_model.dart'
    hide Lesson, LessonType;
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart';

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
      final courseLessonResponse =
          await _courseLessonUseCase.getCourseLessons(courseId);
      _courseLessonResponse = courseLessonResponse;
      print('Đã nhận dữ liệu từ API thành công');

      // Convert API data to local format
      _courseData = _convertApiDataToLocalFormat(courseLessonResponse);
      print('Đã chuyển đổi dữ liệu API: ${_courseData.length} chương');

      // Initialize expanded chapters state
      _expandedChapters =
          List.generate(_courseData.length, (index) => index == 0);

      // Setup initial selected chapter and lesson
      if (_courseData.isNotEmpty) {
        _selectedChapterIndex = 0;
        // Only set selectedLessonIndex if the chapter has lessons
        if (_courseData[0].lessons.isNotEmpty) {
          _selectedLessonIndex = 0;
        } else {
          _selectedLessonIndex = -1; // No lesson selected
        }
      } else {
        _selectedChapterIndex = -1;
        _selectedLessonIndex = -1;
      }

      // Initialize completed lessons (empty at start)
      _completedLessons = {};
    } catch (e) {
      print('Lỗi tải dữ liệu khóa học: $e');
      // Initialize with empty data to avoid null errors
      _courseData = [];
      _expandedChapters = [];
      _completedLessons = {};
      _selectedChapterIndex = -1;
      _selectedLessonIndex = -1;
    } finally {
      _isLoading = false;
      print('Đã hoàn thành quá trình tải dữ liệu, isLoading = $_isLoading');
      notifyListeners();
    }
  }

  // Convert API data to local format
  List<CourseChapter> _convertApiDataToLocalFormat(
      CourseLessonResponse apiData) {
    final List<CourseChapter> chapters = [];

    for (final chapter in apiData.chapters) {
      final List<Lesson> lessons = [];

      // Convert lessons
      for (final apiLesson in chapter.lessons) {
        // Determine lesson type
        final LessonType lessonType =
            apiLesson.lessonTest != null ? LessonType.test : LessonType.video;

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
        );

        lessons.add(lesson);
      }

      // Add chapter test if available
      if (chapter.chapterTest != null) {
        final chapterTest = Lesson(
          id: "chapter_test_${chapter.chapterId}",
          title: chapter.chapterTest!.testTitle,
          duration: "30 phút",
          type: LessonType.test,
          isUnlocked: true,
          questionCount: 15,
          videoUrl: null,
          documentUrl: null,
          testType: chapter.chapterTest!.testType,
        );

        lessons.add(chapterTest);
      }

      // Create CourseChapter object
      final courseChapter = CourseChapter(
        id: chapter.chapterId,
        title: chapter.chapterTitle,
        lessons: lessons,
      );

      chapters.add(courseChapter);
    }

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

  // Check if can navigate to next lesson
  bool canNavigateToNextLesson() {
    // If at the last lesson of the course
    if (_selectedChapterIndex == _courseData.length - 1 &&
        _selectedLessonIndex ==
            _courseData[_selectedChapterIndex].lessons.length - 1) {
      return false;
    }

    // If current lesson is not completed
    final currentLesson =
        _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];
    if (_completedLessons[currentLesson.id] != true) {
      return false;
    }

    // If next lesson is locked
    if (_selectedLessonIndex <
        _courseData[_selectedChapterIndex].lessons.length - 1) {
      // Next lesson in the same chapter
      final nextLesson =
          _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex + 1];
      if (!nextLesson.isUnlocked) {
        return false;
      }
    } else if (_selectedChapterIndex < _courseData.length - 1) {
      // First lesson of next chapter
      final nextLesson = _courseData[_selectedChapterIndex + 1].lessons[0];
      if (!nextLesson.isUnlocked) {
        return false;
      }
    }

    return true;
  }

  // Navigate to previous lesson
  void navigateToPreviousLesson() {
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

  // Navigate to next lesson
  void navigateToNextLesson() {
    if (_selectedLessonIndex <
        _courseData[_selectedChapterIndex].lessons.length - 1) {
      // Go to next lesson in same chapter
      _selectedLessonIndex++;
    } else if (_selectedChapterIndex < _courseData.length - 1) {
      // Go to first lesson of next chapter
      _selectedChapterIndex++;
      _selectedLessonIndex = 0;

      // Ensure chapter is expanded
      _expandedChapters[_selectedChapterIndex] = true;
    }
    notifyListeners();
  }

  // LESSON COMPLETION METHODS

  // Mark a lesson as completed
  void onLessonCompleted(String lessonId) {
    _completedLessons[lessonId] = true;

    // Unlock next lesson
    _unlockNextLesson(lessonId);
    notifyListeners();
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
    notifyListeners();
  }

  // Calculate if test is passed
  bool isTestPassed() {
    return _testResult >= 5.0;
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
}
