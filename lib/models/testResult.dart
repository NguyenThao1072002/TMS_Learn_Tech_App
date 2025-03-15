class TestResult {
  final String title;
  final int score;
  final String result;
  final DateTime date;
  final int correctAnswers;
  final int totalQuestions;

  TestResult({
    required this.title,
    required this.score,
    required this.result,
    required this.date,
    required this.correctAnswers,
    required this.totalQuestions,
  });
}
