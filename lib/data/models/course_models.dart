// Define the LessonType enum
enum LessonType {
  video,
  test,
  document,
}

// Define the Lesson class
class Lesson {
  final String id;
  final String title;
  final String duration;
  final LessonType type;
  final bool isUnlocked;
  final int? questionCount; // Optional for test lessons

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.isUnlocked,
    this.questionCount,
  });
}

// Define the CourseChapter class
class CourseChapter {
  final int id;
  final String title;
  final List<Lesson> lessons;

  CourseChapter({
    required this.id,
    required this.title,
    required this.lessons,
  });
}
