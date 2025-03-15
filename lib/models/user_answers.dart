class UserAnswers {
  final int id;
  final DateTime deletedDate;
  final bool isDeleted;
  final String result;
  final int accountId;
  final int courseId;
  final int questionId;
  final int testId;
  final int testResultId;

  UserAnswers({
    required this.id,
    required this.deletedDate,
    required this.isDeleted,
    required this.result,
    required this.accountId,
    required this.courseId,
    required this.questionId,
    required this.testId,
    required this.testResultId,
  });

  factory UserAnswers.fromJson(Map<String, dynamic> json) {
    return UserAnswers(
      id: json['id'],
      deletedDate: DateTime.parse(json['deleted_date']),
      isDeleted: json['is_deleted'] == 1,
      result: json['result'],
      accountId: json['account_id'],
      courseId: json['course_id'],
      questionId: json['question_id'],
      testId: json['test_id'],
      testResultId: json['test_result_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deleted_date': deletedDate.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'result': result,
      'account_id': accountId,
      'course_id': courseId,
      'question_id': questionId,
      'test_id': testId,
      'test_result_id': testResultId,
    };
  }
}