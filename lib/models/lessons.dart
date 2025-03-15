class Lessons {
  final int id;
  final DateTime createdAt;
  final int duration;
  final String lessonTitle;
  final DateTime updatedAt;
  final int chapterId;
  final int courseId;
  final DateTime deletedDate;
  final bool isDeleted;
  final String isTestExcluded;
  final String topic;
  final bool status;

  Lessons({
    required this.id,
    required this.createdAt,
    required this.duration,
    required this.lessonTitle,
    required this.updatedAt,
    required this.chapterId,
    required this.courseId,
    required this.deletedDate,
    required this.isDeleted,
    required this.isTestExcluded,
    required this.topic,
    required this.status,
  });

  factory Lessons.fromJson(Map<String, dynamic> json) {
    return Lessons(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      duration: json['duration'],
      lessonTitle: json['lesson_title'],
      updatedAt: DateTime.parse(json['updated_at']),
      chapterId: json['chapter_id'],
      courseId: json['course_id'],
      deletedDate: DateTime.parse(json['deleted_date']),
      isDeleted: json['is_deleted'] == 1,
      isTestExcluded: json['is_test_excluded'],
      topic: json['topic'],
      status: json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'duration': duration,
      'lesson_title': lessonTitle,
      'updated_at': updatedAt.toIso8601String(),
      'chapter_id': chapterId,
      'course_id': courseId,
      'deleted_date': deletedDate.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'is_test_excluded': isTestExcluded,
      'topic': topic,
      'status': status ? 1 : 0,
    };
  }
}