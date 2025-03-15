class TestResults {
  final int testResultId;
  final bool isChapterTest;
  final DateTime completedAt;
  final int correctAnswers;
  final DateTime deletedDate;
  final int incorrectAnswers;
  final bool isDeleted;
  final String result;
  final double score;
  final int totalQuestions;
  final int accountId;
  final int courseId;
  final int testId;

  TestResults({
    required this.testResultId,
    required this.isChapterTest,
    required this.completedAt,
    required this.correctAnswers,
    required this.deletedDate,
    required this.incorrectAnswers,
    required this.isDeleted,
    required this.result,
    required this.score,
    required this.totalQuestions,
    required this.accountId,
    required this.courseId,
    required this.testId,
  });

  factory TestResults.fromJson(Map<String, dynamic> json) {
    return TestResults(
      testResultId: json['test_result_id'],
      isChapterTest: json['is_chapter_test'] == 1,
      completedAt: DateTime.parse(json['completed_at']),
      correctAnswers: json['correct_answers'],
      deletedDate: DateTime.parse(json['deleted_date']),
      incorrectAnswers: json['incorrect_answers'],
      isDeleted: json['is_deleted'] == 1,
      result: json['result'],
      score: json['score'],
      totalQuestions: json['total_questions'],
      accountId: json['account_id'],
      courseId: json['course_id'],
      testId: json['test_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_result_id': testResultId,
      'is_chapter_test': isChapterTest ? 1 : 0,
      'completed_at': completedAt.toIso8601String(),
      'correct_answers': correctAnswers,
      'deleted_date': deletedDate.toIso8601String(),
      'incorrect_answers': incorrectAnswers,
      'is_deleted': isDeleted ? 1 : 0,
      'result': result,
      'score': score,
      'total_questions': totalQuestions,
      'account_id': accountId,
      'course_id': courseId,
      'test_id': testId,
    };
  }
}