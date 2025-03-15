class Progress {
  final int id;
  final bool isChapterTest;
  final DateTime completedAt;
  final bool testCompleted;
  final double testScore;
  final bool videoCompleted;
  final int accountId;
  final int chapterId;
  final int courseId;
  final int lessonId;

  Progress({
    required this.id,
    required this.isChapterTest,
    required this.completedAt,
    required this.testCompleted,
    required this.testScore,
    required this.videoCompleted,
    required this.accountId,
    required this.chapterId,
    required this.courseId,
    required this.lessonId,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      isChapterTest: json['is_chapter_test'] == 1,
      completedAt: DateTime.parse(json['completed_at']),
      testCompleted: json['test_completed'] == 1,
      testScore: json['test_score'],
      videoCompleted: json['video_completed'] == 1,
      accountId: json['account_id'],
      chapterId: json['chapter_id'],
      courseId: json['course_id'],
      lessonId: json['lesson_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_chapter_test': isChapterTest ? 1 : 0,
      'completed_at': completedAt.toIso8601String(),
      'test_completed': testCompleted ? 1 : 0,
      'test_score': testScore,
      'video_completed': videoCompleted ? 1 : 0,
      'account_id': accountId,
      'chapter_id': chapterId,
      'course_id': courseId,
      'lesson_id': lessonId,
    };
  }
}