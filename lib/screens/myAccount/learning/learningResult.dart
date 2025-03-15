import 'package:flutter/material.dart';
import 'package:tms/models/course.dart';
import 'package:tms/models/testResult.dart';
import 'package:tms/screens/myAccount/learning/learningResultDetail.dart';

class LearningResults extends StatelessWidget {
  final List<Course> courses = [
    Course(
      name: "Lập trình Python",
      image: "assets/imgs/courses/course_example.png",
      progress: 55,
      author: "TMS",
      results: [
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
            TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
      ],
    ),
    Course(
      name: "Machine Learning",
      image: "assets/imgs/courses/course_example.png",
      progress: 70,
      author: "Đinh Nguyễn Trọng Nghĩa",
      results: [
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
      ],
    ),
    Course(
      name: "Lập trình C",
      image: "assets/imgs/courses/course_example.png",
      progress: 15,
      author: "TMS2",
      results: [
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
      ],
    ),
    Course(
      name: "Machine Learning",
      image: "assets/imgs/courses/course_example.png",
      progress: 100,
      author: "Vũ Đức Thịnh",
      results: [
        TestResult(
            title: "Xử lý lỗi",
            score: 2,
            result: "Fail",
            date: DateTime(2025, 1, 10),
            correctAnswers: 1,
            totalQuestions: 5),
        TestResult(
            title: "Ghi file JSON",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 2, 5),
            correctAnswers: 10,
            totalQuestions: 10),
        TestResult(
            title: "CSV trong Python",
            score: 8,
            result: "Pass",
            date: DateTime(2025, 3, 20),
            correctAnswers: 8,
            totalQuestions: 10),
        TestResult(
            title: "Test",
            score: 10,
            result: "Pass",
            date: DateTime(2025, 1, 10),
            correctAnswers: 10,
            totalQuestions: 10),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Kết Quả Học Tập",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return buildCourseCard(context, courses[index], index);
          },
        ),
      ),
    );
  }

  Widget buildCourseCard(BuildContext context, Course course, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearningResultDetail(course: course),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  course.image,
                  fit: BoxFit.cover,
                  height: 170,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                course.name,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                course.author,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: course.progress / 100,
                color: Colors.blue,
                backgroundColor: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text("${course.progress.toInt()}% hoàn thành"),
            ],
          ),
        ),
      ),
    );
  }
}
