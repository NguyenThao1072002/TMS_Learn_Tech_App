import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';

class StructuredCourseTab extends StatefulWidget {
  final CourseCardModel course;
  final List<StructureCourseModel> structureCourse;
  final bool isLoading;
  final bool isPurchased;
  final String totalDuration;
  final Function navigateToCart;
  final bool isDarkMode;

  const StructuredCourseTab({
    Key? key,
    required this.course,
    required this.structureCourse,
    required this.isLoading,
    required this.isPurchased,
    required this.totalDuration,
    required this.navigateToCart,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<StructuredCourseTab> createState() => _StructuredCourseTabState();
}

class _StructuredCourseTabState extends State<StructuredCourseTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final bool hasNotPurchased = !widget.isPurchased;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin khóa học
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Text(
                      "Nội dung khóa học",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildCourseStatItem(Icons.access_time, "Thời lượng",
                    "${widget.totalDuration} giờ học"),
                SizedBox(height: 8),
                _buildCourseStatItem(Icons.playlist_play, "Số bài học",
                    "${_calculateTotalLessons()} bài học"),
                SizedBox(height: 8),
                _buildCourseStatItem(Icons.quiz, "Bài test tổng kết",
                    "${_calculateNumberOfTests()} bài kiểm tra"),
                if (hasNotPurchased) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Bạn có thể học thử một số bài học trước khi quyết định mua khóa học",
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24),

          // Danh sách các chương và bài học
          if (widget.structureCourse.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Nội dung khóa học đang được cập nhật...",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ..._buildChaptersList(hasNotPurchased),

          SizedBox(height: 32),

          // Call to action - Chỉ hiển thị nếu chưa mua
          if (hasNotPurchased)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Mở khóa toàn bộ nội dung khóa học",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Đăng ký ngay để truy cập đầy đủ các bài học, bài tập thực hành và nhận hỗ trợ từ giảng viên",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => widget.navigateToCart(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        "Đăng ký khóa học",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _calculateTotalLessons() {
    int total = 0;
    for (var chapter in widget.structureCourse) {
      total += chapter.videoDTOUserViewList.length;
    }
    return total;
  }

  int _calculateNumberOfTests() {
    // Tính số bài kiểm tra trong toàn bộ khóa học
    int total = 0;
    for (var chapter in widget.structureCourse) {
      for (var video in chapter.videoDTOUserViewList) {
        if (video.videoTitle.toLowerCase().contains('test') ||
            video.videoTitle.toLowerCase().contains('quiz') ||
            video.videoTitle.toLowerCase().contains('kiểm tra')) {
          total++;
        }
      }
    }
    return total;
  }

  List<Widget> _buildChaptersList(bool hasNotPurchased) {
    if (widget.structureCourse.isEmpty) return [];

    List<Widget> chapterWidgets = [];

    // Hiển thị tất cả các chương
    for (int i = 0; i < widget.structureCourse.length; i++) {
      final chapter = widget.structureCourse[i];
      if (i > 0) chapterWidgets.add(SizedBox(height: 16));

      List<Widget> lessonWidgets = [];
      for (var video in chapter.videoDTOUserViewList) {
        bool isFreePreview =
            video.videoId % 5 == 0; // Giả định: mỗi video thứ 5 là preview
        bool canAccess =
            !hasNotPurchased || isFreePreview; // Đã mua hoặc là video xem thử

        String durationText = _formatDuration(video.videoDuration);

        lessonWidgets.add(
          _buildModernLessonItem(
            video.videoTitle,
            durationText,
            canAccess,
            isVideo: true,
            isFreePreview: isFreePreview,
            isCompleted: video.viewTest,
          ),
        );
      }

      chapterWidgets.add(
        _buildModernChapterItem(
          "Chương ${chapter.chapterId}",
          chapter.chapterTitle,
          i == 0, // Chỉ mở rộng chương đầu tiên
          lessons: lessonWidgets,
        ),
      );
    }

    return chapterWidgets;
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int remainingSeconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes}:${remainingSeconds.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildCourseStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.blue.shade600,
          ),
        ),
        SizedBox(width: 12),
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernChapterItem(
      String chapterNumber, String title, bool isExpanded,
      {List<Widget> lessons = const []}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    chapterNumber.split(" ")[1],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: lessons.isNotEmpty
              ? lessons
              : [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Center(
                      child: Text(
                        "Nội dung đang được cập nhật...",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildModernLessonItem(
    String title,
    String duration,
    bool canAccess, {
    required bool isVideo,
    bool isCompleted = false,
    bool isFreePreview = false,
    bool isQuiz = false,
    bool isPractice = false,
  }) {
    final IconData typeIcon = isVideo
        ? Icons.videocam
        : isQuiz
            ? Icons.quiz
            : isPractice
                ? Icons.code
                : Icons.insert_drive_file;

    final Color typeColor = isVideo
        ? Colors.red
        : isQuiz
            ? Colors.purple
            : isPractice
                ? Colors.teal
                : Colors.blue;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFreePreview ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Icon(
                isFreePreview ? Icons.play_arrow : Icons.lock,
                size: 18,
                color: isFreePreview ? Colors.green : Colors.grey.shade500,
              ),
            ),
          ),
          if (isFreePreview)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: canAccess ? FontWeight.w500 : FontWeight.normal,
                color: canAccess ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
          if (isFreePreview)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Học thử",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeIcon,
            size: 16,
            color: canAccess ? typeColor : Colors.grey.shade400,
          ),
          SizedBox(width: 4),
          Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              color: canAccess ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
      onTap: () {
        if (canAccess || isFreePreview) {
          // Xử lý mở bài học
          if (isVideo) {
            // Mở video
            showDialog(
              context: context,
              builder: (context) => _VideoPreviewDialog(
                title: title,
                isFreePreview: isFreePreview,
              ),
            );
          } else if (isQuiz) {
            // Mở quiz
          } else if (isPractice) {
            // Mở bài thực hành
          } else {
            // Mở tài liệu
          }
        }
      },
    );
  }
}

// VideoPreviewDialog embedded in the file
class _VideoPreviewDialog extends StatelessWidget {
  final String title;
  final bool isFreePreview;

  const _VideoPreviewDialog({
    Key? key,
    required this.title,
    this.isFreePreview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isFreePreview)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Học thử",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Video content
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Progress bar
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "00:00 / 10:30",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.volume_up,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 12),
                                  Icon(Icons.fullscreen,
                                      color: Colors.white, size: 16),
                                ],
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

            // Video footer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "1x",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.skip_previous, color: Colors.white, size: 24),
                      SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.skip_next, color: Colors.white, size: 24),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.repeat, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Lặp",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
}
