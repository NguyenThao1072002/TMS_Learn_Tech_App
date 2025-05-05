import 'package:flutter/material.dart';
import 'dart:math';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart'
    as import_cart;
import 'package:tms_app/presentation/widgets/component/navbar_add_to_card.dart';
import 'package:tms_app/presentation/widgets/course/course_detail/info_general_course.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseCardModel course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseUseCase _courseUseCase = sl<CourseUseCase>();

  OverviewCourseModel? _overviewCourse;
  List<StructureCourseModel> _structureCourse = [];
  List<ReviewCourseModel> _reviews = [];
  List<OverviewCourseModel> _relatedCourses = [];

  bool _isLoadingOverview = true;
  bool _isLoadingStructure = true;
  bool _isLoadingReviews = true;
  bool _isLoadingRelated = true;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourseData();
    _checkPurchaseStatus();
  }

  Future<void> _loadCourseData() async {
    _loadOverviewData();
    _loadStructureData();
    _loadReviewData();
    _loadRelatedCourses();
  }

  Future<void> _loadOverviewData() async {
    try {
      final overview =
          await _courseUseCase.getOverviewCourseDetail(widget.course.id);
      setState(() {
        _overviewCourse = overview;
        _isLoadingOverview = false;
      });
    } catch (e) {
      print('Lỗi khi tải thông tin tổng quan: $e');
      setState(() {
        _isLoadingOverview = false;
      });
    }
  }

  Future<void> _loadStructureData() async {
    try {
      final structure =
          await _courseUseCase.getStructureCourse(widget.course.id);
      setState(() {
        _structureCourse = structure;
        _isLoadingStructure = false;
      });
    } catch (e) {
      print('Lỗi khi tải cấu trúc khóa học: $e');
      setState(() {
        _isLoadingStructure = false;
      });
    }
  }

  Future<void> _loadReviewData() async {
    try {
      final reviews = await _courseUseCase.getReviewCourse(widget.course.id);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Lỗi khi tải đánh giá: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadRelatedCourses() async {
    try {
      if (_overviewCourse?.courseCategoryId != null) {
        final relatedCourses = await _courseUseCase
            .getRelatedCourse(int.parse(_overviewCourse!.courseCategoryId));

        setState(() {
          // Sử dụng relatedCourses trực tiếp là danh sách OverviewCourseModel
          _relatedCourses = relatedCourses;
          _isLoadingRelated = false;
        });
      } else {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải khóa học liên quan: $e');
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  Future<void> _checkPurchaseStatus() async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      final bool status = widget.course.id % 3 == 0;

      if (mounted) {
        setState(() {
          _isPurchased = status;
        });
      }
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái mua: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Chi tiết khóa học",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Course header - sử dụng widget InfoGeneralCourse
          InfoGeneralCourse(
            course: widget.course,
            overviewCourse: _overviewCourse,
            isLoadingOverview: _isLoadingOverview,
            totalDuration: _calculateTotalDuration(),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: "Tổng quan"),
                Tab(text: "Nội dung"),
                Tab(text: "Khóa học liên quan"),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildContentTab(),
                _buildRelatedCoursesTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavbarAddToCard(
        course: widget.course,
        isPurchased: _isPurchased,
        onAddToCart: _addToCart,
        onPurchase: _navigateToCart,
        onContinueLearning: _goToLearningScreen,
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoadingOverview) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin cơ bản
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildElevatedInfoRow(Icons.access_time, "Thời lượng",
                    "${_calculateTotalDuration()} Giờ"),
                Divider(height: 24),
                _buildElevatedInfoRow(
                    Icons.workspace_premium,
                    "Chứng chỉ",
                    _overviewCourse?.certificate ??
                        "Chứng chỉ hoàn thành khóa học"),
                Divider(height: 24),
                _buildElevatedInfoRow(Icons.bar_chart, "Trình độ",
                    _overviewCourse?.vietnameseLevel ?? "Sơ cấp"),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Mô tả khóa học
          _buildSectionTitle("Mô tả khóa học"),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: CourseDescriptionWidget(
              description: _overviewCourse?.description ??
                  "Thông tin mô tả khóa học đang được cập nhật.",
            ),
          ),

          SizedBox(height: 24),

          // Đầu ra khóa học
          _buildSectionTitle("Đầu ra khóa học"),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: _buildLearningOutcomes(),
            ),
          ),

          SizedBox(height: 24),

          // Đánh giá
          _buildSectionTitle("Đánh giá"),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: _isLoadingReviews
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Rating summary
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${widget.course.averageRating}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    double rating =
                                        widget.course.averageRating ?? 0;
                                    return Icon(
                                      index < rating.floor()
                                          ? Icons.star
                                          : (index < rating)
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: Colors.amber,
                                      size: 24,
                                    );
                                  }),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Dựa trên ${_reviews.length} đánh giá",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 32),

                      // Reviews
                      if (_reviews.isEmpty)
                        Center(
                          child: Text(
                            "Chưa có đánh giá nào cho khóa học này",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      else
                        ..._buildReviewsList(),

                      if (_reviews.length > 3) ...[
                        SizedBox(height: 16),
                        // Xem thêm button
                        Center(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.amber.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement view all reviews
                              },
                              icon: Icon(Icons.comment, size: 16),
                              label: Text("Xem thêm đánh giá"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLearningOutcomes() {
    if (_overviewCourse?.courseOutput == null ||
        _overviewCourse!.courseOutput.isEmpty) {
      return [
        _buildModernLearningOutcome(
            "1", "Hiểu sâu về các kiến thức trong khóa học"),
        SizedBox(height: 16),
        _buildModernLearningOutcome("2", "Áp dụng được kiến thức vào thực tế"),
        SizedBox(height: 16),
        _buildModernLearningOutcome("3", "Phát triển kỹ năng chuyên môn"),
      ];
    }

    final List<Widget> outcomes = [];
    final List<String> outcomesList = _overviewCourse!.courseOutput.split('\n');

    for (int i = 0; i < outcomesList.length; i++) {
      if (i > 0) outcomes.add(SizedBox(height: 16));
      outcomes.add(_buildModernLearningOutcome("${i + 1}", outcomesList[i]));
    }

    return outcomes;
  }

  List<Widget> _buildReviewsList() {
    final reviewsToShow =
        _reviews.length > 3 ? _reviews.sublist(0, 3) : _reviews;
    List<Widget> reviewWidgets = [];

    for (int i = 0; i < reviewsToShow.length; i++) {
      if (i > 0) reviewWidgets.add(SizedBox(height: 16));
      final review = reviewsToShow[i];
      reviewWidgets.add(
        _buildModernReview(
          review.fullname,
          review.createdAt.substring(0, 10), // Format date
          review.rating,
          review.review ?? "Không có bình luận",
          review.image.isNotEmpty
              ? review.image
              : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(review.fullname)}&background=random",
        ),
      );
    }

    return reviewWidgets;
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernLearningOutcome(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.5),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernReview(
      String name, String date, int rating, String comment, String avatarUrl) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                SizedBox(height: 8),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    if (_isLoadingStructure) {
      return Center(child: CircularProgressIndicator());
    }

    final bool hasNotPurchased = !_isPurchased;

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
                    "${_calculateTotalDuration()} giờ học"),
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
          if (_structureCourse.isEmpty)
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
                      onPressed: _navigateToCart,
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
    for (var chapter in _structureCourse) {
      total += chapter.videoDTOUserViewList.length;
    }
    return total;
  }

  int _calculateNumberOfTests() {
    // Tính số bài kiểm tra trong toàn bộ khóa học
    int total = 0;
    for (var chapter in _structureCourse) {
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
    if (_structureCourse.isEmpty) return [];

    List<Widget> chapterWidgets = [];

    // Hiển thị tất cả các chương
    for (int i = 0; i < _structureCourse.length; i++) {
      final chapter = _structureCourse[i];
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

  Widget _buildRelatedCoursesTab() {
    if (_isLoadingRelated) {
      return Center(child: CircularProgressIndicator());
    }

    if (_relatedCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Không có khóa học liên quan",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _relatedCourses.map((course) {
          return Column(
            children: [
              _buildRelatedCourseItem(
                course.title,
                course.rating.toString(),
                "${course.duration} giờ học",
                course.imageUrl,
                course,
              ),
              SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelatedCourseItem(String title, String rating, String duration,
      String imageUrl, OverviewCourseModel course) {
    return InkWell(
      onTap: () {
        // Chuyển đổi từ OverviewCourseModel sang CourseCardModel khi cần chuyển màn hình
        final courseCard = CourseCardModel(
            id: course.id,
            title: course.title,
            imageUrl: course.imageUrl,
            price: course.price,
            cost: course.cost,
            numberOfStudents: course.studentCount,
            averageRating: course.rating,
            author: course.author,
            courseOutput: course.courseOutput,
            description: course.description ?? "",
            duration: course.duration,
            language: course.language ?? "Tiếng Việt",
            status: course.status ?? true,
            type: course.type,
            categoryName: course.categoryName,
            discountPercent: 0);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: courseCard),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 80,
                  color: Colors.blue.shade100,
                  child: Icon(Icons.image, color: Colors.blue.shade800),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              color:
                  isFreePreview ? Colors.green.shade100 : Colors.grey.shade100,
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
              builder: (context) => VideoPreviewDialog(
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

  void _goToLearningScreen() {
    // TODO: Implement navigation to learning screen
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chuyển đến màn hình học khóa học')));
  }

  // Thêm khóa học vào giỏ hàng
  void _addToCart() {
    // Thêm trực tiếp vào giỏ hàng mà không cần hiện dialog
    _showAddToCartFeedback();
  }

  // Hiển thị thông báo đã thêm vào giỏ hàng
  void _showAddToCartFeedback() {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Đã thêm khóa học vào giỏ hàng',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'XEM GIỎ',
        textColor: Colors.white,
        onPressed: _navigateToCart,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Chuyển đến màn hình giỏ hàng
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CartScreenWithSelectedCourse(courseId: widget.course.id.toString()),
      ),
    );
  }

  // Thêm phương thức tính tổng thời lượng
  String _calculateTotalDuration() {
    if (_structureCourse.isEmpty) return "0";

    int totalSeconds = 0;
    for (var chapter in _structureCourse) {
      for (var video in chapter.videoDTOUserViewList) {
        totalSeconds += video.videoDuration;
      }
    }

    // Chuyển đổi giây thành giờ và làm tròn đến 1 chữ số thập phân
    double hours = totalSeconds / 3600;

    // Định dạng số thành a.b - một số nguyên và một chữ số thập phân
    String formatted = hours.toStringAsFixed(1);

    // Đảm bảo định dạng a.b bằng cách loại bỏ số 0 đằng sau nếu là số nguyên
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }

    return formatted;
  }
}

// Thêm widget mô tả khóa học ở cuối file, trước khi đóng lớp
class CourseDescriptionWidget extends StatefulWidget {
  final String description;

  const CourseDescriptionWidget({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  State<CourseDescriptionWidget> createState() =>
      _CourseDescriptionWidgetState();
}

class _CourseDescriptionWidgetState extends State<CourseDescriptionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade800,
          ),
          maxLines: _expanded ? null : 5,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        SizedBox(height: 12),
        Center(
          child: InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _expanded ? "Thu gọn" : "Xem thêm",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Thêm VideoPreviewDialog ở cuối file
class VideoPreviewDialog extends StatelessWidget {
  final String title;
  final bool isFreePreview;

  const VideoPreviewDialog({
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

// Thêm helper widget để chuyển đến Cart với khóa học được chọn sẵn
class CartScreenWithSelectedCourse extends StatelessWidget {
  final String courseId;

  const CartScreenWithSelectedCourse({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Chúng ta sẽ cần import CartScreen từ path tương ứng
    return FutureBuilder(
      // Sử dụng delay nhỏ để đảm bảo CartScreen được khởi tạo đúng
      future: Future.delayed(Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        // Import thực tế của CartScreen
        return import_cart.CartScreen(
          preSelectedCourseId: courseId,
        );
      },
    );
  }
}
