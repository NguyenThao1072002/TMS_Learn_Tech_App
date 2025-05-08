import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';

class ReviewCourseTab extends StatefulWidget {
  final CourseCardModel course;
  final List<ReviewCourseModel> reviews;
  final bool isLoading;
  final bool isPurchased;

  const ReviewCourseTab({
    Key? key,
    required this.course,
    required this.reviews,
    required this.isLoading,
    this.isPurchased = false,
  }) : super(key: key);

  @override
  State<ReviewCourseTab> createState() => _ReviewCourseTabState();
}

class _ReviewCourseTabState extends State<ReviewCourseTab> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Đánh giá khóa học"),
          SizedBox(height: 16),
          
          // Rating summary
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
                            "Dựa trên ${widget.reviews.length} đánh giá",
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
                
                if (widget.reviews.isNotEmpty) ...[
                  Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Đánh giá của học viên",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Tất cả",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Reviews list
          if (widget.reviews.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Chưa có đánh giá nào cho khóa học này",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildReviewsList(),
            
          if (widget.reviews.length > 3 && !_showAllReviews) ...[
            SizedBox(height: 24),
            // Xem thêm button
            Center(
              child: Container(
                height: 40,
                width: 200,
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
                    setState(() {
                      _showAllReviews = true;
                    });
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
          
          SizedBox(height: 24),
          
          // Viết đánh giá
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chia sẻ trải nghiệm học tập của bạn",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.isPurchased 
                      ? "Đánh giá của bạn sẽ giúp cải thiện chất lượng khóa học và giúp học viên khác có lựa chọn phù hợp"
                      : "Bạn cần mua khóa học này để có thể viết đánh giá",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 200,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isPurchased
                            ? [Colors.blue.shade400, Colors.blue.shade700]
                            : [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: widget.isPurchased
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: widget.isPurchased
                          ? () {
                              // TODO: Implement write review
                            }
                          : null,
                      icon: Icon(Icons.edit, size: 16),
                      label: Text("Viết đánh giá"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        disabledForegroundColor: Colors.white.withOpacity(0.6),
                        disabledBackgroundColor: Colors.transparent,
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

  List<Widget> _buildReviewsList() {
    final reviewsToShow = _showAllReviews 
        ? widget.reviews 
        : (widget.reviews.length > 3 ? widget.reviews.sublist(0, 3) : widget.reviews);
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
}
