class Videos {
  final int id;
  final DateTime createdAt;
  final DateTime deletedDate;
  final String documentShort;
  final String documentUrl;
  final int duration;
  final bool isDeleted;
  final String videoTitle;
  final DateTime updatedAt;
  final String url;
  final int lessonId;
  final int isViewTest;

  Videos({
    required this.id,
    required this.createdAt,
    required this.deletedDate,
    required this.documentShort,
    required this.documentUrl,
    required this.duration,
    required this.isDeleted,
    required this.videoTitle,
    required this.updatedAt,
    required this.url,
    required this.lessonId,
    required this.isViewTest,
  });

  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      deletedDate: DateTime.parse(json['deleted_date']),
      documentShort: json['document_short'],
      documentUrl: json['document_url'],
      duration: json['duration'],
      isDeleted: json['is_deleted'] == 1,
      videoTitle: json['video_title'],
      updatedAt: DateTime.parse(json['updated_at']),
      url: json['url'],
      lessonId: json['lesson_id'],
      isViewTest: json['isviewtest'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'deleted_date': deletedDate.toIso8601String(),
      'document_short': documentShort,
      'document_url': documentUrl,
      'duration': duration,
      'is_deleted': isDeleted ? 1 : 0,
      'video_title': videoTitle,
      'updated_at': updatedAt.toIso8601String(),
      'url': url,
      'lesson_id': lessonId,
      'isviewtest': isViewTest,
    };
  }
}