// Model class for the Course Lesson structure
class CourseLessonResponse {
  final int courseId;
  final String courseTitle;
  final List<Chapter> chapters;

  CourseLessonResponse({
    required this.courseId,
    required this.courseTitle,
    required this.chapters,
  });

  factory CourseLessonResponse.fromJson(Map<String, dynamic> json) {
    return CourseLessonResponse(
      courseId: json['course_id'] as int,
      courseTitle: json['course_title'] as String,
      chapters: (json['chapters'] as List)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'course_title': courseTitle,
        'chapters': chapters.map((e) => e.toJson()).toList(),
      };
}

class Chapter {
  final int chapterId;
  final String chapterTitle;
  final List<Lesson> lessons;
  final Test? chapterTest;

  Chapter({
    required this.chapterId,
    required this.chapterTitle,
    required this.lessons,
    this.chapterTest,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id'] as int,
      chapterTitle: json['chapter_title'] as String,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      chapterTest: json['chapter_test'] != null
          ? Test.fromJson(json['chapter_test'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapter_id': chapterId,
        'chapter_title': chapterTitle,
        'lessons': lessons.map((e) => e.toJson()).toList(),
        'chapter_test': chapterTest?.toJson(),
      };
}

class Lesson {
  final int lessonId;
  final String lessonTitle;
  final int lessonDuration;
  final Video? video;
  final Test? lessonTest;

  Lesson({
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonDuration,
    this.video,
    this.lessonTest,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'] as int,
      lessonTitle: json['lesson_title'] as String,
      lessonDuration: json['lesson_duration'] as int,
      video: json['video'] != null
          ? Video.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      lessonTest: json['lesson_test'] != null
          ? Test.fromJson(json['lesson_test'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
        'lesson_duration': lessonDuration,
        'video': video?.toJson(),
        'lesson_test': lessonTest?.toJson(),
      };
}

class Video {
  final int videoId;
  final String videoTitle;
  final String videoUrl;
  final String? documentShort;
  final String? documentUrl;

  Video({
    required this.videoId,
    required this.videoTitle,
    required this.videoUrl,
    this.documentShort,
    this.documentUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['video_id'] as int,
      videoTitle: json['video_title'] as String,
      videoUrl: json['video_url'] as String,
      documentShort: json['document_short'] as String?,
      documentUrl: json['document_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'video_id': videoId,
        'video_title': videoTitle,
        'video_url': videoUrl,
        'document_short': documentShort,
        'document_url': documentUrl,
      };
}

class Test {
  final int testId;
  final String testTitle;
  final String testType;

  Test({
    required this.testId,
    required this.testTitle,
    required this.testType,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      testId: json['test_id'] as int,
      testTitle: json['test_title'] as String,
      testType: json['test_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'test_id': testId,
        'test_title': testTitle,
        'test_type': testType,
      };
}
