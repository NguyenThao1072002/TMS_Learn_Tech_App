class Questions {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime deletedDate;
  final String instruction;
  final bool isDeleted;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String result;
  final String resultCheck;
  final DateTime updatedAt;
  final String level;
  final String type;
  final int accountId;
  final int courseId;
  final String topic;

  Questions({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.deletedDate,
    required this.instruction,
    required this.isDeleted,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.result,
    required this.resultCheck,
    required this.updatedAt,
    required this.level,
    required this.type,
    required this.accountId,
    required this.courseId,
    required this.topic,
  });

  factory Questions.fromJson(Map<String, dynamic> json) {
    return Questions(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      deletedDate: DateTime.parse(json['deleted_date']),
      instruction: json['instruction'],
      isDeleted: json['is_deleted'] == 1,
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      result: json['result'],
      resultCheck: json['result_check'],
      updatedAt: DateTime.parse(json['updated_at']),
      level: json['level'],
      type: json['type'],
      accountId: json['account_id'],
      courseId: json['course_id'],
      topic: json['topic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'deleted_date': deletedDate.toIso8601String(),
      'instruction': instruction,
      'is_deleted': isDeleted ? 1 : 0,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'result': result,
      'result_check': resultCheck,
      'updated_at': updatedAt.toIso8601String(),
      'level': level,
      'type': type,
      'account_id': accountId,
      'course_id': courseId,
      'topic': topic,
    };
  }
}