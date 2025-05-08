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
import 'package:flutter_html/flutter_html.dart';
import 'package:tms_app/presentation/widgets/course/course_detail/related_course.dart';
import 'package:tms_app/presentation/widgets/course/course_detail/overview_course.dart';
import 'package:tms_app/presentation/widgets/course/course_detail/review_course.dart';
import 'package:tms_app/presentation/widgets/course/course_detail/structured_course.dart';

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
  List<CourseCardModel> _relatedCourses = [];

  bool _isLoadingOverview = true;
  bool _isLoadingStructure = true;
  bool _isLoadingReviews = true;
  bool _isLoadingRelated = true;
  bool _isPurchased = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCourseData();
    _checkPurchaseStatus();
  }

  Future<void> _loadCourseData() async {
    await _loadOverviewData();
    await _loadStructureData();
    await _loadReviewData();
    await _loadRelatedCourses();
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

        if (mounted) {
          setState(() {
            _relatedCourses = relatedCourses;
            _isLoadingRelated = false;
          });
        }
      } else {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
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
    } catch (e) {}
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
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: false,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  text: "Tổng quan",
                  height: 46,
                ),
                Tab(
                  text: "Nội dung",
                  height: 46,
                ),
                Tab(
                  text: "Đánh giá",
                  height: 46,
                ),
                Tab(
                  text: "Liên quan",
                  height: 46,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Sử dụng OverviewCourseTab widget thay vì _buildOverviewTab()
                OverviewCourseTab(
                  course: widget.course,
                  overviewCourse: _overviewCourse,
                  reviews: _reviews,
                  isLoadingOverview: _isLoadingOverview,
                  isLoadingReviews: _isLoadingReviews,
                  totalDuration: _calculateTotalDuration(),
                ),
                // Sử dụng StructuredCourseTab widget thay vì _buildContentTab()
                StructuredCourseTab(
                  course: widget.course,
                  structureCourse: _structureCourse,
                  isLoading: _isLoadingStructure,
                  isPurchased: _isPurchased,
                  totalDuration: _calculateTotalDuration(),
                  navigateToCart: _navigateToCart,
                ),
                // Sử dụng ReviewCourseTab widget cho tab đánh giá
                ReviewCourseTab(
                  course: widget.course,
                  reviews: _reviews,
                  isLoading: _isLoadingReviews,
                  isPurchased: _isPurchased,
                ),
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

  Widget _buildRelatedCoursesTab() {
    return RelatedCourses(
      courses: _relatedCourses,
      isLoading: _isLoadingRelated,
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
    // Kiểm tra xem description có phải là chuỗi HTML không
    bool isHtml =
        widget.description.contains('<') && widget.description.contains('>');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container với giới hạn chiều cao khi chưa mở rộng
        Container(
          constraints: BoxConstraints(
            maxHeight: _expanded ? double.infinity : 150,
          ),
          child: isHtml
              ? Html(
                  data: widget.description,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14),
                      color: Colors.grey.shade800,
                    ),
                    "p": Style(
                      margin: Margins(bottom: Margin(8)),
                    ),
                    "li": Style(
                      margin: Margins(bottom: Margin(4)),
                    ),
                    "ul": Style(
                      margin: Margins(left: Margin(16), bottom: Margin(16)),
                    ),
                    "strong": Style(
                      fontWeight: FontWeight.bold,
                    ),
                  },
                )
              : Text(
                  widget.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
        ),

        SizedBox(height: 12),

        // Nút mở rộng / thu gọn
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
    return import_cart.CartScreen(
      preSelectedCourseId: courseId,
    );
  }
}
