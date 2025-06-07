import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';

class InfoGeneralCourse extends StatelessWidget {
  final CourseCardModel course;
  final OverviewCourseModel? overviewCourse;
  final bool isLoadingOverview;
  final String totalDuration;
  final bool isDarkMode;

  const InfoGeneralCourse({
    Key? key,
    required this.course,
    this.overviewCourse,
    this.isLoadingOverview = false,
    this.totalDuration = "0",
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: AppDimensions.headerHeight,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              overviewCourse?.imageUrl ?? course.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: AppStyles.defaultHeaderGradient,
                ),
                child: CustomPaint(
                  painter: TechnologyHexagonPainter(),
                ),
              ),
            ),
          ),

          // Gradient overlay để chữ dễ đọc
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppStyles.headerGradientOverlay,
              ),
            ),
          ),

          // Course details
          Positioned(
            left: AppDimensions.standardPadding,
            right: AppDimensions.standardPadding,
            bottom: AppDimensions.standardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Teacher & Level info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.chipPaddingHorizontal, 
                        vertical: AppDimensions.chipPaddingVertical
                      ),
                      decoration: AppStyles.categoryChipDecoration,
                      child: Text(
                        overviewCourse?.categoryName?.toUpperCase() ??
                            course.categoryName?.toUpperCase() ??
                            "KHÓA HỌC",
                        style: AppStyles.categoryChipStyle,
                      ),
                    ),

                    // Level info
                    if (overviewCourse?.level != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.chipPaddingHorizontal, 
                          vertical: AppDimensions.chipPaddingVertical
                        ),
                        decoration: AppStyles.levelChipDecoration,
                        child: Text(
                          overviewCourse?.vietnameseLevel ?? "Sơ cấp",
                          style: AppStyles.levelChipStyle,
                        ),
                      ),

                    // Teacher info
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.chipPaddingHorizontal, 
                        vertical: AppDimensions.chipPaddingVertical
                      ),
                      decoration: AppStyles.teacherChipDecoration,
                      child: Text(
                        "GV: ${overviewCourse?.author ?? course.author ?? 'Đang tải...'}",
                        style: AppStyles.teacherChipStyle,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.smallSpacing + 3),

                // Title
                Text(
                  overviewCourse?.title ?? course.title,
                  style: AppStyles.courseTitleStyle,
                ),

                // Stats row (rating, students, duration)
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4, 
                        vertical: 2
                      ),
                      decoration: AppStyles.ratingChipDecoration,
                      child: Row(
                        children: [
                          Text(
                            "${overviewCourse?.rating ?? course.averageRating ?? '0.0'}",
                            style: AppStyles.statsRatingStyle,
                          ),
                          Icon(
                            Icons.star, 
                            color: Colors.white, 
                            size: 10
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: AppDimensions.statsPadding),

                    // Students
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Colors.white, 
                          size: AppDimensions.statsIconSize
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${overviewCourse?.studentCount ?? course.numberOfStudents ?? 0} học viên",
                          style: AppStyles.statsTextStyle,
                        ),
                      ],
                    ),

                    SizedBox(width: AppDimensions.statsPadding),

                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time, 
                          color: Colors.white, 
                          size: AppDimensions.statsIconSize
                        ),
                        SizedBox(width: 4),
                        Text(
                          isLoadingOverview
                              ? "Đang tải..."
                              : "$totalDuration giờ học",
                          style: AppStyles.statsTextStyle,
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
