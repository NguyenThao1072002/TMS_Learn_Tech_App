import 'package:equatable/equatable.dart';

/// Model for a recently viewed lesson
class RecentLessonModel extends Equatable {
  final String lessonId;
  final String imageCourse;
  final String courseName;
  final int duration;
  final String lessonTitle;
  final String chapterId;
  final String courseId;
  final String createdAt;

  const RecentLessonModel({
    required this.lessonId,
    required this.imageCourse,
    required this.courseName,
    required this.duration,
    required this.lessonTitle,
    required this.chapterId,
    required this.courseId,
    required this.createdAt,
  });

  factory RecentLessonModel.fromJson(Map<String, dynamic> json) {
    return RecentLessonModel(
      lessonId: json['lessonId'] as String,
      imageCourse: json['imageCourse'] as String,
      courseName: json['courseName'] as String,
      duration: json['duration'] as int,
      lessonTitle: json['lessonTitle'] as String,
      chapterId: json['chapterId'] as String,
      courseId: json['courseId'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'imageCourse': imageCourse,
      'courseName': courseName,
      'duration': duration,
      'lessonTitle': lessonTitle,
      'chapterId': chapterId,
      'courseId': courseId,
      'createdAt': createdAt,
    };
  }

  /// Format duration from seconds to mm:ss format
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object> get props => [
        lessonId,
        imageCourse,
        courseName,
        duration,
        lessonTitle,
        chapterId,
        courseId,
        createdAt,
      ];
}

/// Model for the response from the recently viewed lessons API
class RecentLessonResponse extends Equatable {
  final int status;
  final String message;
  final List<RecentLessonModel> data;

  const RecentLessonResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RecentLessonResponse.fromJson(Map<String, dynamic> json) {
    return RecentLessonResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => RecentLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [status, message, data];
}
