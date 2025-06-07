// Models for course activation

// Request model for activating a course
class ActivateCourseRequest {
  final String email;
  final String code;
  final int accountId;
  final int birthday;
  final int studyHoursPerWeek;
  final int timeSpentOnSocialMedia;
  final int sleepHoursPerNight;
  final String gender;  // "0" for female, "1" for male
  final int preferredLearningStyle;
  final bool useOfEducationalTech;
  final int selfReportedStressLevel;

  ActivateCourseRequest({
    required this.email,
    required this.code,
    required this.accountId,
    required this.birthday,
    required this.studyHoursPerWeek,
    required this.timeSpentOnSocialMedia,
    required this.sleepHoursPerNight,
    required this.gender,
    required this.preferredLearningStyle,
    required this.useOfEducationalTech,
    required this.selfReportedStressLevel,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'accountId': accountId,
        'birthday': birthday,
        'studyHoursPerWeek': studyHoursPerWeek,
        'timeSpentOnSocialMedia': timeSpentOnSocialMedia,
        'sleepHoursPerNight': sleepHoursPerNight,
        'gender': gender,
        'preferredLearningStyle': preferredLearningStyle,
        'useOfEducationalTech': useOfEducationalTech,
        'selfReportedStressLevel': selfReportedStressLevel,
      };
}

// Request model for checking if a course code is valid
class CheckCourseCodeRequest {
  final String code;
  final int accountId;

  CheckCourseCodeRequest({
    required this.code,
    required this.accountId,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'accountId': accountId,
      };
}

// Response model for checking course code validity
class CheckCourseCodeResponse {
  final int status;
  final String message;
  final CheckCourseCodeData data;

  CheckCourseCodeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CheckCourseCodeResponse.fromJson(Map<String, dynamic> json) {
    return CheckCourseCodeResponse(
      status: json['status'],
      message: json['message'],
      data: CheckCourseCodeData.fromJson(json['data']),
    );
  }
}

class CheckCourseCodeData {
  final String code;
  final bool valid;

  CheckCourseCodeData({
    required this.code,
    required this.valid,
  });

  factory CheckCourseCodeData.fromJson(Map<String, dynamic> json) {
    return CheckCourseCodeData(
      code: json['code'],
      valid: json['valid'],
    );
  }
}

// Enum for learning style preferences
enum LearningStyle {
  practice, // 0
  readWrite, // 1
  audio,    // 2
  visual,   // 3
}

// Enum for stress levels
enum StressLevel {
  veryLow,   // 0
  low,       // 1
  medium,    // 2
  high,      // 3
  veryHigh,  // 4
}
