import 'package:flutter/material.dart';
import 'package:tms_app/data/models/my_course/learn_lesson_model.dart'
    hide Lesson;
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_summary_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/lesson_materials_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/comment_section_widget.dart';
import 'package:tms_app/presentation/widgets/my_course/complete_lesson_button.dart';

class LessonContentWidget extends StatelessWidget {
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tiêu đề bài học
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
                    // Nút bài trước
                    IconButton(
                      onPressed:
                          canNavigateToPrevious ? onPreviousLesson : null,
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

                    // Nút bài tiếp
                    IconButton(
                      onPressed: canNavigateToNext ? onNextLesson : null,
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
                          color: completedLessons[currentLesson.id] == true
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              completedLessons[currentLesson.id] == true
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 12,
                              color: completedLessons[currentLesson.id] == true
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              completedLessons[currentLesson.id] == true
                                  ? 'Đã hoàn thành'
                                  : 'Chưa hoàn thành',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    completedLessons[currentLesson.id] == true
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
                controller: tabController,
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
              controller: tabController,
              children: [
                // Tab 1: Video hoặc Bài kiểm tra
                SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: currentLesson.type == LessonType.video
                      ? _buildVideoLessonContent(context)
                      : _buildTestLessonContent(context),
                ),

                // Tab 2: Tài liệu
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LessonMaterialsWidget(
                    materials: materials,
                    lessonTitle: currentLesson.title,
                  ),
                ),

                // Tab 3: Tóm tắt
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LessonSummaryWidget(
                    lesson: currentLesson,
                    summary: summary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget nội dung bài học video
  Widget _buildVideoLessonContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () {
                      // Handle video tap
                    },
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video placeholder
                          videoUrl != null && videoUrl!.isNotEmpty
                              ? Image.network(
                                  'https://img.youtube.com/vi/default/maxresdefault.jpg',
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

                // Video URL info (for debugging)
                if (videoUrl != null && videoUrl!.isNotEmpty)
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
                          videoUrl!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => openVideoInExternalPlayer(videoUrl!),
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
                  onCommentSubmit: onCommentSubmit,
                ),

                // Space for the fixed button
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Fixed "Complete" button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CompleteLessonButton(
              isCompleted: completedLessons[currentLesson.id] == true,
              onComplete: onCompleteLesson,
            ),
          ),
        ],
      ),
    );
  }

  // Widget nội dung bài kiểm tra
  Widget _buildTestLessonContent(BuildContext context) {
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
                          currentLesson.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian: ${currentLesson.duration} | ${currentLesson.questionCount} câu hỏi',
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
                    _buildTestInstruction(
                      icon: Icons.timer,
                      text: 'Thời gian làm bài: ${currentLesson.duration}',
                    ),
                    const SizedBox(height: 8),
                    _buildTestInstruction(
                      icon: Icons.question_answer,
                      text: 'Số câu hỏi: ${currentLesson.questionCount} câu',
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
            onPressed: completedLessons[currentLesson.id] == true
                ? () => showTestResults()
                : () => startTest(),
            icon: Icon(completedLessons[currentLesson.id] == true
                ? Icons.assessment
                : Icons.play_arrow),
            label: Text(
              completedLessons[currentLesson.id] == true
                  ? 'Xem lại kết quả'
                  : 'Bắt đầu làm bài',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: completedLessons[currentLesson.id] == true
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
}
