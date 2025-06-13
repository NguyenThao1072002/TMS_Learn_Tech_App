import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart';
import 'package:tms_app/presentation/widgets/my_course/comment_item_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/complete_lesson_button.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_materials_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_summary_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:tms_app/core/services/video_player_service.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/presentation/controller/my_course/course_progress_controller.dart';
import 'package:tms_app/core/auth/auth_manager.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/services/my_course/course_progress_service.dart';
// import 'package:tms_app/data/repositories/course_progress_repository.dart';
import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/domain/repositories/my_course/course_progress_repository.dart';

class LessonContentWidget extends StatefulWidget {
  final CourseChapter currentChapter;
  final Lesson currentLesson;
  final Map<String, bool> completedLessons;
  final TabController tabController;
  final String summary;
  final String? videoUrl;
  final List<MaterialItem> materials;
  final Function(String) onCommentSubmit;
  final VoidCallback onCompleteLesson;
  final VoidCallback onPreviousLesson;
  final VoidCallback onNextLesson;
  final bool canNavigateToPrevious;
  final bool canNavigateToNext;
  final Function() showTestResults;
  final Function() startTest;
  final Function(String) openVideoInExternalPlayer;

  // Function to build lesson detail info
  final Widget Function(Lesson lesson)? buildLessonDetailInfo;

  const LessonContentWidget({
    Key? key,
    required this.currentChapter,
    required this.currentLesson,
    required this.completedLessons,
    required this.tabController,
    required this.summary,
    required this.videoUrl,
    required this.materials,
    required this.onCommentSubmit,
    required this.onCompleteLesson,
    required this.onPreviousLesson,
    required this.onNextLesson,
    required this.canNavigateToPrevious,
    required this.canNavigateToNext,
    required this.showTestResults,
    required this.startTest,
    required this.openVideoInExternalPlayer,
    this.buildLessonDetailInfo,
  }) : super(key: key);

  @override
  State<LessonContentWidget> createState() => _LessonContentWidgetState();
}

class _LessonContentWidgetState extends State<LessonContentWidget> {
  // Controller cho video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo video player nếu có URL video
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      // Tự động khởi tạo video ngay lập tức không cần delay
      _initializeVideoPlayer();
    }
  }

  @override
  void didUpdateWidget(LessonContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khởi tạo lại video player nếu URL video thay đổi
    if (widget.videoUrl != oldWidget.videoUrl) {
      _disposeVideoPlayer();
      if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _initializeVideoPlayer();
      }
    }

    // Thêm log để kiểm tra khi nào widget được cập nhật và dữ liệu hiện tại
    print('📱 didUpdateWidget được gọi trong LessonContentWidget');
    print('   - Chương hiện tại: ${widget.currentChapter.title}');
    print('   - Bài học hiện tại: ${widget.currentLesson.title}');
    print('   - Có thể chuyển bài tiếp: ${widget.canNavigateToNext}');
    print(
        '   - Đã hoàn thành: ${widget.completedLessons[widget.currentLesson.id] == true}');

    // In ra toàn bộ danh sách bài học đã hoàn thành
    print('   - Danh sách bài học đã hoàn thành:');
    widget.completedLessons.forEach((key, value) {
      print('     + Bài học ID: $key, Hoàn thành: $value');
    });
  }

  // Khởi tạo video player
  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isVideoInitialized = false;
      });

      // Xử lý URL qua service
      String cleanUrl = VideoPlayerService.processVideoUrl(widget.videoUrl!);

      // Sử dụng service để tạo ChewieController
      _chewieController = await VideoPlayerService.initializeChewieController(
        videoUrl: cleanUrl,
        autoPlay: false, // Thay đổi: không tự động phát khi tải xong
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      // Lấy và thiết lập controller từ Chewie
      if (_chewieController != null) {
        _videoPlayerController = _chewieController!.videoPlayerController;

        // Lắng nghe sự kiện kết thúc video để đánh dấu hoàn thành bài học
        _videoPlayerController!.addListener(_videoPlayerListener);

        // Cập nhật UI
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isPlaying = false; // Thay đổi: cập nhật trạng thái là không phát
          });
        }
      } else {
        throw Exception("Không thể tạo Chewie Controller");
      }
    } catch (e) {
      print("Lỗi khi khởi tạo video player: $e");
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _videoPlayerListener() {
    // Kiểm tra nếu video đã kết thúc
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized &&
        _videoPlayerController!.value.position >=
            _videoPlayerController!.value.duration) {
      // Video đã kết thúc, đánh dấu hoàn thành bài học
      if (mounted && widget.completedLessons[widget.currentLesson.id] != true) {
        print("🏁 Video đã kết thúc, đánh dấu hoàn thành bài học");
        widget.onCompleteLesson(); // Đánh dấu hoàn thành bài học
      }
    }
  }

  // Giải phóng controller khi widget bị hủy
  void _disposeVideoPlayer() {
    try {
      if (_chewieController != null) {
        _chewieController!.dispose();
        _chewieController = null;
      }

      if (_videoPlayerController != null) {
        _videoPlayerController!.removeListener(_videoPlayerListener);
        _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }

      _isVideoInitialized = false;
      _isPlaying = false;
    } catch (e) {
      print('Lỗi khi dispose video controller: $e');
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  // Phương thức để chuyển đổi trạng thái play/pause
  void _togglePlayPause() {
    if (_videoPlayerController == null || !_isVideoInitialized) return;

    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _isPlaying = false;
      } else {
        _videoPlayerController!.play();
        _isPlaying = true;
      }
    });
  }

  // Phương thức để chuyển đổi chế độ toàn màn hình
  void _toggleFullScreen() {
    if (_chewieController == null) return;

    _chewieController!.toggleFullScreen();
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Thêm log để kiểm tra khi widget build được gọi
    print('📱 build được gọi trong LessonContentWidget');
    print('   - Chương hiện tại: ${widget.currentChapter.title}');
    print('   - Bài học hiện tại: ${widget.currentLesson.title}');
    print('   - Có thể chuyển bài tiếp: ${widget.canNavigateToNext}');
    print(
        '   - Đã hoàn thành: ${widget.completedLessons[widget.currentLesson.id] == true}');
    print('   - ID bài học hiện tại: ${widget.currentLesson.id}');

    // Kiểm tra xem ID bài học có đúng định dạng không
    final lessonId = widget.currentLesson.id;
    print('   - Kiểu dữ liệu của lessonId: ${lessonId.runtimeType}');

    // Kiểm tra completedLessons có chứa lessonId không
    print(
        '   - completedLessons có chứa lessonId không: ${widget.completedLessons.containsKey(lessonId)}');

    // In ra toàn bộ danh sách bài học đã hoàn thành
    print('   - Danh sách bài học đã hoàn thành:');
    widget.completedLessons.forEach((key, value) {
      print('     + Bài học ID: $key, Hoàn thành: $value');
    });

    // Check for dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tiêu đề bài học
          if (!_isFullScreen)
            Container(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.black.withOpacity(0.05),
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
                      // Nút bài trước
                      IconButton(
                        onPressed: widget.canNavigateToPrevious
                            ? widget.onPreviousLesson
                            : null,
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        tooltip: 'Bài trước',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        style: IconButton.styleFrom(
                          backgroundColor: isDarkMode 
                              ? Color(0xFF252525) 
                              : Colors.grey[100],
                          foregroundColor: isDarkMode 
                              ? Colors.white 
                              : Colors.grey[800],
                          disabledBackgroundColor: isDarkMode 
                              ? Color(0xFF1A1A1A) 
                              : Colors.grey[100],
                          disabledForegroundColor: isDarkMode 
                              ? Colors.grey[700] 
                              : Colors.grey[400],
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
                                    'Chương ${widget.currentChapter.id}',
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
                                    widget.currentChapter.title
                                                .split(':')
                                                .length >
                                            1
                                        ? widget.currentChapter.title
                                            .split(':')[1]
                                            .trim()
                                        : widget.currentChapter.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode 
                                          ? Colors.grey[400] 
                                          : Colors.grey[700],
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
                              widget.currentLesson.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Nút bài tiếp
                      IconButton(
                        onPressed: () {
                          print("📱 Nhấn nút bài tiếp ở header");
                          if (widget.canNavigateToNext) {
                            widget.onNextLesson();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        tooltip: 'Bài tiếp',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        style: IconButton.styleFrom(
                          backgroundColor: widget.canNavigateToNext
                              ? Colors.orange
                              : isDarkMode 
                                  ? Color(0xFF252525) 
                                  : Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDarkMode 
                              ? Color(0xFF1A1A1A) 
                              : Colors.grey[300],
                          disabledForegroundColor: isDarkMode 
                              ? Colors.grey[700] 
                              : Colors.grey[400],
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
                              widget.currentLesson.type == LessonType.video
                                  ? Icons.videocam
                                  : Icons.assignment,
                              size: 14,
                              color: isDarkMode 
                                  ? Colors.grey[400] 
                                  : Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.currentLesson.duration,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode 
                                    ? Colors.grey[400] 
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),

                        // Trạng thái bài học
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.completedLessons[
                                        widget.currentLesson.id] ==
                                    true
                                ? Colors.green.withOpacity(0.1)
                                : isDarkMode 
                                    ? Color(0xFF252525) 
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.completedLessons[
                                            widget.currentLesson.id] ==
                                        true
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 12,
                                color: widget.completedLessons[
                                            widget.currentLesson.id] ==
                                        true
                                    ? Colors.green
                                    : isDarkMode 
                                        ? Colors.grey[500] 
                                        : Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.completedLessons[
                                            widget.currentLesson.id] ==
                                        true
                                    ? 'Đã hoàn thành'
                                    : 'Chưa hoàn thành',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.completedLessons[
                                              widget.currentLesson.id] ==
                                          true
                                      ? Colors.green
                                      : isDarkMode 
                                          ? Colors.grey[500] 
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

          // TabBar cho nội dung bài học - chỉ hiển thị khi không ở chế độ toàn màn hình
          if (!_isFullScreen)
            SizedBox(
              height: 56,
              child: Material(
                color: isDarkMode ? Colors.black : Colors.white,
                child: TabBar(
                  controller: widget.tabController,
                  labelColor: Colors.orange,
                  unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  indicatorColor: Colors.orange,
                  indicatorWeight: 3,
                  dividerHeight: 1,
                  dividerColor: isDarkMode ? Color(0xFF3A3F55) : Colors.grey[300],
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
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
            child: _isFullScreen
                ? _buildVideoPlayer(isFullScreen: true)
                : TabBarView(
                    controller: widget.tabController,
                    children: [
                      // Tab 1: Video hoặc Bài kiểm tra
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(0),
                        child: widget.currentLesson.type == LessonType.video
                            ? _buildVideoLessonContent(context)
                            : _buildTestLessonContent(context),
                      ),

                      // Tab 2: Tài liệu
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: LessonMaterialsWidget(
                          materials: widget.materials,
                          lessonTitle: widget.currentLesson.title,
                        ),
                      ),

                      // Tab 3: Tóm tắt
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: LessonSummaryWidget(
                          lesson: widget.currentLesson,
                          summary: widget.summary,
                        ),
                      ),
                    ],
                  ),
          ),

          // Hiển thị nút hoàn thành bài học khi không ở chế độ toàn màn hình
          if (!_isFullScreen) _buildCompleteLessonButton(),
        ],
      ),
    );
  }

  // Widget xây dựng trình phát video
  Widget _buildVideoPlayer({bool isFullScreen = false}) {
    if (_videoPlayerController == null ||
        !_isVideoInitialized ||
        _chewieController == null) {
      // Chỉ hiển thị hiệu ứng loading đơn giản
      return Container(
        width: double.infinity,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    // Sử dụng Chewie để phát video
    return AspectRatio(
      aspectRatio: isFullScreen
          ? MediaQuery.of(context).size.width /
              MediaQuery.of(context).size.height
          : _videoPlayerController!.value.aspectRatio,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

  // Phương thức khởi tạo và phát video
  Future<void> _initializeAndPlayVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return;
    }

    if (!_isVideoInitialized) {
      // Tải video mà không hiển thị thông báo
      await _initializeVideoPlayer();
    }

    // Không tự động phát video sau khi khởi tạo
    // Đã bỏ đoạn code tự động phát
    setState(() {
      _isPlaying = _videoPlayerController?.value.isPlaying ?? false;
    });
  }

  // Định dạng thời gian từ giây sang MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Widget nội dung bài học video
  Widget _buildVideoLessonContent(BuildContext context) {
    // Lấy ID video và ID bài học từ currentLesson
    final int videoId = widget.currentLesson.videoId ?? 0;
    final int lessonId = int.parse(widget.currentLesson.id);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player
          Container(
            color: Colors.black,
            child: _buildVideoPlayer(),
          ),

          // Thông tin chi tiết về video
          if (widget.buildLessonDetailInfo != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.buildLessonDetailInfo!(widget.currentLesson),
            ),

          // Comment section - Sử dụng CommentSectionWidget mới
          CommentSectionWidget(
            onCommentSubmit: widget.onCommentSubmit,
            videoId: videoId,
            lessonId: lessonId,
          ),
        ],
      ),
    );
  }

  // Widget nội dung bài kiểm tra
  Widget _buildTestLessonContent(BuildContext context) {
    // Make sure to dispose any video player when showing test content
    if (_videoPlayerController != null) {
      _disposeVideoPlayer();
    }
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                          widget.currentLesson.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian: ${widget.currentLesson.duration} | ${widget.currentLesson.questionCount} câu hỏi',
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
                  color: isDarkMode ? Color(0xFF252525) : Colors.white,
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
                    _buildTestInstruction(
                      icon: Icons.timer,
                      text:
                          'Thời gian làm bài: ${widget.currentLesson.duration}',
                    ),
                    const SizedBox(height: 8),
                    _buildTestInstruction(
                      icon: Icons.question_answer,
                      text:
                          'Số câu hỏi: ${widget.currentLesson.questionCount} câu',
                    ),
                    const SizedBox(height: 8),
                    const _buildTestInstruction(
                      icon: Icons.check_circle,
                      text: 'Điểm đạt: 70% số câu trả lời đúng',
                    ),
                    const SizedBox(height: 8),
                    const _buildTestInstruction(
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
            color: isDarkMode ? Color(0xFF252525) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin quan trọng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bài kiểm tra này đánh giá kiến thức của bạn về nội dung đã học. Bạn cần đạt tối thiểu 70% số câu đúng để vượt qua và mở khóa bài học tiếp theo.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDarkMode ? Colors.grey[300] : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lưu ý:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
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
            onPressed: widget.completedLessons[widget.currentLesson.id] == true
                ? () => widget.showTestResults()
                : () => widget.startTest(),
            icon: Icon(widget.completedLessons[widget.currentLesson.id] == true
                ? Icons.assessment
                : Icons.play_arrow),
            label: Text(
              widget.completedLessons[widget.currentLesson.id] == true
                  ? 'Xem lại kết quả'
                  : 'Bắt đầu làm bài',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.completedLessons[widget.currentLesson.id] == true
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

  // Widget để hiển thị nút hoàn thành bài học
  Widget _buildCompleteLessonButton() {
    // Lấy ID bài học hiện tại
    final String lessonId = widget.currentLesson.id;

    // Kiểm tra trạng thái hoàn thành
    final bool isCompleted = widget.completedLessons[lessonId] == true;

    final bool hasTest = widget.currentLesson.testType != null;
    final bool canNavigate = widget.canNavigateToNext;

    print('🔍 LessonContentWidget: Hiển thị CompleteLessonButton');
    print('   - isCompleted: $isCompleted');
    print('   - hasTest: $hasTest');
    print('   - canNavigateToNext: $canNavigate');
    print('   - currentLessonId: $lessonId');
    print('   - completedLessons: ${widget.completedLessons}');

    return CompleteLessonButton(
      isCompleted: isCompleted,
      onComplete: () async {
        print('📢 LessonContentWidget: Gọi onCompleteLesson từ UI');

        if (!isCompleted && !hasTest) {
          // Gọi API mở khóa bài học tiếp theo
          try {
            // Lấy thông tin người dùng từ SharedPrefs
            final accountId =
                await SharedPrefs.getUserId().then((id) => id.toString());

            // Lấy ID khóa học từ context
            final enrollCourse =
                context.findAncestorWidgetOfExactType<EnrollCourseScreen>();
            if (enrollCourse == null) {
              print('❌ Không thể lấy courseId từ EnrollCourseScreen');
              return;
            }

            // Gọi API trực tiếp bằng Dio
            final dio = GetIt.instance<Dio>();
            final baseUrl = Constants.BASE_URL;

            print(
                '🔄 Gọi API mở khóa bài học tiếp theo: accountId=$accountId, courseId=${enrollCourse.courseId}, chapterId=${widget.currentChapter.id}, lessonId=$lessonId');

            await dio.post(
              '$baseUrl/api/progress/unlock-next',
              queryParameters: {
                'accountId': accountId,
                'courseId': enrollCourse.courseId.toString(),
                'chapterId': widget.currentChapter.id,
                'lessonId': lessonId,
              },
            );

            print('✅ Đã mở khóa bài học tiếp theo thành công');
          } catch (e) {
            print('❌ Lỗi khi mở khóa bài học tiếp theo: $e');
          }
        }

        // Đánh dấu hoàn thành bài học trong UI
        widget.onCompleteLesson();

        // Cập nhật UI
        setState(() {});
      },
      hasTest: hasTest,
      onStartTest: hasTest ? () => widget.startTest() : null,
      onNextLesson: canNavigate ? widget.onNextLesson : null,
      // Không cần truyền thông báo lỗi vì không dùng controller
      errorMessage: null,
    );
  }
}

class _buildTestInstruction extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _buildTestInstruction({
    Key? key,
    required this.icon,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final defaultTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[800];
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? defaultColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color ?? defaultTextColor,
          ),
        ),
      ],
    );
  }
}
