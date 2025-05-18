import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/DI/service_locator.dart'; // Import sl từ service_locator
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/data/models/my_course/learn_lesson_model.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/take_test.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/test_instruction.dart';
import 'package:dio/dio.dart';
import 'package:tms_app/data/services/my_course/course_lesson_service.dart';
import 'package:tms_app/data/repositories/my_course/course_lesson_repository_impl.dart';

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

  // Thêm hàm tĩnh để hiển thị popup tiếp tục học
  static Future<int?> showContinueLearningDialog(
    BuildContext context, {
    required String courseTitle,
    required int courseProgress,
    required String lastLessonTitle,
    required String thumbnailUrl,
  }) {
    return showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Continue Learning",
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation1,
                curve: Curves.easeOutCubic,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail khóa học với thanh tiến độ
                    Stack(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: thumbnailUrl.startsWith('assets/')
                              ? Image.asset(
                                  thumbnailUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(
                                          Icons.school,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  thumbnailUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(
                                          Icons.school,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),

                        // Tiêu đề khóa học
                        Positioned(
                          bottom: 40,
                          left: 16,
                          right: 16,
                          child: Text(
                            courseTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Thanh tiến độ
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Phần trăm hoàn thành
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tiến độ: $courseProgress%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.orange,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tiếp tục học',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Progress bar
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: courseProgress / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.orange,
                                          Colors.deepOrange,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nút đóng
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).pop(null),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Nội dung: Bài học tiếp theo
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề bài học tiếp theo
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bài học tiếp theo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      lastLessonTitle,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Các lựa chọn
                          Column(
                            children: [
                              // Nút Tiếp tục học
                              _buildOptionButton(
                                context,
                                icon: Icons.play_arrow_rounded,
                                label: 'Tiếp tục học',
                                color: Colors.orange,
                                onPressed: () => Navigator.of(context).pop(1),
                              ),

                              const SizedBox(height: 16),

                              // Thay đổi từ "Xem lại từ đầu" thành "Xem tài liệu khóa học"
                              _buildOptionButton(
                                context,
                                icon: Icons.book,
                                label: 'Xem tài liệu khóa học',
                                color: Colors.blue,
                                onPressed: () => Navigator.of(context).pop(2),
                              ),

                              const SizedBox(height: 16),

                              // Nút Xem tất cả bài học
                              _buildOptionButton(
                                context,
                                icon: Icons.view_list_rounded,
                                label: 'Xem tất cả bài học',
                                color: Colors.grey[800]!,
                                isOutlined: true,
                                onPressed: () => Navigator.of(context).pop(3),
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
          ),
        );
      },
    );
  }

  // Helper method to build option buttons with consistent style
  static Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
    required VoidCallback onPressed,
  }) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 22,
          ),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: Colors.grey[300]!),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 22,
          ),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<EnrollCourseScreen> createState() => _EnrollCourseScreenState();
}

class _EnrollCourseScreenState extends State<EnrollCourseScreen>
    with SingleTickerProviderStateMixin {
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

  // Đang xem video
  bool _isWatchingVideo = false;

  // Đang làm bài kiểm tra
  final bool _isTakingTest = false;

  // Thêm biến trạng thái để điều khiển hiển thị trong chế độ di động
  bool _showSidebarInMobile = false;

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
  bool _isVideoPlaying = false;
  final int _activeTabIndex = 0;
  Lesson? _currentLesson;
  String? _selectedLessonId;
  final bool _isCompletingLesson = false;
  late TabController _tabController;

  // Khai báo useCase sử dụng DI chính thống
  late CourseLessonUseCase _courseLessonUseCase;

  // Add course data from API response
  CourseLessonResponse? _courseLessonResponse;

  @override
  void initState() {
    super.initState();

    // Khởi tạo TabController
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo useCase từ DI
    _courseLessonUseCase = sl<CourseLessonUseCase>();
    print('Đã lấy CourseLessonUseCase từ DI thành công');

    // Tải dữ liệu khóa học
    _loadCourseData();
  }

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
    setState(() {
      // Mở rộng tất cả các chương
      _expandedChapters = List.generate(_courseData.length, (index) => true);
      // Hiển thị thanh bên trong chế độ di động
      _showSidebarInMobile = true;
    });
  }

  // Hiển thị popup tiếp tục học
  void _showContinueLearningPopup() async {
    // Tính toán phần trăm tiến độ khóa học (giả lập)
    int totalLessons = 0;
    int completedLessons = 0;

    // Đợi dữ liệu khóa học được tải xong
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // Thêm một độ trễ nhỏ để tránh vấn đề với animation
    await Future.delayed(const Duration(milliseconds: 300));

    // Nếu widget đã bị hủy (navigate away), thoát
    if (!mounted) return;

    // Tính tổng số bài học và số bài học đã hoàn thành
    for (var chapter in _courseData) {
      totalLessons += chapter.lessons.length.toInt();
      for (var lesson in chapter.lessons) {
        if (_completedLessons[lesson.id] == true) {
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
    for (var chapter in _courseData) {
      for (var lesson in chapter.lessons) {
        if (_completedLessons[lesson.id] != true && lesson.isUnlocked) {
          lastLessonTitle = lesson.title;
          break outerLoop;
        }
      }
    }

    // Hiển thị dialog
    final result = await EnrollCourseScreen.showContinueLearningDialog(
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
        _showSidebarInMobile =
            false; // Hiển thị tab nội dung bài học thay vì danh sách
        // _isWatchingVideo = true; // Không mở video ngay lập tức
      });
    } else if (result == 2) {
      // Người dùng chọn Xem tài liệu khóa học, chuyển đến tab tài liệu
      Future.delayed(const Duration(milliseconds: 100), () {
        // Sử dụng DefaultTabController để chuyển đến tab tài liệu (index 1)
        DefaultTabController.of(context).animateTo(1);
      });
    } else if (result == 3) {
      // Người dùng chọn Xem tất cả bài học, hiển thị danh sách bài học
      _expandAllChapters();
    }
  }

  // Tải dữ liệu khóa học từ API
  Future<void> _loadCourseData() async {
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
        // Xác định kiểu bài học (video hoặc test)
        final LessonType lessonType =
            apiLesson.lessonTest != null ? LessonType.test : LessonType.video;

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
    if (_isLoading) {
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
                      _showSidebarInMobile = false;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !_showSidebarInMobile
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Nội dung bài học',
                      style: TextStyle(
                        color: !_showSidebarInMobile
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
                      _showSidebarInMobile = true;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _showSidebarInMobile
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Danh sách bài học',
                      style: TextStyle(
                        color: _showSidebarInMobile
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
          child: _showSidebarInMobile
              ? _buildLessonSidebar()
              : _buildLessonContent(),
        ),
      ],
    );
  }

  // Widget xây dựng thanh bên danh sách bài học
  Widget _buildLessonSidebar() {
    return ListView.builder(
      itemCount: _courseData.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, chapterIndex) {
        final chapter = _courseData[chapterIndex];
        final isExpanded = _expandedChapters[chapterIndex];

        // Tính số bài học đã hoàn thành trong chương
        int completedLessons = 0;
        for (var lesson in chapter.lessons) {
          if (_completedLessons[lesson.id] == true) {
            completedLessons++;
          }
        }

        return Column(
          children: [
            // Tiêu đề chương
            InkWell(
              onTap: () {
                setState(() {
                  _expandedChapters[chapterIndex] =
                      !_expandedChapters[chapterIndex];
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: _selectedChapterIndex == chapterIndex
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
                            '$completedLessons/${chapter.lessons.length} bài học',
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

            // Danh sách bài học trong chương
            if (isExpanded)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapter.lessons.length,
                itemBuilder: (context, lessonIndex) {
                  final lesson = chapter.lessons[lessonIndex];
                  final isCompleted = _completedLessons[lesson.id] == true;
                  final isSelected = _selectedChapterIndex == chapterIndex &&
                      _selectedLessonIndex == lessonIndex;

                  return InkWell(
                    onTap: lesson.isUnlocked
                        ? () {
                            setState(() {
                              _selectedChapterIndex = chapterIndex;
                              _selectedLessonIndex = lessonIndex;
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
                                        ? lesson.type == LessonType.video
                                            ? Icons.play_arrow
                                            : Icons.quiz
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
                                    Icon(
                                      lesson.type == LessonType.video
                                          ? Icons.videocam
                                          : Icons.assignment,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
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
            if (chapterIndex < _courseData.length - 1)
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
    if (_courseData.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu bài học'),
      );
    }

    final currentChapter = _courseData[_selectedChapterIndex];
    final currentLesson = currentChapter.lessons[_selectedLessonIndex];

    // Tab controller cho nội dung bài học
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tiêu đề bài học với thiết kế tối ưu hơn
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row chứa tiêu đề và nút điều hướng
                Row(
                  children: [
                    // Nút bài trước - thu nhỏ lại
                    IconButton(
                      onPressed: _canNavigateToPreviousLesson()
                          ? _navigateToPreviousLesson
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      tooltip: 'Bài trước',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[800],
                        disabledBackgroundColor: Colors.grey[100],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tiêu đề bài học và chương
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chương
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Chương ${currentChapter.id}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentChapter.title.split(':').length > 1
                                      ? currentChapter.title
                                          .split(':')[1]
                                          .trim()
                                      : currentChapter.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Tên bài học
                          Text(
                            currentLesson.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Nút bài tiếp - thu nhỏ lại
                    IconButton(
                      onPressed: _canNavigateToNextLesson()
                          ? _navigateToNextLesson
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      tooltip: 'Bài tiếp',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                    ),
                  ],
                ),

                // Thời lượng và thông tin khác
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4, left: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Thông tin bài học
                      Row(
                        children: [
                          Icon(
                            currentLesson.type == LessonType.video
                                ? Icons.videocam
                                : Icons.assignment,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentLesson.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      // Trạng thái bài học
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _completedLessons[currentLesson.id] == true
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _completedLessons[currentLesson.id] == true
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 12,
                              color: _completedLessons[currentLesson.id] == true
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _completedLessons[currentLesson.id] == true
                                  ? 'Đã hoàn thành'
                                  : 'Chưa hoàn thành',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    _completedLessons[currentLesson.id] == true
                                        ? Colors.green
                                        : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar cho nội dung bài học
          SizedBox(
            height: 56,
            child: Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.orange,
                indicatorWeight: 3,
                dividerHeight: 1,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.play_circle_filled),
                    text: 'Video',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book),
                    text: 'Tài liệu',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.summarize),
                    text: 'Tóm tắt',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung bài học với TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Video bài học
                SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: currentLesson.type == LessonType.video
                      ? _buildVideoLessonContent(currentLesson)
                      : _buildTestLessonContent(currentLesson),
                ),

                // Tab 2: Tài liệu bài học
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildLessonMaterials(currentLesson),
                ),

                // Tab 3: Tóm tắt bài học
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildLessonSummary(currentLesson),
                ),
              ],
            ),
          ),
        ],
      ),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bình luận',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comment input field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận của bạn...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon:
                                  const Icon(Icons.send, color: Colors.orange),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã gửi bình luận'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sample comments
                      _buildCommentItem(
                        username: 'Nguyễn Văn A',
                        timeAgo: '2 ngày trước',
                        content:
                            'Bài học rất hay và dễ hiểu. Cảm ơn giảng viên đã chia sẻ!',
                        avatarUrl:
                            'https://randomuser.me/api/portraits/men/1.jpg',
                        likes: 5,
                      ),
                      const SizedBox(height: 16),
                      _buildCommentItem(
                        username: 'Trần Thị B',
                        timeAgo: '1 tuần trước',
                        content:
                            'Tôi có thắc mắc về phần triển khai API, liệu có thể giải thích rõ hơn được không?',
                        avatarUrl:
                            'https://randomuser.me/api/portraits/women/2.jpg',
                        likes: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildCommentItem(
                        username: 'Lê Văn C',
                        timeAgo: '2 tuần trước',
                        content:
                            'Kiến thức trong bài học này có thể áp dụng cho các dự án thực tế không? Tôi đang làm một ứng dụng tương tự.',
                        avatarUrl:
                            'https://randomuser.me/api/portraits/men/3.jpg',
                        likes: 8,
                      ),
                    ],
                  ),
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
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hoàn thành bài học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Define isPassed and other variables here so they're in scope for the entire dialog
        final bool isPassed = result >= 5.0;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phần header với gradients
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isPassed
                          ? [const Color(0xFF43A047), const Color(0xFF2E7D32)]
                          : [const Color(0xFFE53935), const Color(0xFFC62828)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPassed ? Icons.emoji_events : Icons.refresh,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isPassed ? 'TUYỆT VỜI!' : 'HÃY THỬ LẠI!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Phần nội dung
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Điểm số dạng biểu đồ tròn
                      Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            // Progress Circle
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: result / 10,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isPassed
                                      ? result >= 8.0
                                          ? Colors.green
                                          : Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ),

                            // Điểm số
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        result.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: isPassed
                                              ? result >= 8.0
                                                  ? Colors.green
                                                  : Colors.orange
                                              : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        '/10',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPassed
                                          ? result >= 8.0
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isPassed
                                          ? result >= 8.0
                                              ? 'Xuất sắc'
                                              : 'Đạt yêu cầu'
                                          : 'Chưa đạt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isPassed
                                            ? result >= 8.0
                                                ? Colors.green
                                                : Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Chi tiết kết quả
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildResultDetailRow(
                                'Đúng',
                                '${(result * 10 ~/ testQuestions.first['points']).toString()}/${testQuestions.length}',
                                isPassed ? Colors.green : Colors.grey[800]!),
                            const SizedBox(height: 10),
                            _buildResultDetailRow(
                                'Thời gian', '15:45', Colors.blue),
                            const SizedBox(height: 10),
                            _buildResultDetailRow(
                                'Điểm đạt', '≥ 5.0', Colors.grey[700]!),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Thông điệp
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? Colors.green.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPassed
                                ? Colors.green.withOpacity(0.3)
                                : Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPassed ? Icons.lightbulb : Icons.info_outline,
                              color: isPassed ? Colors.green : Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isPassed
                                    ? 'Bạn đã hoàn thành bài kiểm tra thành công và mở khóa bài học tiếp theo.'
                                    : 'Bạn cần xem lại bài giảng và thử lại bài kiểm tra để tiếp tục.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isPassed
                                      ? Colors.green[800]
                                      : Colors.amber[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Phần nút hành động
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: Row(
                    children: [
                      if (!isPassed)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Học lại'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (!isPassed) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (!isPassed) {
                              _startTest(lesson); // Làm lại bài kiểm tra
                            }
                          },
                          icon: Icon(
                              isPassed ? Icons.arrow_forward : Icons.refresh),
                          label: Text(isPassed ? 'Tiếp tục' : 'Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPassed ? Colors.green : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method để hiển thị hàng thông tin kết quả
  Widget _buildResultDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 14,
          ),
        ),
      ],
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

    for (var chapter in _courseData) {
      totalLessons += chapter.lessons.length.toInt();
      for (var lesson in chapter.lessons) {
        if (_completedLessons[lesson.id] == true) {
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
                itemCount: _courseData.length,
                itemBuilder: (context, index) {
                  final chapter = _courseData[index];
                  int chapterCompletedLessons = 0;

                  for (var lesson in chapter.lessons) {
                    if (_completedLessons[lesson.id] == true) {
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
                        if (index < _courseData.length - 1) const Divider(),
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
        // ... existing sample materials
      ];
    }

    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Material Categories with modern card design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Danh mục tài liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Material Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildMaterialCategoryCard(
                    icon: Icons.menu_book,
                    title: "Tài liệu bài học",
                    subtitle: "${materials.length} tài liệu",
                    color: Colors.blue,
                  ),
                  _buildMaterialCategoryCard(
                    icon: Icons.assignment,
                    title: "Bài tập thực hành",
                    subtitle: "3 bài tập",
                    color: Colors.purple,
                  ),
                  _buildMaterialCategoryCard(
                    icon: Icons.public,
                    title: "Tài nguyên web",
                    subtitle: "5 liên kết",
                    color: Colors.teal,
                  ),
                  // _buildMaterialCategoryCard(
                  //   icon: Icons.code,
                  //   title: "Mã nguồn",
                  //   subtitle: "2 repositories",
                  //   color: Colors.deepOrange,
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // // Section 2: Essential materials
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Tài liệu thiết yếu',
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.blueGrey[800],
            //         ),
            //       ),
            //       TextButton.icon(
            //         onPressed: () {
            //           // Future implementation: view all materials
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(
            //               content: Text('Xem tất cả tài liệu'),
            //               behavior: SnackBarBehavior.floating,
            //             ),
            //           );
            //         },
            //         icon: const Icon(Icons.view_list, size: 18),
            //         label: const Text('Xem tất cả'),
            //         style: TextButton.styleFrom(
            //           foregroundColor: Colors.blue,
            //           padding: EdgeInsets.zero,
            //           visualDensity: VisualDensity.compact,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 12),

            // Essential Materials List
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: sampleMaterials.length,
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   itemBuilder: (context, index) {
            //     final material = sampleMaterials[index];
            //     return _buildMaterialCard(material);
            //   },
            // ),

            // const SizedBox(height: 32),

            // Section 3: Course Community
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cộng đồng khóa học',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '324 thành viên tích cực',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tham gia trao đổi, học hỏi và chia sẻ kinh nghiệm cùng các học viên khác trong cộng đồng khóa học',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCommunityButton(
                          icon: Icons.forum_outlined,
                          label: 'Diễn đàn thảo luận',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mở diễn đàn thảo luận'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCommunityButton(
                          icon: Icons.question_answer_outlined,
                          label: 'Hỏi đáp với giảng viên',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mở hỏi đáp với giảng viên'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // // Section 4: Recent discussions
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Thảo luận gần đây',
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.blueGrey[800],
            //         ),
            //       ),
            //       const SizedBox(height: 16),

            //       // Recent discussion items
            //       _buildDiscussionItem(
            //         avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
            //         username: 'Nguyễn Văn A',
            //         timeAgo: '2 giờ trước',
            //         title: 'Cách triển khai API trong Flutter?',
            //         replies: 8,
            //         views: 42,
            //       ),
            //       _buildDiscussionItem(
            //         avatarUrl:
            //             'https://randomuser.me/api/portraits/women/44.jpg',
            //         username: 'Trần Thị B',
            //         timeAgo: '1 ngày trước',
            //         title: 'Gặp lỗi khi thực hiện bài tập số 3',
            //         replies: 15,
            //         views: 89,
            //       ),
            //       _buildDiscussionItem(
            //         avatarUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
            //         username: 'Lê Văn C',
            //         timeAgo: '3 ngày trước',
            //         title: 'Chia sẻ project cuối khóa của mình',
            //         replies: 23,
            //         views: 156,
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 32),

            // Section 5: Supplementary resources
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài nguyên bổ sung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSupplementaryResource(
                    icon: Icons.book,
                    title: 'Sách tham khảo',
                    description:
                        'Danh sách sách liên quan đến nội dung bài học',
                  ),
                  _buildSupplementaryResource(
                    icon: Icons.video_library,
                    title: 'Video bổ sung',
                    description: 'Các video hướng dẫn chuyên sâu',
                  ),
                  _buildSupplementaryResource(
                    icon: Icons.article,
                    title: 'Bài viết liên quan',
                    description: 'Các bài viết chuyên môn từ chuyên gia',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Section 2: List of Materials
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài liệu của bài học này',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  // Sort button (if needed)
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Materials list
            if (materials.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có tài liệu nào cho bài học này',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return _buildMaterialCard(material);
                },
              ),
          ],
        ),
      ),
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

  // Widget xây dựng nội dung tóm tắt bài học
  Widget _buildLessonSummary(Lesson lesson) {
    // Dummy summary content
    final summaryContent =
        'Bài học này giới thiệu về các khái niệm cơ bản trong lập trình Flutter, bao gồm StatefulWidget, StatelessWidget, và cách xây dựng UI. Bạn sẽ hiểu được cách Flutter hoạt động và cách tạo các ứng dụng di động đa nền tảng.\n\nFlutter là một framework UI mã nguồn mở của Google dùng để phát triển các ứng dụng di động đa nền tảng với một codebase duy nhất. Flutter sử dụng ngôn ngữ lập trình Dart và cung cấp bộ widget phong phú để xây dựng giao diện người dùng đẹp mắt, hiệu quả.';

    // Key points list
    final keyPoints = [
      'Hiểu về cấu trúc cơ bản của ứng dụng Flutter',
      'Sử dụng thành thạo StatefulWidget và StatelessWidget',
      'Triển khai quản lý trạng thái hiệu quả',
      'Áp dụng nguyên tắc thiết kế UI cho ứng dụng di động',
      'Hiểu biết về lifecycle của widgets trong Flutter',
    ];

    // Tips list
    final tips = [
      'Luyện tập code Flutter ít nhất 1 giờ mỗi ngày',
      'Đọc tài liệu chính thức của Flutter để hiểu rõ hơn về các widget',
      'Tham gia vào các diễn đàn cộng đồng để học hỏi kinh nghiệm từ người khác',
    ];

    // Controller for the notes text field
    final TextEditingController _notesController = TextEditingController();

    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elegant header with illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade400,
                    Colors.purple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tóm tắt bài học',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Điểm chính và tinh hoa của bài học',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Thời gian đọc: ${lesson.duration}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress tracker
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiến độ học tập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Linear progress indicator with percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.indigo.shade400),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '65%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Details row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem(
                        icon: Icons.play_circle_filled,
                        label: 'Video đã xem',
                        value: '65%',
                        color: Colors.indigo,
                      ),
                      _buildProgressItem(
                        icon: Icons.assignment_turned_in,
                        label: 'Bài tập đã làm',
                        value: '50%',
                        color: Colors.orange,
                      ),
                      _buildProgressItem(
                        icon: Icons.emoji_events,
                        label: 'Điểm kiểm tra',
                        value: '8.5/10',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary content card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.indigo.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Tổng quan nội dung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary text
                  Text(
                    summaryContent,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key points card with expandable content
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    const Text(
                      'Điểm chính cần nhớ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                childrenPadding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                children: [
                  ...keyPoints.map((point) => _buildKeyPointItem(point)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tips card with expandable content
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    const Text(
                      'Lời khuyên học tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                childrenPadding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                children: [
                  ...tips.map((tip) => _buildTipItem(tip)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Notes section for students
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.purple.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Ghi chú cá nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instructions text
                  Text(
                    'Ghi lại những điểm quan trọng, câu hỏi hoặc ý tưởng của bạn về bài học này.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes text field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú của bạn ở đây...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu ghi chú của bạn'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu ghi chú'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Resources card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Tài liệu tham khảo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Resource links
                  _buildResourceLinkItem(
                    icon: Icons.language,
                    title: 'Tài liệu chính thức Flutter',
                    url: 'https://flutter.dev/docs',
                  ),
                  _buildResourceLinkItem(
                    icon: Icons.book,
                    title: 'Sách: Flutter in Action',
                    url: 'https://www.manning.com/books/flutter-in-action',
                  ),
                  _buildResourceLinkItem(
                    icon: Icons.video_library,
                    title: 'Video: Flutter Crash Course',
                    url: 'https://www.youtube.com/watch?v=1gDhl4leEzA',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Download summary button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang tải tóm tắt bài học dưới dạng PDF'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Tải xuống tóm tắt bài học'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
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
        setState(() {
          this.result = result;
          // Cập nhật trạng thái hoàn thành nếu đạt điểm
          if (result >= 5.0) {
            _completedLessons[lesson.id] = true;
            _unlockNextLesson(lesson.id);
          }
        });

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
}
