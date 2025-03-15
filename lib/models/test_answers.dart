class TestAnswers {
  final int id;
  final int questionId;
  final int testId;

  TestAnswers({
    required this.id,
    required this.questionId,
    required this.testId,
  });

  factory TestAnswers.fromJson(Map<String, dynamic> json) {
    return TestAnswers(
      id: json['id'],
      questionId: json['question_id'],
      testId: json['test_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'test_id': testId,
    };
  }
}