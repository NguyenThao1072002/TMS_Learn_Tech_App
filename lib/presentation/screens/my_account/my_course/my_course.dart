import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart';
import 'package:tms_app/data/models/my_course/my_course_list_model.dart';
import 'package:tms_app/data/models/my_course/recent_lesson_model.dart';
import 'package:tms_app/domain/usecases/my_course/my_course_list_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/course_lesson_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/recent_lesson_usecase.dart';
import 'package:tms_app/data/repositories/my_course/my_course_list_repository_impl.dart';
import 'package:tms_app/data/services/my_course/my_course_list_service.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:get_it/get_it.dart';
import 'package:confetti/confetti.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:tms_app/presentation/controller/my_course/my_course_controller.dart';
import 'package:tms_app/domain/repositories/my_course/recent_lesson_reporitory.dart';
import 'package:tms_app/data/repositories/my_course/recent_lesson_reporitory_impl.dart';
import 'package:tms_app/data/services/my_course/recent_lesson_services.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({Key? key}) : super(key: key);

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  bool _isLoading = false;
  ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  // Controller for recent lessons
  late MyCourseController _myCourseController;

  // Use model data instead of fake data
  MyCourseListResponse _courseListResponse = MyCourseListResponse(
    totalElements: 0,
    totalPages: 0,
    pageable: PageableInfo(
      pageNumber: 0,
      pageSize: 10,
      sort: SortInfo(sorted: true, empty: false, unsorted: false),
      offset: 0,
      paged: true,
      unpaged: false,
    ),
    size: 10,
    content: [],
    number: 0,
    sort: SortInfo(sorted: true, empty: false, unsorted: false),
    first: true,
    last: true,
    numberOfElements: 0,
    empty: true,
  );

  String _currentStatus = 'Actived'; // Actived, Studying, Completed

  // Filtered courses based on search and current tab
  List<MyCourseItem> get _filteredCourses {
    List<MyCourseItem> filteredList = _courseListResponse.content;

    // Lọc thêm theo tiến trình cho tab Studying (nếu tiến trình = 0, không hiển thị trong tab Đang học)
    if (_currentStatus == 'Studying') {
      filteredList =
          filteredList.where((course) => course.progress > 0).toList();
    }

    // Lọc theo tìm kiếm nếu có
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((course) =>
              course.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredList;
  }

  // Recent courses (last viewed)
  List<MyCourseItem> get _recentCourses {
    final sortedCourses = List<MyCourseItem>.from(_courseListResponse.content);
    // Sort by updatedAt date, most recent first
    sortedCourses.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedCourses.take(2).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo controller cách đơn giản nhất
    try {
      print('⚡ Khởi tạo MyCourseController...');
      
      // Tạo các dependencies thủ công
      final dio = GetIt.instance.get<Dio>();
      final recentLessonService = RecentLessonService(dio);
      final recentLessonRepo = RecentLessonRepositoryImpl(recentLessonService);
      final recentLessonUseCase = RecentLessonUseCase(recentLessonRepo);
      
      // Lấy courseLessonUseCase từ GetIt
      final courseLessonUseCase = GetIt.instance.get<CourseLessonUseCase>();
      
      // Tạo controller với các dependencies đã chuẩn bị
      _myCourseController = MyCourseController(
        courseLessonUseCase: courseLessonUseCase,
        recentLessonUseCase: recentLessonUseCase,
      );
      
      print('✅ Đã khởi tạo MyCourseController thành công');
      
      // Load dữ liệu bài học gần đây
      _loadRecentLessons();
    } catch (e) {
      print('❌ Lỗi khi khởi tạo MyCourseController: $e');
      
      // Trường hợp không thành công, vẫn giữ UI hoạt động với recentLessonUseCase là null
      try {
        final courseLessonUseCase = GetIt.instance.get<CourseLessonUseCase>();
        _myCourseController = MyCourseController(
          courseLessonUseCase: courseLessonUseCase,
          recentLessonUseCase: null,
        );
      } catch (e) {
        print('❌ Lỗi nghiêm trọng, không thể khởi tạo controller: $e');
      }
    }
    
    // Xử lý sự kiện khi tab thay đổi (bấm vào tab)
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _handleTabChange();
      }
    });

    _loadCourses();
  }

  // Load recent lessons using the controller
  Future<void> _loadRecentLessons() async {
    await _myCourseController.loadRecentLessons();
    // No need to setState here as the controller will notify listeners
  }

  // Xử lý khi tab thay đổi (cả khi bấm vào tab hoặc vuốt ngang)
  void _handleTabChange() {
    _currentPage = 0; // Reset page when changing tabs
    _updateCurrentStatus();
    // Gọi lại API khi chuyển tab để lấy dữ liệu mới
    _loadCourses();
  }

  void _updateCurrentStatus() {
    switch (_tabController.index) {
      case 0:
        _currentStatus = 'Actived'; // Đã đăng ký
        break;
      case 1:
        _currentStatus = 'Studying'; // Đang học
        break;
      case 2:
        _currentStatus = 'Completed'; // Hoàn thành
        break;
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the usecase from service locator
      final useCase = GetIt.instance<MyCourseListUseCase>();

      // Get user ID from SharedPrefs
      int userId;
      try {
        userId = await SharedPrefs.getUserId() ??
            105; // Sử dụng phương thức đã được cải tiến
      } catch (e) {
        userId = 105; // Fallback to default
      }

      // Call the API using the usecase với status tương ứng với tab hiện tại
      final response = await useCase.getEnrolledCourses(
        accountId: userId,
        page: _currentPage,
        size: _pageSize,
        status: _currentStatus, // Sử dụng status tương ứng với tab hiện tại
        title: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _courseListResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Log error
      debugPrint('❌ Error loading courses: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái dark mode từ Theme hiện tại
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colors based on dark mode
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final borderColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey.shade200;
    final searchBgColor = isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey[100];
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Khóa học của tôi',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey,
            indicatorColor: Colors.orange,
            tabs: const [
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Đã đăng ký',
              ),
              Tab(
                icon: Icon(Icons.play_circle_outline),
                text: 'Đang học',
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Hoàn thành',
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: backgroundColor,
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khóa học...',
                      hintStyle: TextStyle(color: secondaryTextColor),
                      prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                      filled: true,
                      fillColor: searchBgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0; // Reset to first page on new search
                      });
                      _loadCourses(); // Reload with new search query
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.orange))
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (_tabController.index != index) {
                        setState(() {
                          _tabController.animateTo(index);
                          _handleTabChange();
                        });
                      }
                    },
                    children: [
                      _buildCoursesTab(_filteredCourses),
                      _buildCoursesTab(_filteredCourses),
                      _buildCoursesTab(_filteredCourses),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show recommendations or featured courses
          _showRecommendedCourses();
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.lightbulb_outline),
      ),
    );
  }

  Widget _buildCoursesTab(List<MyCourseItem> courses) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final emptyIconColor = isDarkMode ? Colors.grey[600] : Colors.grey[400];
    
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 60, color: emptyIconColor),
            const SizedBox(height: 16),
            Text(
              'Không có khóa học nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // Check if we're on the first tab (All enrolled) to show recently viewed courses
    if (_tabController.index == 0 && _recentCourses.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await _loadCourses();
          await _loadRecentLessons();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently viewed section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã xem gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // View all recently viewed lessons
                    },
                    icon: const Icon(Icons.history,
                        size: 16, color: Colors.orange),
                    label: const Text(
                      'Xem tất cả',
                      style: TextStyle(color: Colors.orange),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            // List of recently viewed lessons
            SizedBox(
              height: 125,
              child: _myCourseController.isLoadingRecentLessons
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 2,
                      ),
                    )
                  : _myCourseController.recentLessons.isEmpty
                      ? Center(
                          child: Text(
                            'Bạn chưa xem bài học nào gần đây',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _myCourseController.recentLessons.length,
                          itemBuilder: (context, index) {
                            final lesson = _myCourseController.recentLessons[index];
                            return _buildRecentLessonItem(lesson);
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: isDarkMode ? const Color(0xFF3A3F55) : null),
            ),
            // All courses section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tất cả khóa học',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            // List of all courses
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _buildCourseListItem(course);
                },
              ),
            ),
          ],
        ),
      );
    }

    // Other tabs just show the course list
    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildCourseListItem(course);
        },
      ),
    );
  }

  // Widget to display a recently viewed lesson
  Widget _buildRecentLessonItem(RecentLessonModel lesson) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey.withOpacity(0.15);
    final placeholderColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDarkMode ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: InkWell(
        onTap: () => _navigateToRecentLesson(lesson),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                lesson.imageCourse,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    color: placeholderColor,
                    child: Center(
                      child: Text(
                        lesson.courseName.isNotEmpty ? lesson.courseName[0] : 'C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Lesson info
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.lessonTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _myCourseController.formatDurationFromSeconds(lesson.duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
  }

  // Navigate to the specific lesson
  void _navigateToRecentLesson(RecentLessonModel lesson) {
    // Get the course ID and lesson ID from the recent lesson
    final courseId = int.parse(lesson.courseId);
    final lessonId = lesson.lessonId;
    
    // Navigate to the EnrollCourseScreen with the course ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnrollCourseScreen(
          courseId: courseId,
          courseTitle: lesson.courseName,
          startOver: false,
          viewAllLessons: false,
          startVideo: true,
          showMaterials: false,
          showLessonContent: true,
          onCommentSubmit: (_) {}, // Placeholder
          currentLesson: Lesson(
            id: lessonId,
            title: lesson.lessonTitle,
            duration: _myCourseController.formatDurationFromSeconds(lesson.duration),
            type: LessonType.video,
            isUnlocked: true,
          ),
          currentChapter: CourseChapter(
            id: lesson.chapterId,
            title: "Chapter",
            lessons: [],
          ),
        ),
      ),
    );
  }

  // Widget to display a course in the list
  Widget _buildCourseListItem(MyCourseItem course) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isCompletedTab = _currentStatus == 'Completed';
    final bool isStudyingTab = _currentStatus == 'Studying';
    
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final placeholderColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: isDarkMode ? 0 : 4,
      shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.3),
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _navigateToCourseDetail(course);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isDarkMode ? BoxDecoration(
            border: Border.all(color: const Color(0xFF3A3F55), width: 1),
            borderRadius: BorderRadius.circular(12),
          ) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Course image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        course.imageUrl,
                        width: 120,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 80,
                            color: placeholderColor,
                            child: Center(
                              child: Text(
                                course.title.isNotEmpty ? course.title[0] : 'C',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Badge for completed courses - only in completed tab
                      if (isCompletedTab)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (isCompletedTab)
                        // Tab Hoàn thành
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dòng 1: Hiển thị ngày hoàn thành
                            Text(
                              'Hoàn thành: ${_formatDate(course.completedDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Dòng 2: Icon hoàn thành
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Colors.amber[700], size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  'Hoàn thành 100%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        // Tab Đã đăng ký và Đang học
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Hiển thị tên tác giả
                            Text(
                              'Tác giả: ${course.author}',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            // Vòng tròn tiến trình
                            CircularPercentIndicator(
                              radius: 20.0,
                              lineWidth: 4.0,
                              percent:
                                  course.progress > 1.0 ? 1.0 : course.progress,
                              center: Text(
                                '${(course.progress * 100).clamp(0, 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              progressColor:
                                  isStudyingTab ? Colors.orange : Colors.blue,
                              backgroundColor: isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey[300]!,
                            ),
                          ],
                        ),

                      // Chỉ hiển thị chứng chỉ trong tab hoàn thành
                      if (isCompletedTab && course.certificateUrl != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: InkWell(
                            onTap: () => _showCertificate(course.certificateUrl!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 16,
                                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Xem chứng chỉ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }

  // Định dạng ngày tháng
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCourseDetail(MyCourseItem course) {
    // Kiểm tra xem khóa học đã hoàn thành hay chưa
    final bool isCompleted =
        course.completedDate != null || _currentStatus == 'Completed';

    if (isCompleted) {
      // Đối với khóa học đã hoàn thành, hiển thị dialog không có nút "Tiếp tục học"
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          // Play confetti when dialog shows
          _confettiController.play();

          return Stack(
            children: [
              Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tiêu đề với icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.orange,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'KHÓA HỌC ĐÃ HOÀN THÀNH',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Divider line
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      const SizedBox(height: 16),
                      // Thumbnail của khóa học
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          course.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 40),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Thông tin khóa học
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Badge hoàn thành
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Hoàn thành: ${_formatDate(course.completedDate)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Các nút hành động
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Luôn hiển thị nút Xem chứng chỉ cho khóa học đã hoàn thành
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Nếu không có URL chứng chỉ thực, sử dụng URL mẫu hoặc hiển thị thông báo
                                final String certificateUrl = course
                                        .certificateUrl ??
                                    'https://example.com/certificates/default.jpg';
                                _showCertificate(certificateUrl);
                              },
                              icon: const Icon(Icons.workspace_premium,
                                  size: 16, color: Colors.white),
                              label: const Text('Xem chứng chỉ',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToCourseEnroll(course,
                                    showLessonContent: true);
                              },
                              icon: const Icon(Icons.list_alt,
                                  size: 16, color: Colors.white),
                              label: const Text('Xem bài học',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Với khóa học chưa hoàn thành, sử dụng dialog hiện tại
      _showInProgressCourseDialog(course);
    }
  }

  void _showInProgressCourseDialog(MyCourseItem course) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final dialogBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final dividerColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey[300];

        return Dialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề với icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'TIẾP TỤC HỌC',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider line
                Divider(
                  color: dividerColor,
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                // Thumbnail của khóa học
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Thông tin khóa học
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Progress bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Tiến độ: ${(course.progress * 100).clamp(0, 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Các nút hành động
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToCourseEnroll(course,
                              showLessonContent: true);
                        },
                        icon: const Icon(Icons.play_arrow,
                            size: 16, color: Colors.white),
                        label: const Text('Tiếp tục học',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToCourseEnroll(course, showMaterials: true);
                        },
                        icon: const Icon(Icons.folder_open,
                            size: 16, color: Colors.white),
                        label: const Text('Xem tài liệu',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToCourseEnroll(course, viewAllLessons: true);
                        },
                        icon: const Icon(Icons.list,
                            size: 16, color: Colors.white),
                        label: const Text('Xem tất cả bài học',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigate to enrolled course details
  void _navigateToCourseEnroll(
    MyCourseItem course, {
    bool startOver = false,
    bool viewAllLessons = false,
    bool startVideo = false,
    bool showMaterials = false,
    bool showLessonContent = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnrollCourseScreen(
          courseId: course.id,
          courseTitle: course.title,
          startOver: startOver,
          viewAllLessons: viewAllLessons,
          startVideo: startVideo,
          showMaterials: showMaterials,
          showLessonContent: showLessonContent,
          onCommentSubmit: (_) {}, // Hàm rỗng, không làm gì cả
          currentLesson: Lesson(
            id: "1",
            title: "Bài học mẫu",
            duration: "10:00",
            type: LessonType.video,
            isUnlocked: true,
          ),
          currentChapter: CourseChapter(
            id: "1",
            title: "Chương 1",
            lessons: [],
          ),
        ),
      ),
    );
  }

  void _showRecommendedCourses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final sheetBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final dividerColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey[300];

        return Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Khóa học được đề xuất',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider line
              Divider(
                color: dividerColor,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildRecommendCourseCard(
                      'Lập trình Web',
                      'Học HTML, CSS, JavaScript và các framework hiện đại',
                      Colors.blue,
                    ),
                    _buildRecommendCourseCard(
                      'Machine Learning cơ bản',
                      'Giới thiệu về học máy và trí tuệ nhân tạo',
                      Colors.green,
                    ),
                    _buildRecommendCourseCard(
                      'Khoa học dữ liệu',
                      'Phân tích và trực quan hóa dữ liệu với Python',
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendCourseCard(
      String title, String description, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Show course details or enrollment options
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Xem chi tiết'),
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị chứng chỉ trong dialog
  void _showCertificate(String certificateUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final dialogBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final dividerColor = isDarkMode ? const Color(0xFF3A3F55) : Colors.grey[300];
        final placeholderBgColor = isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey[100];

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.amber[700],
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'CHỨNG CHỈ HOÀN THÀNH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(color: dividerColor, thickness: 1),

                // Certificate image in a scrollable container
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: isDarkMode ? Border.all(color: const Color(0xFF3A3F55), width: 1) : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: certificateUrl.toLowerCase().endsWith('.pdf')
                              ? Container(
                                  height: 300,
                                  width: double.infinity,
                                  color: placeholderBgColor,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf,
                                          size: 60, color: Colors.red[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tài liệu PDF',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tải về để xem',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Image.network(
                                  certificateUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 300,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: Colors.orange,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 300,
                                      width: double.infinity,
                                      color: placeholderBgColor,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              size: 60, color: Colors.red[300]),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Không thể tải chứng chỉ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Share certificate - show URL with copy option
                            Navigator.pop(context);
                            _showShareCertificateDialog(certificateUrl);
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text('Chia sẻ',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Download certificate
                            Navigator.pop(context);
                            _downloadCertificate(certificateUrl);
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text('Tải về',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
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

  // Hiển thị dialog chia sẻ chứng chỉ với đường dẫn URL
  void _showShareCertificateDialog(String certificateUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.link_rounded,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIÊN KẾT CHỨNG CHỈ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sao chép để chia sẻ với người khác',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hiển thị đường dẫn trong container có viền
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          certificateUrl,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Nút sao chép và đóng
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ĐÓNG',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Sao chép đường dẫn vào clipboard
                        Clipboard.setData(ClipboardData(text: certificateUrl));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('SAO CHÉP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Download certificate function
  Future<void> _downloadCertificate(String certificateUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Kiểm tra quyền lưu trữ trước khi tải
      if (!await _checkAndRequestStoragePermission()) {
        return; // Không tiếp tục nếu không có quyền
      }

      // Get filename from URL
      String fileName = _getFileNameFromUrl(certificateUrl);

      // Xác định loại file dựa vào phần mở rộng
      final String fileExtension = path.extension(fileName).toLowerCase();
      final bool isPdf = fileExtension == '.pdf';
      final bool isImage =
          ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension);
      final bool isDocument = [
        '.doc',
        '.docx',
        '.ppt',
        '.pptx',
        '.xls',
        '.xlsx',
        '.txt'
      ].contains(fileExtension);

      // Nếu không có phần mở rộng, xác định dựa vào URL
      if (fileExtension.isEmpty) {
        if (certificateUrl.toLowerCase().contains('pdf')) {
          fileName = '$fileName.pdf';
        } else if (certificateUrl.toLowerCase().contains('doc')) {
          fileName = '$fileName.docx';
        } else if (certificateUrl.toLowerCase().contains('ppt')) {
          fileName = '$fileName.pptx';
        } else if (certificateUrl.toLowerCase().contains('xls')) {
          fileName = '$fileName.xlsx';
        } else {
          // Mặc định là ảnh JPG nếu không xác định được
          fileName = '$fileName.jpg';
        }
      }

      // Tạo thư mục TMS_Documents để lưu tất cả các loại tài liệu
      final String dirPath;
      if (Platform.isAndroid) {
        // Lưu tất cả các loại file vào cùng một thư mục trong Download
        dirPath = '/storage/emulated/0/Download/TMS_Documents';

        // Tạo thư mục nếu chưa tồn tại
        final dir = Directory(dirPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        // iOS hoặc các nền tảng khác
        final dir = await getApplicationDocumentsDirectory();
        dirPath = dir.path;
      }

      final String filePath = path.join(dirPath, fileName);

      // Download file
      final Dio dio = Dio(); // Create a new Dio instance

      // Use Dio to download the file
      await dio.download(certificateUrl, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          // Update progress if needed in future
          final progress = (received / total * 100).toStringAsFixed(0);
        }
      });

      // Thông báo Media Scanner về file mới (chỉ cần đối với ảnh)
      if (Platform.isAndroid && isImage) {
        try {
          await _scanFile(filePath);
        } catch (e) {
          // Error handling media scan
        }
      }

      // Open the file after download
      _openDownloadedFile(filePath);
    } catch (e) {
      debugPrint('❌ Error downloading certificate: ${e.toString()}');
    }
  }

  // Kiểm tra và yêu cầu quyền lưu trữ với hướng dẫn chi tiết
  Future<bool> _checkAndRequestStoragePermission() async {
    // Kiểm tra quyền hiện tại
    var status = await Permission.storage.status;

    // Nếu đã được cấp quyền
    if (status.isGranted) {
      return true;
    }

    // Nếu quyền bị từ chối vĩnh viễn, hiển thị hướng dẫn đi tới Cài đặt
    if (status.isPermanentlyDenied) {
      bool shouldOpenSettings = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Cần cấp quyền lưu trữ'),
              content: const Text(
                  'Ứng dụng cần quyền truy cập bộ nhớ để tải và lưu tài liệu. '
                  'Vui lòng vào Cài đặt và cấp quyền "Lưu trữ" cho ứng dụng.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Để sau'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Mở Cài đặt'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldOpenSettings) {
        await openAppSettings();
      }

      return false;
    }

    // Nếu chưa yêu cầu quyền, hiển thị hướng dẫn và yêu cầu
    bool shouldRequest = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Cấp quyền lưu trữ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/storage_permission.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.storage, size: 80, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ứng dụng cần quyền truy cập bộ nhớ để tải và lưu tài liệu vào thư mục TMS_Documents. '
                  'Vui lòng chọn "Cho phép" trong hộp thoại tiếp theo.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldRequest) {
      return false;
    }

    // Yêu cầu quyền
    status = await Permission.storage.request();

    // Kiểm tra lại sau khi yêu cầu
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  // Thông báo cho Media Scanner về file mới
  Future<void> _scanFile(String filePath) async {
    try {
      // Tạm thời ghi file .nomedia rồi xóa đi để trigger media scanner
      final nomediaPath = path.join(path.dirname(filePath), '.temp_trigger');
      final nomediaFile = File(nomediaPath);
      await nomediaFile.writeAsString('trigger media scan');
      await nomediaFile.delete();
    } catch (e) {
      // Error handling media scan
    }
  }

  // Get file name from URL
  String _getFileNameFromUrl(String url) {
    // Try to get filename from content-disposition header or fallback to URL path
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;

    // Remove query parameters if any
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }

    // Use a default name if empty
    if (fileName.isEmpty) {
      fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}';
    }

    return fileName;
  }

  // Open downloaded file
  Future<void> _openDownloadedFile(String filePath) async {
    try {
      File file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ Error: File does not exist - $filePath');
        return;
      }

      // Thử mở file bằng intent mặc định
      try {
        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          debugPrint('❌ Error opening file: ${result.message}');
        }
      } catch (e) {
        // Log error
        debugPrint('❌ Cannot open file: $e');
      }
    } catch (e) {
      debugPrint('❌ File operation error: $e');
    }
  }
}
