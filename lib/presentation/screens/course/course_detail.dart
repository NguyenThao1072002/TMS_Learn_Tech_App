import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tms_app/data/models/course_card_model.dart'; // Đảm bảo import đúng
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart'
    as import_cart;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          // Course header
          _buildCourseHeader(),

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
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          // Background image - sử dụng ảnh công nghệ với lục giác
          Positioned.fill(
            child: Image.asset(
              'assets/images/courses/technology_hexagon.jpg', // Đặt tên file ảnh phù hợp
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.network(
                'https://img.freepik.com/free-photo/businessman-touching-technology-concept_23-2150441132.jpg', // Fallback URL
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade800,
                        Colors.blue.shade600,
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: TechnologyHexagonPainter(),
                  ),
                ),
              ),
            ),
          ),

          // Gradient overlay để chữ dễ đọc
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // Course details
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Teacher info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "LẬP TRÌNH",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Teacher info
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "GV: TMS",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Title
                Text(
                  widget.course.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Subtitle
                Text(
                  "Cấu trúc dữ liệu & giải thuật",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 8),

                // Stats row (rating, students, duration)
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${widget.course.averageRating}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.star, color: Colors.white, size: 10),
                        ],
                      ),
                    ),

                    SizedBox(width: 12),

                    // Students
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "${widget.course.numberOfStudents} học viên",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 12),

                    // Duration
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "10.5h học viên",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
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
                _buildElevatedInfoRow(Icons.access_time, "Thời lượng", "6 Giờ"),
                Divider(height: 24),
                _buildElevatedInfoRow(Icons.workspace_premium, "Chứng chỉ",
                    "Chứng chỉ hoàn thành khóa học TMS"),
                Divider(height: 24),
                _buildElevatedInfoRow(Icons.bar_chart, "Trình độ", "Beginner"),
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
              description:
                  "Khóa học này sẽ giúp bạn nắm vững các cấu trúc dữ liệu cơ bản và thuật toán phổ biến. Bạn sẽ hiểu cách tối ưu hóa các giải thuật, từ đó có thể ứng dụng vào thực tế xây dựng phần mềm hiệu quả. Các ví dụ được chọn lọc từ các bài toán thực tiễn giúp bạn hiểu rõ hơn cách áp dụng các cấu trúc dữ liệu vào giải quyết các vấn đề thực tế từ đơn giản đến phức tạp. \n\nKhóa học được thiết kế cho cả người mới bắt đầu và những người đã có kinh nghiệm muốn củng cố kiến thức. Chúng tôi sẽ đi từ những khái niệm cơ bản như array, list đến các cấu trúc phức tạp hơn như tree, graph và các thuật toán nâng cao. \n\nSau khi hoàn thành khóa học, bạn sẽ có khả năng phân tích, thiết kế và triển khai các giải pháp tối ưu cho các vấn đề lập trình khác nhau, đồng thời nâng cao hiệu suất ứng dụng của mình.",
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
              children: [
                _buildModernLearningOutcome("1",
                    "Hiểu sâu về các cấu trúc dữ liệu Array, List, Stack, Queue..."),
                SizedBox(height: 16),
                _buildModernLearningOutcome("2",
                    "Phân tích và đánh giá thời gian các cấu trúc dữ liệu"),
                SizedBox(height: 16),
                _buildModernLearningOutcome(
                    "3", "Thiết kế và hiện thực các cấu trúc dữ liệu tùy biến"),
                SizedBox(height: 16),
                _buildModernLearningOutcome("4",
                    "Áp dụng thuật toán để giải quyết các bài toán thực tế trong lập trình"),
                SizedBox(height: 16),
                _buildModernLearningOutcome("5",
                    "Phân tích lý năng cao trình tối ưu hóa các thuật toán và cải thiện tốc độ xử lý dữ liệu"),
              ],
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
            child: Column(
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
                          "4.3",
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
                              return Icon(
                                index < 4 ? Icons.star : Icons.star_half,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Dựa trên 24 đánh giá",
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
                _buildModernReview(
                  "Thu Thảo Chính Gié",
                  "27/12/2023",
                  4,
                  "Giảm giá rồi khóa học này rất tốt, em rất thích",
                  "https://randomuser.me/api/portraits/women/10.jpg",
                ),
                SizedBox(height: 16),
                _buildModernReview(
                  "Chiến Thắng Vương",
                  "12/11/2023",
                  5,
                  "Khóa học hay",
                  "https://randomuser.me/api/portraits/men/32.jpg",
                ),
                SizedBox(height: 16),
                _buildModernReview(
                  "Thanh Tâm Tế",
                  "02/10/2023",
                  4,
                  "Khóa học phải học nên rất nhiệt tình",
                  "https://randomuser.me/api/portraits/women/22.jpg",
                ),

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
                      onPressed: () {},
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
            ),
          ),
        ],
      ),
    );
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
    // Người dùng chưa mua khóa học
    final bool hasNotPurchased = true;

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
                _buildCourseStatItem(
                    Icons.access_time, "Thời lượng", "6 giờ học"),
                SizedBox(height: 8),
                _buildCourseStatItem(
                    Icons.playlist_play, "Số bài học", "18 bài học"),
                SizedBox(height: 8),
                _buildCourseStatItem(
                    Icons.quiz, "Bài kiểm tra", "5 bài kiểm tra"),
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
          _buildModernChapterItem(
            "Chương 1",
            "Giới thiệu về cấu trúc dữ liệu",
            true,
            lessons: [
              _buildModernLessonItem(
                  "Bài 1: Giới thiệu khóa học", "08:30", true,
                  isVideo: true, isFreePreview: true),
              _buildModernLessonItem(
                  "Bài 2: Tổng quan về cấu trúc dữ liệu", "15:45", false,
                  isVideo: true),
              _buildModernLessonItem(
                  "Tài liệu: Cấu trúc dữ liệu cơ bản", "12 trang", false,
                  isVideo: false),
              _buildModernLessonItem(
                  "Quiz: Kiểm tra kiến thức", "10 câu hỏi", false,
                  isVideo: false, isQuiz: true),
            ],
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 2",
            "Array và List",
            true,
            lessons: [
              _buildModernLessonItem("Bài 1: Array cơ bản", "12:20", true,
                  isVideo: true, isFreePreview: true),
              _buildModernLessonItem("Bài 2: Array đa chiều", "14:30", false,
                  isVideo: true),
              _buildModernLessonItem(
                  "Bài 3: Các thao tác với List", "18:15", false,
                  isVideo: true),
              _buildModernLessonItem(
                  "Bài thực hành: Thao tác với Array", "45 phút", false,
                  isVideo: false, isPractice: true),
            ],
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 3",
            "Stack và Queue",
            false,
            lessons: [
              _buildModernLessonItem("Bài 1: Ngăn xếp (Stack)", "10:15", true,
                  isVideo: true, isFreePreview: true),
              _buildModernLessonItem("Bài 2: Hàng đợi (Queue)", "11:40", false,
                  isVideo: true),
              _buildModernLessonItem(
                  "Bài 3: Ứng dụng Stack và Queue", "16:25", false,
                  isVideo: true),
            ],
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 4",
            "Linked List",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 5",
            "Cây nhị phân (Binary Tree)",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 6",
            "Bảng băm (Hash Table)",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 7",
            "Đồ thị (Graph)",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 8",
            "Thuật toán sắp xếp",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 9",
            "Thuật toán tìm kiếm",
            false,
          ),

          SizedBox(height: 16),

          _buildModernChapterItem(
            "Chương 10",
            "Bài tập tổng hợp và dự án",
            false,
          ),

          SizedBox(height: 32),

          // Call to action
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
                    onPressed: () {},
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

  Widget _buildRelatedCoursesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRelatedCourseItem(
            "Học máy",
            "4.8",
            "15.5h học viên",
            "assets/images/courses/machine_learning.jpg",
          ),
          SizedBox(height: 16),
          _buildRelatedCourseItem(
            "Lập trình C căn bản",
            "4.9",
            "12.5h học viên",
            "assets/images/courses/c_programming.jpg",
          ),
          SizedBox(height: 16),
          _buildRelatedCourseItem(
            "Lập trình Java",
            "4.7",
            "18h học viên",
            "assets/images/courses/java_programming.jpg",
          ),
          SizedBox(height: 16),
          _buildRelatedCourseItem(
            "Triết học Machine Learning",
            "4.6",
            "10h học viên",
            "assets/images/courses/ai_philosophy.jpg",
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCourseItem(
      String title, String rating, String duration, String imageUrl) {
    return Container(
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
            child: Image.asset(
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Phần giá
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị giá với ellipsis để tránh tràn
                Text(
                  "${widget.course.price} đ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.course.cost > 0)
                  Text(
                    "${widget.course.cost} đ",
                    style: TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Khoảng cách
          SizedBox(width: 8),

          // Nút thêm vào giỏ hàng
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: IconButton(
              onPressed: _addToCart,
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.blue),
              tooltip: 'Thêm vào giỏ hàng',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),

          // Khoảng cách
          SizedBox(width: 8),

          // Nút đăng ký học
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _navigateToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Đăng ký",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}

// Painter để vẽ mô hình lục giác nếu không tải được ảnh
class TechnologyHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.7),
      fontSize: 14,
    );

    // Vẽ lưới lục giác
    final hexagonSize = size.width * 0.2;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    // Vẽ lục giác trung tâm
    _drawHexagon(canvas, centerX, centerY, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX, centerY, "IT", Colors.blue, 24);

    // Vẽ các lục giác xung quanh
    _drawHexagon(
        canvas, centerX - hexagonSize * 1.5, centerY, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX - hexagonSize * 1.5, centerY, "Data",
        Colors.transparent, 14);

    _drawHexagon(
        canvas, centerX + hexagonSize * 1.5, centerY, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX + hexagonSize * 1.5, centerY, "Computer",
        Colors.transparent, 14);

    _drawHexagon(canvas, centerX - hexagonSize * 0.75,
        centerY - hexagonSize * 1.3, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX - hexagonSize * 0.75,
        centerY - hexagonSize * 1.3, "Mobile", Colors.transparent, 14);

    _drawHexagon(canvas, centerX + hexagonSize * 0.75,
        centerY - hexagonSize * 1.3, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX + hexagonSize * 0.75,
        centerY - hexagonSize * 1.3, "Information", Colors.transparent, 14);

    _drawHexagon(canvas, centerX - hexagonSize * 0.75,
        centerY + hexagonSize * 1.3, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX - hexagonSize * 0.75,
        centerY + hexagonSize * 1.3, "Internet", Colors.transparent, 14);

    _drawHexagon(canvas, centerX + hexagonSize * 0.75,
        centerY + hexagonSize * 1.3, hexagonSize, paint);
    _drawTextInHexagon(canvas, centerX + hexagonSize * 0.75,
        centerY + hexagonSize * 1.3, "Business", Colors.transparent, 14);
  }

  void _drawHexagon(
      Canvas canvas, double centerX, double centerY, double size, Paint paint) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = centerX + size * cos(angle);
      final y = centerY + size * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTextInHexagon(Canvas canvas, double centerX, double centerY,
      String text, Color bgColor, double fontSize) {
    if (bgColor != Colors.transparent) {
      final bgPaint = Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill;

      final hexPath = Path();
      final hexSize = fontSize * 1.2;

      for (int i = 0; i < 6; i++) {
        final angle = (i * 60) * (3.14159 / 180);
        final x = centerX + hexSize * cos(angle);
        final y = centerY + hexSize * sin(angle);

        if (i == 0) {
          hexPath.moveTo(x, y);
        } else {
          hexPath.lineTo(x, y);
        }
      }

      hexPath.close();
      canvas.drawPath(hexPath, bgPaint);
    }

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    final xCenter = centerX - textPainter.width / 2;
    final yCenter = centerY - textPainter.height / 2;

    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
