import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';

class ReviewCourseTab extends StatefulWidget {
  final CourseCardModel course;
  final List<ReviewCourseModel> reviews;
  final bool isLoading;
  final bool isPurchased;
  final bool isDarkMode;

  const ReviewCourseTab({
    Key? key,
    required this.course,
    required this.reviews,
    required this.isLoading,
    required this.isPurchased,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<ReviewCourseTab> createState() => _ReviewCourseTabState();
}

class _ReviewCourseTabState extends State<ReviewCourseTab> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.standardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Đánh giá khóa học"),
          SizedBox(height: AppDimensions.standardPadding),
          
          // Rating summary
          Container(
            decoration: AppStyles.reviewCardDecoration,
            padding: EdgeInsets.all(AppDimensions.standardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: AppDimensions.ratingCircleSize,
                      height: AppDimensions.ratingCircleSize,
                      decoration: BoxDecoration(
                        color: AppStyles.ratingCircleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${widget.course.averageRating}",
                          style: AppStyles.ratingValueStyle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.standardPadding),
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
                                color: AppStyles.amberColor,
                                size: AppDimensions.ratingIconSize,
                              );
                            }),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Dựa trên ${widget.reviews.length} đánh giá",
                            style: AppStyles.ratingCountStyle,
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
                        style: AppStyles.reviewTitleStyle,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: AppStyles.filterChipDecoration,
                        child: Text(
                          "Tất cả",
                          style: AppStyles.filterChipStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.standardPadding),
                ],
              ],
            ),
          ),
          
          SizedBox(height: AppDimensions.standardPadding),
          
          // Reviews list
          if (widget.reviews.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: AppStyles.emptyReviewDecoration,
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: AppStyles.emptyReviewIconColor,
                    ),
                    SizedBox(height: AppDimensions.standardPadding),
                    Text(
                      "Chưa có đánh giá nào cho khóa học này",
                      style: AppStyles.emptyReviewStyle,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildReviewsList(),
            
          if (widget.reviews.length > 3 && !_showAllReviews) ...[
            SizedBox(height: AppDimensions.headingSpacing),
            // Xem thêm button
            Center(
              child: Container(
                height: AppDimensions.reviewButtonHeight,
                width: AppDimensions.reviewButtonWidth,
                decoration: AppStyles.viewMoreButtonDecoration,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllReviews = true;
                    });
                  },
                  icon: Icon(Icons.comment, size: AppDimensions.reviewButtonIconSize),
                  label: Text("Xem thêm đánh giá"),
                  style: AppStyles.viewMoreButtonStyle,
                ),
              ),
            ),
          ],
          
          SizedBox(height: AppDimensions.headingSpacing),
          
          // Viết đánh giá
          Container(
            decoration: AppStyles.writeReviewContainerDecoration,
            padding: EdgeInsets.all(AppDimensions.standardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chia sẻ trải nghiệm học tập của bạn",
                  style: AppStyles.writeReviewTitleStyle,
                ),
                SizedBox(height: 12),
                Text(
                  widget.isPurchased 
                      ? "Đánh giá của bạn sẽ giúp cải thiện chất lượng khóa học và giúp học viên khác có lựa chọn phù hợp"
                      : "Bạn cần mua khóa học này để có thể viết đánh giá",
                  style: AppStyles.writeReviewDescriptionStyle,
                ),
                SizedBox(height: AppDimensions.standardPadding),
                Center(
                  child: Container(
                    width: AppDimensions.reviewButtonWidth,
                    height: 45,
                    decoration: widget.isPurchased
                        ? AppStyles.writeReviewButtonDecoration
                        : AppStyles.writeReviewButtonDisabledDecoration,
                    child: ElevatedButton.icon(
                      onPressed: widget.isPurchased
                          ? () {
                              // TODO: Implement write review
                            }
                          : null,
                      icon: Icon(Icons.edit, size: AppDimensions.reviewButtonIconSize),
                      label: Text("Viết đánh giá"),
                      style: AppStyles.viewMoreButtonStyle,
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
            width: AppDimensions.sectionTitleIndicatorWidth,
            height: AppDimensions.sectionTitleIndicatorHeight,
            decoration: BoxDecoration(
              color: AppStyles.tabActiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: AppStyles.sectionTitleStyle,
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
