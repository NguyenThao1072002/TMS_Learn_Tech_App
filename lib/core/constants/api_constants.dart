/// Các hằng số URL API cho ứng dụng
class ApiConstants {
  /// URL cơ sở của API
  static const String baseUrl = 'https://api.tmsapp.com';

  // Auth API endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refreshToken = '/api/auth/refresh-token';

  // User API endpoints
  static const String userProfile = '/api/user/profile';

  // Course API endpoints
  static const String courses = '/api/courses';
  static const String lessons = '/api/lessons';

  // Activity API endpoints
  static const String activities = '/api/activity';
  static const String streak = '/api/activity/streak';

  /// Endpoint cho API bình luận
  static const String comments = '/api/comments';

  /// Endpoint cho API bình luận khóa học
  static const String courseComments = '/api/comments/course';
}
