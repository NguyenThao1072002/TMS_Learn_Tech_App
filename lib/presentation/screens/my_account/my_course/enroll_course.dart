import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/DI/service_locator.dart'; // Import sl từ service_locator
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/data/models/my_course/learn_lesson_model.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/take_test.dart';
import 'package:tms_app/presentation/widgets/my_course/test_instruction.dart';
import 'package:dio/dio.dart';
import 'package:tms_app/data/services/my_course/course_lesson_service.dart';
import 'package:tms_app/data/repositories/my_course/course_lesson_repository_impl.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_summary_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/continue_learning_dialog.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_materials_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/comment_item_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/complete_lesson_button.dart';
import 'package:tms_app/presentation/widgets/my_course/test_results_dialog.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_content_widget.dart';
import 'package:tms_app/presentation/controller/my_course/my_course_controller.dart';
import 'package:provider/provider.dart';

// Enum for lesson types
enum LessonType { video, test }

// Enum for material types
enum MaterialType {
  pdf,
  document,
  presentation,
  spreadsheet,
  image,
  code,
  other,
}

// Material item model
class MaterialItem {
  final String title;
  final String description;
  final MaterialType type;
  final String url;

  const MaterialItem({
    required this.title,
    required this.description,
    required this.type,
    required this.url,
  });
}

// Course chapter model
class CourseChapter {
  final int id;
  final String title;
  final List<Lesson> lessons;

  CourseChapter({
    required this.id,
    required this.title,
    required this.lessons,
  });
}

// Lesson model
class Lesson {
  final String id;
  final String title;
  final String duration;
  final LessonType type;
  bool isUnlocked;
  final int? questionCount;
  final String? videoUrl; // URL video từ API
  final String? documentUrl; // URL tài liệu từ API
  final String? testType; // Loại bài kiểm tra (Test Bài/Test Chương)

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.isUnlocked,
    this.questionCount,
    this.videoUrl,
    this.documentUrl,
    this.testType,
  });
}

class EnrollCourseScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final bool startOver;
  final bool viewAllLessons;
  final bool startVideo;
  final bool showMaterials;
  final bool showLessonContent;
  final String videoUrl;
  final List<MaterialItem> materials;
  final String summary;

  const EnrollCourseScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.startOver = false,
    this.viewAllLessons = false,
    this.startVideo = false,
    this.showMaterials = false,
    this.showLessonContent = false,
    this.videoUrl = '',
    this.materials = const [],
    this.summary = '',
  });

  @override
  State<EnrollCourseScreen> createState() => _EnrollCourseScreenState();
}

class _EnrollCourseScreenState extends State<EnrollCourseScreen>
    with SingleTickerProviderStateMixin {
  // Controller for managing business logic
  late MyCourseController _controller;

  // Additional UI state variables that don't belong in controller
  bool _isWatchingVideo = false;
  final bool _isTakingTest = false;
  bool _isVideoPlaying = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize TabController for UI
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controller from dependency injection
    _controller = sl<MyCourseController>();

    // Load course data using the controller
    _loadCourseData();
  }

  // Load course data using the controller
  Future<void> _loadCourseData() async {
    try {
      await _controller.initialize(widget.courseId);
      // Force rebuild UI after data loaded successfully
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading course data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải dữ liệu khóa học: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Chỉ mục chương đang được chọn
  int _selectedChapterIndex = 0;

  // Chỉ mục bài học đang được chọn
  int _selectedLessonIndex = 0;

  // Trạng thái mở rộng/thu gọn của các chương
  late List<bool> _expandedChapters;

  // Trạng thái hoàn thành của các bài học
  late Map<String, bool> _completedLessons;

  // Dữ liệu giả lập khóa học
  late List<CourseChapter> _courseData;

  // Đang tải dữ liệu
  bool _isLoading = true;

  // Điểm kiểm tra (giả lập)
  double result = 7.5;

  // Câu hỏi kiểm tra (giả lập)
  final List<Map<String, dynamic>> testQuestions = [
    {'id': 1, 'points': 1.0},
    {'id': 2, 'points': 1.0},
    {'id': 3, 'points': 1.0},
    {'id': 4, 'points': 1.0},
    {'id': 5, 'points': 1.0},
    {'id': 6, 'points': 1.0},
    {'id': 7, 'points': 1.0},
    {'id': 8, 'points': 1.0},
    {'id': 9, 'points': 1.0},
    {'id': 10, 'points': 1.0},
  ];

  // Additional properties
  Lesson? _currentLesson;
  String? _selectedLessonId;
  final bool _isCompletingLesson = false;

  // Khai báo useCase sử dụng DI chính thống
  late CourseLessonUseCase _courseLessonUseCase;

  // Add course data from API response
  CourseLessonResponse? _courseLessonResponse;

  // Đặt lại tiến độ khóa học từ đầu
  void _resetCourseProgress() {
    setState(() {
      // Đặt lại tất cả các bài học về trạng thái chưa hoàn thành
      _completedLessons = {};

      // Chọn bài học đầu tiên
      _selectedChapterIndex = 0;
      _selectedLessonIndex = 0;

      // Chỉ mở rộng chương đầu tiên
      _expandedChapters =
          List.generate(_courseData.length, (index) => index == 0);

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đã đặt lại tiến độ khóa học. Bạn có thể bắt đầu lại từ đầu.'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  // Mở rộng tất cả các chương để xem toàn bộ bài học
  void _expandAllChapters() {
    // Mở rộng tất cả các chương thông qua controller
    setState(() {
      // Mở rộng tất cả các chương
      _expandedChapters = List.generate(_courseData.length, (index) => true);
      // Hiển thị thanh bên trong chế độ di động
      _controller.setSidebarVisibility(true);
    });
  }

  // Hiển thị popup tiếp tục học
  void _showContinueLearningPopup() async {
    // Tính toán phần trăm tiến độ khóa học
    int totalLessons = 0;
    int completedLessons = 0;

    // Đợi dữ liệu khóa học được tải xong
    if (_controller.isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // Thêm một độ trễ nhỏ để tránh vấn đề với animation
    await Future.delayed(const Duration(milliseconds: 300));

    // Nếu widget đã bị hủy (navigate away), thoát
    if (!mounted) return;

    // Tính tổng số bài học và số bài học đã hoàn thành
    for (var chapter in _controller.courseData) {
      totalLessons += chapter.lessons.length.toInt();
      for (var lesson in chapter.lessons) {
        if (_controller.completedLessons[lesson.id] == true) {
          completedLessons++;
        }
      }
    }

    // Tính phần trăm hoàn thành
    final courseProgress = totalLessons > 0
        ? ((completedLessons / totalLessons) * 100).round()
        : 0;

    // Tìm bài học tiếp theo cần học
    String lastLessonTitle = "Bài 1: Tổng quan về khóa học";

    // Tìm bài học đầu tiên chưa hoàn thành
    outerLoop:
    for (var chapter in _controller.courseData) {
      for (var lesson in chapter.lessons) {
        if (_controller.completedLessons[lesson.id] != true &&
            lesson.isUnlocked) {
          lastLessonTitle = lesson.title;
          break outerLoop;
        }
      }
    }

    // Hiển thị dialog
    final result = await ContinueLearningDialog.show(
      context,
      courseTitle: widget.courseTitle,
      courseProgress: courseProgress,
      lastLessonTitle: lastLessonTitle,
      thumbnailUrl:
          'https://img.youtube.com/vi/default/maxresdefault.jpg', // URL mẫu
    );

    // Xử lý kết quả từ dialog
    if (result == 1) {
      // Người dùng chọn Tiếp tục học, hiển thị tab nội dung bài học
      setState(() {
        _controller
            .setSidebarVisibility(false); // Hiển thị tab nội dung bài học
      });
    } else if (result == 2) {
      // Người dùng chọn Xem tài liệu khóa học
      setState(() {
        _controller.setSidebarVisibility(true); // Hiển thị danh sách bài học
        // Chuyển đến tab tài liệu
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_tabController != null) {
            _tabController.animateTo(1);
          }
        });
      });
    } else if (result == 3) {
      // Người dùng chọn Xem tất cả bài học, hiển thị danh sách bài học
      setState(() {
        _controller.setSidebarVisibility(true); // Hiển thị danh sách bài học
        _controller.expandAllChapters(); // Mở rộng tất cả các chương
      });
    }
  }

  // Tải dữ liệu khóa học từ API
  Future<void> _initApiDataLoading() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Bắt đầu gọi API lấy dữ liệu khóa học ${widget.courseId}');

      // Gọi API để lấy dữ liệu khóa học
      final courseLessonResponse =
          await _courseLessonUseCase.getCourseLessons(widget.courseId);

      print(
          'Đã nhận dữ liệu từ API, có ${courseLessonResponse.chapters.length} chương');

      // Lưu dữ liệu API để sử dụng sau này
      _courseLessonResponse = courseLessonResponse;

      // Chuyển đổi dữ liệu từ API sang định dạng cục bộ
      _courseData = _convertApiDataToLocalFormat(courseLessonResponse);

      print(
          'Đã chuyển đổi dữ liệu API thành định dạng cục bộ: ${_courseData.length} chương');

      // Nếu không có dữ liệu, hiển thị thông báo
      if (_courseData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khóa học này chưa có nội dung'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Khởi tạo trạng thái mở rộng cho các chương
      _expandedChapters =
          List.generate(_courseData.length, (index) => index == 0);

      // Khởi tạo trạng thái hoàn thành bài học
      _completedLessons = {};

      print('Đã tải xong dữ liệu API');
    } catch (e) {
      print('Lỗi khi tải dữ liệu khóa học: $e');

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu khóa học: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Khởi tạo mảng rỗng để tránh lỗi null
      _courseData = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Chuyển đổi dữ liệu API sang định dạng cục bộ
  List<CourseChapter> _convertApiDataToLocalFormat(
      CourseLessonResponse apiData) {
    final List<CourseChapter> chapters = [];

    for (final chapter in apiData.chapters) {
      final List<Lesson> lessons = [];

      // Chuyển đổi bài học
      for (final apiLesson in chapter.lessons) {
        // Xác định kiểu bài học - ưu tiên nội dung video nếu có
        final LessonType lessonType = (apiLesson.video != null &&
                apiLesson.video!.videoUrl != null &&
                apiLesson.video!.videoUrl.isNotEmpty)
            ? LessonType.video
            : (apiLesson.lessonTest != null
                ? LessonType.test
                : LessonType.video);

        // Chuyển đổi thời lượng từ giây sang định dạng phút:giây
        final String duration = _formatDuration(apiLesson.lessonDuration);

        // Tạo đối tượng Lesson
        final lesson = Lesson(
          id: apiLesson.lessonId.toString(),
          title: apiLesson.lessonTitle,
          duration: duration,
          type: lessonType,
          isUnlocked: true, // Giả sử tất cả bài học đều đã mở khóa
          questionCount: apiLesson.lessonTest != null
              ? 10
              : null, // Giả sử mỗi bài kiểm tra có 10 câu hỏi
          videoUrl: apiLesson.video != null ? apiLesson.video!.videoUrl : null,
          documentUrl:
              apiLesson.video != null ? apiLesson.video!.documentUrl : null,
          testType: apiLesson.lessonTest != null
              ? apiLesson.lessonTest!.testType
              : null,
        );

        lessons.add(lesson);
      }

      // Thêm bài kiểm tra cấp chương nếu có
      if (chapter.chapterTest != null) {
        final chapterTest = Lesson(
          id: "chapter_test_${chapter.chapterId}",
          title: chapter.chapterTest!.testTitle,
          duration:
              "30 phút", // Giả sử thời gian làm bài kiểm tra chương là 30 phút
          type: LessonType.test,
          isUnlocked: true,
          questionCount: 15, // Giả sử mỗi bài kiểm tra chương có 15 câu hỏi
          videoUrl: null, // Bài kiểm tra chương không có video
          documentUrl: null, // Bài kiểm tra chương không có tài liệu
          testType: chapter.chapterTest!.testType,
        );

        lessons.add(chapterTest);
      }

      // Tạo đối tượng CourseChapter
      final courseChapter = CourseChapter(
        id: chapter.chapterId,
        title: chapter.chapterTitle,
        lessons: lessons,
      );

      chapters.add(courseChapter);
    }

    return chapters;
  }

  // Chuyển đổi thời lượng từ giây sang định dạng phút:giây
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Khởi tạo dữ liệu mẫu trong trường hợp không thể tải dữ liệu từ API
  void _initializeSampleData() {
    print('Khởi tạo dữ liệu mẫu tạm thời do không thể kết nối API');

    // Dữ liệu giả lập
    _courseData = [
      CourseChapter(
        id: 1,
        title: "Chương 1: Giới thiệu khóa học (Dữ liệu mẫu)",
        lessons: [
          Lesson(
            id: "1_1",
            title: "Bài 1: Tổng quan về khóa học (Dữ liệu mẫu)",
            duration: "10:15",
            type: LessonType.video,
            isUnlocked: true,
            videoUrl: "https://example.com/video1.mp4",
            documentUrl: "https://example.com/document1.pdf",
            testType: "Test Bài",
          ),
          Lesson(
            id: "1_2",
            title: "Bài 2: Cài đặt môi trường (Dữ liệu mẫu)",
            duration: "15:30",
            type: LessonType.video,
            isUnlocked: true,
            videoUrl: "https://example.com/video2.mp4",
            documentUrl: "https://example.com/document2.docx",
            testType: "Test Bài",
          ),
          Lesson(
            id: "1_test",
            title: "Bài kiểm tra chương 1 (Dữ liệu mẫu)",
            duration: "15 phút",
            type: LessonType.test,
            isUnlocked: true,
            questionCount: 5,
            videoUrl: "https://example.com/test_video.mp4",
            documentUrl: "https://example.com/test_document.pdf",
            testType: "Test Bài",
          ),
        ],
      ),
      CourseChapter(
        id: 2,
        title: "Chương 2: Kiến thức nền tảng (Dữ liệu mẫu)",
        lessons: [
          Lesson(
            id: "2_1",
            title: "Bài 1: Kiến thức cơ bản (Dữ liệu mẫu)",
            duration: "12:30",
            type: LessonType.video,
            isUnlocked: true,
            videoUrl: "https://example.com/video3.mp4",
            documentUrl: "https://example.com/document3.pptx",
            testType: "Test Bài",
          ),
          Lesson(
            id: "2_test",
            title: "Bài kiểm tra chương 2 (Dữ liệu mẫu)",
            duration: "20 phút",
            type: LessonType.test,
            isUnlocked: true,
            questionCount: 8,
            videoUrl: "https://example.com/test_video2.mp4",
            documentUrl: "https://example.com/test_document2.docx",
            testType: "Test Chương",
          ),
        ],
      ),
    ];

    // Hiển thị thông báo cho người dùng
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Đang sử dụng dữ liệu mẫu. Kết nối máy chủ thất bại.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Khởi tạo trạng thái mở rộng cho các chương
    _expandedChapters =
        List.generate(_courseData.length, (index) => index == 0);

    // Khởi tạo trạng thái hoàn thành bài học (giả lập)
    _completedLessons = {};
  }

  // Xử lý khi bài học được hoàn thành
  void _onLessonCompleted(String lessonId) {
    setState(() {
      _completedLessons[lessonId] = true;

      // Tìm và mở khóa bài học tiếp theo
      _unlockNextLesson(lessonId);

      // Kiểm tra bài học vừa hoàn thành có bài kiểm tra không
      Lesson? completedLesson;

      // Tìm bài học vừa được đánh dấu hoàn thành
      for (final chapter in _courseData) {
        for (final lesson in chapter.lessons) {
          if (lesson.id == lessonId) {
            completedLesson = lesson;
            break;
          }
        }
        if (completedLesson != null) break;
      }

      // Nếu bài học có bài kiểm tra, chuyển đến bài kiểm tra
      if (completedLesson != null && completedLesson.testType != null) {
        // Tự động chuyển sang màn hình bài kiểm tra sau một khoảng thời gian ngắn
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startTest(completedLesson!);
          }
        });
      }
    });
  }

  // Mở khóa bài học tiếp theo
  void _unlockNextLesson(String completedLessonId) {
    // Tìm chương và bài học hiện tại
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
      // Nếu không phải bài học cuối cùng trong chương
      if (lessonIndex < _courseData[chapterIndex].lessons.length - 1) {
        setState(() {
          _courseData[chapterIndex].lessons[lessonIndex + 1].isUnlocked = true;
        });
      }
      // Nếu là bài cuối của chương và có chương tiếp theo
      else if (chapterIndex < _courseData.length - 1) {
        setState(() {
          _courseData[chapterIndex + 1].lessons[0].isUnlocked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.courseTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      );
    }

    if (_isWatchingVideo) {
      return _buildVideoPlayer();
    }

    if (_isTakingTest) {
      return _buildTestScreen();
    }

    // Kiểm tra kích thước màn hình để quyết định layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Coi thiết bị có width > 600 là tablet

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseTitle,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              _showProgressStats();
            },
            tooltip: 'Thống kê tiến độ',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Trợ giúp',
          ),
        ],
      ),
      // Sử dụng layout khác nhau dựa trên kích thước màn hình
      body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
    );
  }

  // Layout cho màn hình tablet (ngang)
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar danh sách chương và bài học (chiếm 30% màn hình)
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              right: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: _buildLessonSidebar(),
        ),

        // Nội dung bài học (chiếm 70% màn hình)
        Expanded(
          child: _buildLessonContent(),
        ),
      ],
    );
  }

  // Layout cho màn hình điện thoại (dọc)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Tab bar cho phép chuyển đổi giữa nội dung và danh sách bài học
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _controller.setSidebarVisibility(false);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !_controller.showSidebarInMobile
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Nội dung bài học',
                      style: TextStyle(
                        color: !_controller.showSidebarInMobile
                            ? Colors.orange
                            : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _controller.setSidebarVisibility(true);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _controller.showSidebarInMobile
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Danh sách bài học',
                      style: TextStyle(
                        color: _controller.showSidebarInMobile
                            ? Colors.orange
                            : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Nội dung chính - hiển thị sidebar hoặc nội dung bài học
        Expanded(
          child: _controller.showSidebarInMobile
              ? _buildLessonSidebar()
              : _buildLessonContent(),
        ),
      ],
    );
  }

  // Widget xây dựng thanh bên danh sách bài học
  Widget _buildLessonSidebar() {
    if (_controller.courseData.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu bài học'),
      );
    }

    // Kiểm tra xem có bài học nào không
    bool hasAnyLesson = false;
    for (var chapter in _controller.courseData) {
      if (chapter.lessons.isNotEmpty) {
        hasAnyLesson = true;
        break;
      }
    }

    if (!hasAnyLesson) {
      return const Center(
        child: Text('Khóa học này chưa có bài học nào'),
      );
    }

    return ListView.builder(
      itemCount: _controller.courseData.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, chapterIndex) {
        final chapter = _controller.courseData[chapterIndex];
        final isExpanded = _controller.expandedChapters[chapterIndex];

        // Tính số bài học đã hoàn thành trong chương
        int completedLessons = 0;
        for (var lesson in chapter.lessons) {
          if (_controller.completedLessons[lesson.id] == true) {
            completedLessons++;
          }
        }

        return Column(
          children: [
            // Tiêu đề chương
            InkWell(
              onTap: () {
                setState(() {
                  _controller.toggleChapterExpanded(chapterIndex);
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: _controller.selectedChapterIndex == chapterIndex
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          chapter.id.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chapter.lessons.isEmpty
                                ? 'Chưa có bài học'
                                : '$completedLessons/${chapter.lessons.length} bài học',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            // Danh sách bài học trong chương - chỉ hiển thị nếu có bài học
            if (isExpanded && chapter.lessons.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapter.lessons.length,
                itemBuilder: (context, lessonIndex) {
                  final lesson = chapter.lessons[lessonIndex];
                  final isCompleted =
                      _controller.completedLessons[lesson.id] == true;
                  final isSelected =
                      _controller.selectedChapterIndex == chapterIndex &&
                          _controller.selectedLessonIndex == lessonIndex;

                  return InkWell(
                    onTap: lesson.isUnlocked
                        ? () {
                            setState(() {
                              _controller.selectLesson(
                                  chapterIndex, lessonIndex);
                              // Nếu đang ở chế độ điện thoại, chuyển sang tab nội dung
                              if (MediaQuery.of(context).size.width <= 600) {
                                _controller.setSidebarVisibility(false);
                              }
                            });
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color:
                                isSelected ? Colors.orange : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon trạng thái bài học
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green
                                  : lesson.isUnlocked
                                      ? Colors.grey[300]
                                      : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isCompleted
                                    ? Icons.check
                                    : lesson.isUnlocked
                                        ? _getLessonIcon(lesson)
                                        : Icons.lock,
                                size: 14,
                                color: isCompleted
                                    ? Colors.white
                                    : lesson.isUnlocked
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: lesson.isUnlocked
                                        ? Colors.black
                                        : Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    // Content type indicators
                                    if (lesson.videoUrl != null &&
                                        lesson.videoUrl!.isNotEmpty)
                                      _buildContentTypeIndicator(
                                          Icons.videocam, Colors.blue),
                                    if (lesson.documentUrl != null &&
                                        lesson.documentUrl!.isNotEmpty)
                                      _buildContentTypeIndicator(
                                          Icons.description, Colors.green),
                                    if (lesson.testType != null)
                                      _buildContentTypeIndicator(
                                          Icons.quiz, Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      lesson.duration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Đường kẻ chia các chương
            if (chapterIndex < _controller.courseData.length - 1)
              Divider(
                color: Colors.grey[300],
                height: 1,
              ),
          ],
        );
      },
    );
  }

  // Widget xây dựng nội dung bài học
  Widget _buildLessonContent() {
    if (_controller.courseData.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu bài học'),
      );
    }

    final currentChapter = _controller.currentChapter;
    final currentLesson = _controller.currentLesson;

    if (currentChapter == null) {
      return const Center(
        child: Text('Không tìm thấy chương học phù hợp'),
      );
    }

    if (currentLesson == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Chương "${currentChapter.title}" chưa có bài học nào',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nội dung đang được cập nhật, vui lòng quay lại sau',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Get video URL and materials using controller
    String videoUrl = _controller.getVideoUrlForLesson(currentLesson);
    List<MaterialItem> materials =
        _controller.getMaterialsForLesson(currentLesson);

    return LessonContentWidget(
      currentChapter: currentChapter,
      currentLesson: currentLesson,
      completedLessons: _controller.completedLessons,
      tabController: _tabController,
      summary: widget.summary,
      videoUrl: videoUrl,
      materials: materials,
      onCommentSubmit: (comment) {
        // Handle comment submission
        print('Submitted comment: $comment');
      },
      onCompleteLesson: () {
        // Mark lesson as complete using controller
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hoàn thành bài học'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _controller.onLessonCompleted(currentLesson.id);
      },
      onPreviousLesson: _controller.navigateToPreviousLesson,
      onNextLesson: _controller.navigateToNextLesson,
      canNavigateToPrevious: _controller.canNavigateToPreviousLesson(),
      canNavigateToNext: _controller.canNavigateToNextLesson(),
      showTestResults: () => _showTestResults(currentLesson),
      startTest: () => _startTest(currentLesson),
      openVideoInExternalPlayer: _openVideoInExternalPlayer,
    );
  }

  // Widget xây dựng nội dung bài học video - cải thiện UI
  Widget _buildVideoLessonContent(Lesson lesson) {
    // Get video URL from API data if available
    String videoUrl = _getVideoUrlForLesson(lesson);

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player (mock)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isVideoPlaying = !_isVideoPlaying;
                      });
                    },
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video placeholder (replace with actual video player in real app)
                          videoUrl.isNotEmpty
                              ? Image.network(
                                  'https://img.youtube.com/vi/default/maxresdefault.jpg', // Fallback thumbnail
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(
                                          Icons.video_library,
                                          size: 64,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.video_library,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),

                          // Play button overlay
                          if (!_isVideoPlaying)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Hiển thị URL video thực tế (để dễ kiểm tra, có thể xóa sau)
                if (videoUrl.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Video URL từ API:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          videoUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Tạo intent để mở video trong trình phát bên ngoài
                            // hoặc triển khai trình phát video trực tiếp
                            _openVideoInExternalPlayer(videoUrl);
                          },
                          icon: const Icon(Icons.play_circle),
                          label: const Text('Xem video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Comment section
                CommentSectionWidget(
                  onCommentSubmit: (comment) {
                    // Handle comment submission
                    print('Submitted comment: $comment');
                  },
                ),

                // Add space at bottom for the fixed button
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Fixed "Complete" button at bottom as navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CompleteLessonButton(
              isCompleted: _completedLessons[lesson.id] == true,
              onComplete: () {
                // Mark lesson as complete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã hoàn thành bài học'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(
                    context, true); // Trả về true để đánh dấu hoàn thành
              },
            ),
          ),
        ],
      ),
    );
  }

  // Lấy URL video từ dữ liệu API dựa trên ID bài học
  String _getVideoUrlForLesson(Lesson lesson) {
    if (_courseLessonResponse == null) {
      return '';
    }

    // Chuyển đổi ID bài học thành int
    int lessonId;
    try {
      lessonId = int.parse(lesson.id);
    } catch (e) {
      // Xử lý trường hợp ID không phải số (ví dụ: "1_1", "chapter_test_1")
      if (lesson.id.startsWith('chapter_test_')) {
        // Đây là bài kiểm tra cấp chương, không có video
        return '';
      }

      // Thử trích xuất ID từ định dạng "chapter_lesson" (ví dụ: "1_1" -> 1)
      final parts = lesson.id.split('_');
      if (parts.length >= 2) {
        try {
          lessonId = int.parse(parts[1]);
        } catch (e) {
          print('Không thể phân tích ID bài học: ${lesson.id}');
          return '';
        }
      } else {
        return '';
      }
    }

    // Tìm chương và bài học trong dữ liệu API
    for (final chapter in _courseLessonResponse!.chapters) {
      for (final apiLesson in chapter.lessons) {
        if (apiLesson.lessonId == lessonId) {
          // Tìm thấy bài học, kiểm tra xem có video không
          if (apiLesson.video != null) {
            return apiLesson.video!.videoUrl;
          }
        }
      }
    }

    return '';
  }

  // Mở video trong trình phát bên ngoài
  void _openVideoInExternalPlayer(String videoUrl) {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có URL video khả dụng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Trong ứng dụng thực tế, bạn sẽ sử dụng url_launcher hoặc intent để mở video
    // Tạm thời chỉ hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đang mở video trong trình phát ngoài...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Triển khai mở video trong trình phát thực tế
    // Ví dụ:
    // url_launcher.launch(videoUrl);
  }

  // Widget xây dựng nội dung bài kiểm tra
  Widget _buildTestLessonContent(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner bài kiểm tra
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian: ${lesson.duration} | ${lesson.questionCount} câu hỏi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hướng dẫn làm bài',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TestInstruction(
                      icon: Icons.timer,
                      text: 'Thời gian làm bài: ${lesson.duration}',
                    ),
                    const SizedBox(height: 8),
                    TestInstruction(
                      icon: Icons.question_answer,
                      text: 'Số câu hỏi: ${lesson.questionCount} câu',
                    ),
                    const SizedBox(height: 8),
                    const TestInstruction(
                      icon: Icons.check_circle,
                      text: 'Điểm đạt: 70% số câu trả lời đúng',
                    ),
                    const SizedBox(height: 8),
                    const TestInstruction(
                      icon: Icons.refresh,
                      text: 'Có thể làm lại nếu không đạt',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Thông tin bài kiểm tra
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin quan trọng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bài kiểm tra này đánh giá kiến thức của bạn về nội dung đã học. Bạn cần đạt tối thiểu 70% số câu đúng để vượt qua và mở khóa bài học tiếp theo.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lưu ý:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn không thể chuyển sang bài học tiếp theo nếu chưa vượt qua bài kiểm tra này.',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hãy đảm bảo bạn đã xem kỹ tất cả bài giảng trước khi làm bài kiểm tra.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Nút bắt đầu làm bài
        Center(
          child: ElevatedButton.icon(
            onPressed: _completedLessons[lesson.id] == true
                ? () {
                    // Xem lại kết quả
                    _showTestResults(lesson);
                  }
                : () {
                    // Bắt đầu bài kiểm tra
                    _startTest(lesson);
                  },
            icon: Icon(_completedLessons[lesson.id] == true
                ? Icons.assessment
                : Icons.play_arrow),
            label: Text(
              _completedLessons[lesson.id] == true
                  ? 'Xem lại kết quả'
                  : 'Bắt đầu làm bài',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _completedLessons[lesson.id] == true
                  ? Colors.blue
                  : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Hiển thị dialog kết quả bài kiểm tra
  void _showTestResults(Lesson lesson) {
    // Use controller's test result and check if passed
    final bool isPassed = _controller.isTestPassed();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TestResultsDialog(
          result: _controller.testResult,
          totalQuestions: testQuestions.length,
          pointsPerQuestion: testQuestions.first['points'],
          isPassed: isPassed,
          onContinue: () {
            Navigator.of(context).pop();
          },
          onRetry: () {
            Navigator.of(context).pop();
            _startTest(lesson); // Làm lại bài kiểm tra
          },
          onReview: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // Kiểm tra có thể chuyển đến bài học trước đó
  bool _canNavigateToPreviousLesson() {
    if (_selectedChapterIndex == 0 && _selectedLessonIndex == 0) {
      return false;
    }
    return true;
  }

  // Kiểm tra có thể chuyển đến bài học tiếp theo
  bool _canNavigateToNextLesson() {
    // Nếu đang ở bài cuối cùng của khóa học
    if (_selectedChapterIndex == _courseData.length - 1 &&
        _selectedLessonIndex ==
            _courseData[_selectedChapterIndex].lessons.length - 1) {
      return false;
    }

    // Nếu bài học hiện tại chưa hoàn thành
    final currentLesson =
        _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];
    if (_completedLessons[currentLesson.id] != true) {
      return false;
    }

    // Nếu bài tiếp theo bị khóa
    if (_selectedLessonIndex <
        _courseData[_selectedChapterIndex].lessons.length - 1) {
      // Bài tiếp theo trong cùng chương
      final nextLesson =
          _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex + 1];
      if (!nextLesson.isUnlocked) {
        return false;
      }
    } else if (_selectedChapterIndex < _courseData.length - 1) {
      // Bài đầu tiên của chương tiếp theo
      final nextLesson = _courseData[_selectedChapterIndex + 1].lessons[0];
      if (!nextLesson.isUnlocked) {
        return false;
      }
    }

    return true;
  }

  // Chuyển đến bài học trước đó
  void _navigateToPreviousLesson() {
    setState(() {
      if (_selectedLessonIndex > 0) {
        // Quay lại bài trước trong cùng chương
        _selectedLessonIndex--;
      } else if (_selectedChapterIndex > 0) {
        // Chuyển đến bài cuối cùng của chương trước đó
        _selectedChapterIndex--;
        _selectedLessonIndex =
            _courseData[_selectedChapterIndex].lessons.length - 1;

        // Đảm bảo chương được mở rộng khi chuyển đến
        _expandedChapters[_selectedChapterIndex] = true;
      }
    });
  }

  // Chuyển đến bài học tiếp theo
  void _navigateToNextLesson() {
    setState(() {
      if (_selectedLessonIndex <
          _courseData[_selectedChapterIndex].lessons.length - 1) {
        // Chuyển đến bài tiếp theo trong cùng chương
        _selectedLessonIndex++;
      } else if (_selectedChapterIndex < _courseData.length - 1) {
        // Chuyển đến bài đầu tiên của chương tiếp theo
        _selectedChapterIndex++;
        _selectedLessonIndex = 0;

        // Đảm bảo chương được mở rộng khi chuyển đến
        _expandedChapters[_selectedChapterIndex] = true;
      }
    });
  }

  // Hiển thị thống kê tiến độ khóa học
  void _showProgressStats() {
    // Tính số bài học đã hoàn thành
    int totalLessons = 0;
    int completedLessons = 0;

    for (var chapter in _controller.courseData) {
      totalLessons += chapter.lessons.length.toInt();
      for (var lesson in chapter.lessons) {
        if (_controller.completedLessons[lesson.id] == true) {
          completedLessons++;
        }
      }
    }

    final completionPercent = (completedLessons / totalLessons * 100).toInt();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tiến độ khóa học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completionPercent% hoàn thành',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: completedLessons / totalLessons,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đã hoàn thành $completedLessons/$totalLessons bài học',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chi tiết theo chương',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _controller.courseData.length,
                itemBuilder: (context, index) {
                  final chapter = _controller.courseData[index];
                  int chapterCompletedLessons = 0;

                  for (var lesson in chapter.lessons) {
                    if (_controller.completedLessons[lesson.id] == true) {
                      chapterCompletedLessons++;
                    }
                  }

                  final chapterPercent =
                      (chapterCompletedLessons / chapter.lessons.length * 100)
                          .toInt();

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      chapter.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: chapterCompletedLessons /
                                chapter.lessons.length,
                            child: Container(
                              decoration: BoxDecoration(
                                color: chapterPercent == 100
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$chapterCompletedLessons/${chapter.lessons.length} bài học ($chapterPercent%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (index < _controller.courseData.length - 1)
                          const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị dialog trợ giúp
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Trợ giúp'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.lock,
              title: 'Mở khóa bài học',
              description:
                  'Hoàn thành bài học hiện tại để mở khóa bài tiếp theo.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.quiz,
              title: 'Bài kiểm tra',
              description:
                  'Đạt tối thiểu 70% câu đúng để vượt qua bài kiểm tra và mở khóa nội dung tiếp theo.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.video_library,
              title: 'Xem video',
              description:
                  'Xem hết video và đánh dấu hoàn thành để tiếp tục tiến trình học tập.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  // Build mục trợ giúp
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Xây dựng trình phát video
  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 20),
            const Text(
              'Video Player',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isWatchingVideo = false;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại bài học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Xây dựng màn hình kiểm tra
  Widget _buildTestScreen() {
    Lesson currentLesson = _getCurrentLesson();

    // Tạo danh sách câu hỏi mẫu cho bài kiểm tra
    final List<TestQuestion> sampleQuestions = [
      TestQuestion(
        questionText: 'Đâu là định nghĩa chính xác nhất về Flutter?',
        type: QuestionType.multipleChoice,
        options: [
          'Một ngôn ngữ lập trình',
          'Một framework UI đa nền tảng',
          'Một hệ điều hành di động',
          'Một công cụ quản lý cơ sở dữ liệu'
        ],
        correctAnswer: 'Một framework UI đa nền tảng',
        points: 1,
      ),
      TestQuestion(
        questionText: 'Các widget nào sau đây thuộc nhóm Stateless Widget?',
        type: QuestionType.checkboxes,
        options: ['Text', 'Image', 'StatefulBuilder', 'FutureBuilder', 'Icon'],
        correctAnswer: ['Text', 'Image', 'Icon'],
        points: 2,
      ),
      TestQuestion(
        questionText:
            'Thư viện quản lý trạng thái phổ biến trong Flutter là gì?',
        type: QuestionType.fillInBlank,
        options: [],
        correctAnswer: 'provider',
        points: 1,
      ),
      TestQuestion(
        questionText:
            'Giải thích cách hoạt động của widget BuildContext trong Flutter',
        type: QuestionType.essay,
        options: [],
        correctAnswer: '',
        points: 3,
      ),
      TestQuestion(
        questionText: 'Dart là ngôn ngữ lập trình kiểu gì?',
        type: QuestionType.multipleChoice,
        options: [
          'Ngôn ngữ lập trình hướng đối tượng',
          'Ngôn ngữ lập trình hàm',
          'Ngôn ngữ kịch bản',
          'Tất cả các đáp án trên'
        ],
        correctAnswer: 'Ngôn ngữ lập trình hướng đối tượng',
        points: 1,
      ),
    ];

    return TakeTestScreen(
      testTitle: currentLesson.title,
      questionCount: currentLesson.questionCount ?? 5,
      timeInMinutes: 15, // Thời gian mẫu
      questions: sampleQuestions,
    );
  }

  // Widget xây dựng nội dung tài liệu bài học
  Widget _buildLessonMaterials(Lesson lesson) {
    // Get materials from API data
    List<MaterialItem> materials = _getMaterialsForLesson(lesson);

    // If no materials found in API, use sample data
    if (materials.isEmpty) {
      // Sample material data as fallback
      materials = [
        const MaterialItem(
          title: 'Tài liệu giới thiệu khóa học',
          description: 'Tổng quan về các nội dung và mục tiêu của khóa học',
          type: MaterialType.pdf,
          url: 'https://example.com/intro.pdf',
        ),
        const MaterialItem(
          title: 'Hướng dẫn thực hành',
          description: 'Các bước thực hành chi tiết cho bài học này',
          type: MaterialType.document,
          url: 'https://example.com/guide.docx',
        ),
      ];
    }

    // Use the extracted widget
    return LessonMaterialsWidget(
      materials: materials,
      lessonTitle: lesson.title,
    );
  }

  // Lấy tài liệu từ dữ liệu API dựa trên ID bài học
  List<MaterialItem> _getMaterialsForLesson(Lesson lesson) {
    if (_courseLessonResponse == null) {
      return [];
    }

    List<MaterialItem> materials = [];

    // Chuyển đổi ID bài học thành int
    int lessonId;
    try {
      lessonId = int.parse(lesson.id);
    } catch (e) {
      // Xử lý ID không phải số như trong _getVideoUrlForLesson
      if (lesson.id.startsWith('chapter_test_')) {
        return [];
      }

      final parts = lesson.id.split('_');
      if (parts.length >= 2) {
        try {
          lessonId = int.parse(parts[1]);
        } catch (e) {
          print('Không thể phân tích ID bài học: ${lesson.id}');
          return [];
        }
      } else {
        return [];
      }
    }

    // Tìm bài học trong dữ liệu API
    for (final chapter in _courseLessonResponse!.chapters) {
      for (final apiLesson in chapter.lessons) {
        if (apiLesson.lessonId == lessonId) {
          // Tìm thấy bài học, kiểm tra xem có tài liệu không
          if (apiLesson.video != null && apiLesson.video!.documentUrl != null) {
            // Lấy URL tài liệu
            final String documentUrl = apiLesson.video!.documentUrl!;

            // Xác định loại tài liệu dựa trên phần mở rộng
            MaterialType materialType = _getMaterialTypeFromUrl(documentUrl);

            // Tạo tiêu đề và mô tả tự động
            String title = 'Tài liệu của ${apiLesson.lessonTitle}';
            String description = 'Tài liệu bổ sung cho bài học này';

            if (apiLesson.video!.documentShort != null &&
                apiLesson.video!.documentShort!.isNotEmpty) {
              description = apiLesson.video!.documentShort!;
            }

            // Tạo đối tượng MaterialItem
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

  // Xác định loại tài liệu dựa trên URL
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

  // Helper widget for material category cards
  Widget _buildMaterialCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mở danh mục: $title'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for material cards
  Widget _buildMaterialCard(MaterialItem material) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mở tài liệu: ${material.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Material icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getMaterialColor(material.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getMaterialIcon(material.type),
                    size: 28,
                    color: _getMaterialColor(material.type),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Material details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      material.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      children: [
                        _buildMaterialActionButton(
                          icon: Icons.visibility,
                          label: 'Xem',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildMaterialActionButton(
                          icon: Icons.download,
                          label: 'Tải về',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildMaterialActionButton(
                          icon: Icons.bookmark_border,
                          label: 'Lưu',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for material action buttons
  Widget _buildMaterialActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label tài liệu'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for community buttons
  Widget _buildCommunityButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for discussion items
  Widget _buildDiscussionItem({
    required String avatarUrl,
    required String username,
    required String timeAgo,
    required String title,
    required int replies,
    required int views,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mở thảo luận: $title'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    avatarUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Username and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Discussion title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.forum, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$replies phản hồi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$views lượt xem',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for supplementary resources
  Widget _buildSupplementaryResource({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mở $title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt bài học',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.summary,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 24),

          // Key points
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Điểm chính',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sample key points
                ..._buildKeyPoints(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKeyPoints() {
    final keyPoints = [
      'Hiểu về cấu trúc cơ bản của ứng dụng Flutter',
      'Sử dụng thành thạo StatefulWidget và StatelessWidget',
      'Triển khai quản lý trạng thái hiệu quả',
      'Áp dụng nguyên tắc thiết kế UI cho ứng dụng di động',
    ];

    return keyPoints.map((point) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(point, style: const TextStyle(fontSize: 16))),
          ],
        ),
      );
    }).toList();
  }

  Color _getMaterialColor(MaterialType type) {
    switch (type) {
      case MaterialType.pdf:
        return Colors.red;
      case MaterialType.document:
        return Colors.blue;
      case MaterialType.presentation:
        return Colors.orange;
      case MaterialType.spreadsheet:
        return Colors.green;
      case MaterialType.image:
        return Colors.purple;
      case MaterialType.code:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.pdf:
        return Icons.picture_as_pdf;
      case MaterialType.document:
        return Icons.description;
      case MaterialType.presentation:
        return Icons.slideshow;
      case MaterialType.spreadsheet:
        return Icons.table_chart;
      case MaterialType.image:
        return Icons.image;
      case MaterialType.code:
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildTestFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showTestConfirmation();
      },
      backgroundColor: Colors.orange,
      icon: const Icon(Icons.quiz),
      label: const Text('Kiểm tra bài học'),
    );
  }

  void _showTestConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bắt đầu kiểm tra?'),
        content: const Text(
          'Bạn có muốn làm bài kiểm tra kiến thức bài học này không? Bạn cần đạt ít nhất 70% để đạt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would navigate to the test screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang mở bài kiểm tra'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Bắt đầu ngay'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_in_picture),
                title: const Text('Chế độ thu nhỏ'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã chuyển sang chế độ thu nhỏ'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Tải xuống bài học'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang tải xuống bài học'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Chia sẻ'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang mở tùy chọn chia sẻ'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build progress item
  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Helper widget hiển thị điểm chính
  Widget _buildKeyPointItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget hiển thị gợi ý
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tips_and_updates,
              size: 16,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget hiển thị link tài liệu tham khảo
  Widget _buildResourceLinkItem({
    required IconData icon,
    required String title,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mở liên kết: $url'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 18,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lấy bài học hiện tại
  Lesson _getCurrentLesson() {
    if (_courseData.isNotEmpty &&
        _selectedChapterIndex < _courseData.length &&
        _selectedLessonIndex <
            _courseData[_selectedChapterIndex].lessons.length) {
      return _courseData[_selectedChapterIndex].lessons[_selectedLessonIndex];
    } else {
      throw Exception("Invalid lesson index");
    }
  }

  // Build test instruction item
  Widget buildTestInstruction({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // Widget để hiển thị item bình luận
  Widget _buildCommentItem({
    required String username,
    required String timeAgo,
    required String content,
    required String avatarUrl,
    required int likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
                onBackgroundImageError: (exception, stackTrace) =>
                    const Icon(Icons.person),
              ),
              const SizedBox(width: 8),
              // Username and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Comment content
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 8),
          // Actions
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.reply_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Trả lời',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bắt đầu bài kiểm tra
  void _startTest(Lesson lesson) {
    // Tạo danh sách câu hỏi mẫu cho bài kiểm tra
    final List<TestQuestion> sampleQuestions = [
      TestQuestion(
        questionText: 'Đâu là định nghĩa chính xác nhất về Flutter?',
        type: QuestionType.multipleChoice,
        options: [
          'Một ngôn ngữ lập trình',
          'Một framework UI đa nền tảng',
          'Một hệ điều hành di động',
          'Một công cụ quản lý cơ sở dữ liệu'
        ],
        correctAnswer: 'Một framework UI đa nền tảng',
        points: 1,
      ),
      TestQuestion(
        questionText: 'Các widget nào sau đây thuộc nhóm Stateless Widget?',
        type: QuestionType.checkboxes,
        options: ['Text', 'Image', 'StatefulBuilder', 'FutureBuilder', 'Icon'],
        correctAnswer: ['Text', 'Image', 'Icon'],
        points: 2,
      ),
      TestQuestion(
        questionText:
            'Thư viện quản lý trạng thái phổ biến trong Flutter là gì?',
        type: QuestionType.fillInBlank,
        options: [],
        correctAnswer: 'provider',
        points: 1,
      ),
      TestQuestion(
        questionText:
            'Giải thích cách hoạt động của widget BuildContext trong Flutter',
        type: QuestionType.essay,
        options: [],
        correctAnswer: '',
        points: 3,
      ),
      TestQuestion(
        questionText: 'Dart là ngôn ngữ lập trình kiểu gì?',
        type: QuestionType.multipleChoice,
        options: [
          'Ngôn ngữ lập trình hướng đối tượng',
          'Ngôn ngữ lập trình hàm',
          'Ngôn ngữ kịch bản',
          'Tất cả các đáp án trên'
        ],
        correctAnswer: 'Ngôn ngữ lập trình hướng đối tượng',
        points: 1,
      ),
    ];

    // Chuyển đến màn hình làm bài kiểm tra
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeTestScreen(
          testTitle: lesson.title,
          questionCount: lesson.questionCount ?? 5,
          timeInMinutes: 15, // Thời gian mẫu
          questions: sampleQuestions,
        ),
      ),
    ).then((result) {
      // Xử lý kết quả khi quay lại từ màn hình kiểm tra
      if (result != null && result is double) {
        // Set test result in controller
        _controller.setTestResult(result);

        // Cập nhật trạng thái hoàn thành nếu đạt điểm
        if (_controller.isTestPassed()) {
          _controller.onLessonCompleted(lesson.id);
        }

        // Hiển thị kết quả
        _showTestResults(lesson);
      }
    });
  }

  // Method to build a material item card
  Widget _buildMaterialItem(MaterialItem material) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloading: ${material.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Material icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getMaterialColor(material.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getMaterialIcon(material.type),
                    size: 28,
                    color: _getMaterialColor(material.type),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Material details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      material.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      children: [
                        _buildMaterialActionButton(
                          icon: Icons.visibility,
                          label: 'Xem',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildMaterialActionButton(
                          icon: Icons.download,
                          label: 'Tải về',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Phương thức để lấy icon phù hợp cho bài học dựa vào loại bài học
  IconData _getLessonIcon(Lesson lesson) {
    return _controller.getLessonIcon(lesson);
  }

  // Phương thức để tạo widget chỉ báo loại nội dung (video, tài liệu, bài kiểm tra)
  Widget _buildContentTypeIndicator(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  // Hiển thị thông tin chi tiết về bài học trong phần nội dung
  Widget _buildLessonDetailInfo(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nội dung bài học:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Thông tin về video
          if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.videocam, color: Colors.blue, size: 20),
              ),
              title:
                  const Text('Video bài giảng', style: TextStyle(fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
            ),

          // Thông tin về tài liệu
          if (lesson.documentUrl != null && lesson.documentUrl!.isNotEmpty)
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.description,
                    color: Colors.green, size: 20),
              ),
              title: const Text('Tài liệu kèm theo',
                  style: TextStyle(fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
            ),

          // Thông tin về bài kiểm tra
          if (lesson.testType != null)
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.quiz, color: Colors.orange, size: 20),
              ),
              title: Text(
                  'Bài kiểm tra ${lesson.testType == "Test Bài" ? "bài học" : "chương"}',
                  style: const TextStyle(fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
