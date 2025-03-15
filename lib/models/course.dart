import 'package:tms/models/testResult.dart';

class Course {
  final String name;
  final String image;
  final double progress;
  final String author;
  final List<TestResult> results;

  Course({
    required this.name,
    required this.image,
    required this.progress,
    required this.author,
    required this.results,
  });
}

