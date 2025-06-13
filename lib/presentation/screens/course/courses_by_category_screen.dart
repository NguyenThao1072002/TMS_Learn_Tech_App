import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/screens/course/course_detail.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';

class CoursesByCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CoursesByCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CoursesByCategoryScreen> createState() =>
      _CoursesByCategoryScreenState();
}

class _CoursesByCategoryScreenState extends State<CoursesByCategoryScreen> {
  late final Future<List<CourseCardModel>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    final courseUseCase = sl<CourseUseCase>();
    _coursesFuture = courseUseCase.getRelatedCourse(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<CourseCardModel>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải khóa học: ${snapshot.error}'),
            );
          }

          final courses = snapshot.data;
          if (courses == null || courses.isEmpty) {
            return const Center(
              child: Text('Không có khóa học nào trong danh mục này.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CourseCard(
                  course: course,
                  selectedIndex: null,
                  onTap: (selectedCourse) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: selectedCourse),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 