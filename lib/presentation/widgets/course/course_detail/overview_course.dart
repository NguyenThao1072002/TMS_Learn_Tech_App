import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';

class OverviewCourseTab extends StatefulWidget {
  final CourseCardModel course;
  final OverviewCourseModel? overviewCourse;
  final List<ReviewCourseModel> reviews;
  final bool isLoadingOverview;
  final bool isLoadingReviews;
  final String totalDuration;
  final bool isDarkMode;

  const OverviewCourseTab({
    Key? key,
    required this.course,
    required this.overviewCourse,
    required this.reviews,
    required this.isLoadingOverview,
    required this.isLoadingReviews,
    required this.totalDuration,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<OverviewCourseTab> createState() => _OverviewCourseTabState();
}

class _OverviewCourseTabState extends State<OverviewCourseTab> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoadingOverview) {
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
                    "${widget.totalDuration} Giờ"),
                Divider(height: 24),
                _buildElevatedInfoRow(
                    Icons.workspace_premium,
                    "Chứng chỉ",
                    widget.overviewCourse?.certificate ??
                        "Chứng chỉ hoàn thành khóa học"),
                Divider(height: 24),
                _buildElevatedInfoRow(Icons.bar_chart, "Trình độ",
                    widget.overviewCourse?.vietnameseLevel ?? "Sơ cấp"),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.overviewCourse?.description != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: _isDescriptionExpanded ? double.infinity : 120,
                        ),
                        child: Html(
                          data: widget.overviewCourse!.description!,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              color: Colors.grey.shade800,
                            ),
                            "p": Style(
                              margin: Margins(bottom: Margin(8)),
                            ),
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            icon: Icon(
                              _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "Thông tin mô tả khóa học đang được cập nhật.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
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
            child: widget.overviewCourse?.courseOutput.isNotEmpty == true
                ? Column(
                    children: [
                      ..._buildLearningOutcomes(),
                    ],
                  )
                : Column(
                    children: [
                      _buildModernLearningOutcome(
                          "1", "Hiểu sâu về các kiến thức trong khóa học"),
                      SizedBox(height: 16),
                      _buildModernLearningOutcome(
                          "2", "Áp dụng được kiến thức vào thực tế"),
                      SizedBox(height: 16),
                      _buildModernLearningOutcome(
                          "3", "Phát triển kỹ năng chuyên môn"),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLearningOutcomes() {
    if (widget.overviewCourse == null) {
      return [
        Text("Không có thông tin đầu ra khóa học",
            style: TextStyle(fontStyle: FontStyle.italic))
      ];
    }

    if (widget.overviewCourse!.courseOutput.isEmpty) {
      return [
        _buildModernLearningOutcome(
            "1", "Hiểu sâu về các kiến thức trong khóa học"),
        SizedBox(height: 16),
        _buildModernLearningOutcome("2", "Áp dụng được kiến thức vào thực tế"),
        SizedBox(height: 16),
        _buildModernLearningOutcome("3", "Phát triển kỹ năng chuyên môn"),
      ];
    }

    // Parse HTML và tạo các learning outcomes
    final RegExp pTagRegex = RegExp(r'<p>(.*?)</p>');
    final matches = pTagRegex.allMatches(widget.overviewCourse!.courseOutput);
    
    List<Widget> outcomes = [];
    int index = 1;
    
    for (var match in matches) {
      if (match.group(1) != null) {
        outcomes.add(_buildModernLearningOutcome(
          index.toString(),
          match.group(1)!.replaceAll(RegExp(r'<[^>]*>'), ''),
        ));
        if (index < matches.length) {
          outcomes.add(SizedBox(height: 16));
        }
        index++;
      }
    }

    return outcomes;
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
}
