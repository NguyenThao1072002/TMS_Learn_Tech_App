class Tests {
  final int id;
  final DateTime createdAt;
  final DateTime deletedDate;
  final String description;
  final bool isDeleted;
  final bool isSummary;
  final String title;
  final int totalQuestion;
  final DateTime updatedAt;
  final int chapterId;
  final int courseId;
  final int lessonId;
  final int easyQuestion;
  final int hardQuestion;
  final int mediumQuestion;
  final String type;
  final bool isAssigned;

  Tests({
    required this.id,
    required this.createdAt,
    required this.deletedDate,
    required this.description,
    required this.isDeleted,
    required this.isSummary,
    required this.title,
    required this.totalQuestion,
    required this.updatedAt,
    required this.chapterId,
    required this.courseId,
    required this.lessonId,
    required this.easyQuestion,
    required this.hardQuestion,
    required this.mediumQuestion,
    required this.type,
    required this.isAssigned,
  });

  factory Tests.fromJson(Map<String, dynamic> json) {
    return Tests(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      deletedDate: DateTime.parse(json['deleted_date']),
      description: json['description'],
      isDeleted: json['is_deleted'] == 1,
      isSummary: json['is_summary'] == 1,
      title: json['title'],
      totalQuestion: json['total_question'],
      updatedAt: DateTime.parse(json['updated_at']),
      chapterId: json['chapter_id'],
      courseId: json['course_id'],
      lessonId: json['lesson_id'],
      easyQuestion: json['easy_question'],
      hardQuestion: json['hard_question'],
      mediumQuestion: json['medium_question'],
      type: json['type'],
      isAssigned: json['is_assigned'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'deleted_date': deletedDate.toIso8601String(),
      'description': description,
      'is_deleted': isDeleted ? 1 : 0,
      'is_summary': isSummary ? 1 : 0,
      'title': title,
      'total_question': totalQuestion,
      'updated_at': updatedAt.toIso8601String(),
      'chapter_id': chapterId,
      'course_id': courseId,
      'lesson_id': lessonId,
      'easy_question': easyQuestion,
      'hard_question': hardQuestion,
      'medium_question': mediumQuestion,
      'type': type,
      'is_assigned': isAssigned ? 1 : 0,
    };
  }
}