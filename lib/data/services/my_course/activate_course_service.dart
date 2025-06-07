import 'package:dio/dio.dart';
import 'package:tms_app/data/models/my_course/activate_model.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';

class ActivateCourseService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  ActivateCourseService(this.dio);

  /// Add auth token to request
  Future<Map<String, dynamic>> _getAuthHeaders() async {
    final token = await SharedPrefs.getJwtToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Check if a course code is valid and not already activated
  Future<CheckCourseCodeResponse> checkCourseCode(CheckCourseCodeRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      
      print('Checking course code: ${request.code} for account: ${request.accountId}');
      
      final response = await dio.post(
        '$baseUrl/course-codes/check-enable',
        data: request.toJson(),
        options: Options(
          headers: headers,
          validateStatus: (status) => true, // Accept all status codes to handle errors ourselves
        ),
      );

      print('Course code check response: ${response.statusCode} - ${response.data}');
      
      // Handle error responses
      if (response.statusCode != 200) {
        String errorMessage = 'Failed to check course code';
        
        if (response.data != null) {
          if (response.data is Map && response.data['message'] != null) {
            errorMessage = response.data['message'];
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }
        
        throw Exception(errorMessage);
      }

      return CheckCourseCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Error checking course code: ${e.message}');
      
      // Try to parse the error message from the response if available
      String errorMessage = 'Failed to check course code';
      try {
        if (e.response != null && e.response!.data != null) {
          if (e.response!.data is Map && e.response!.data['message'] != null) {
            errorMessage = e.response!.data['message'];
          } else if (e.response!.data is String) {
            errorMessage = e.response!.data;
          }
        }
      } catch (_) {
        // Ignore parsing errors
      }
      
      // Handle specific error cases
      if (e.response?.statusCode == 401) {
        throw Exception('Lỗi xác thực. Vui lòng đăng nhập lại.');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Unexpected error checking course code: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Activate a course with student data
  Future<bool> activateCourse(ActivateCourseRequest request) async {
    try {
      // Ensure gender is a string in the JSON request
      final Map<String, dynamic> requestData = {
        'email': request.email,
        'code': request.code,
        'accountId': request.accountId,
        'birthday': request.birthday,
        'studyHoursPerWeek': request.studyHoursPerWeek,
        'timeSpentOnSocialMedia': request.timeSpentOnSocialMedia,
        'sleepHoursPerNight': request.sleepHoursPerNight,
        'gender': request.gender.toString(), // Already a string "0" or "1"
        'preferredLearningStyle': request.preferredLearningStyle,
        'useOfEducationalTech': request.useOfEducationalTech,
        'selfReportedStressLevel': request.selfReportedStressLevel,
      };
      
      print("Debug gender type: ${requestData['gender'].runtimeType}");
      print("Debug gender value: '${requestData['gender']}'");
      
      final headers = await _getAuthHeaders();
      
      print('Activating course with code: ${request.code}');
      print('Request data (final): $requestData');
      print('Request URL: $baseUrl/course-codes/enable');
      
      // Create a new Dio instance with extended timeout
      final activationDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: headers,
          contentType: 'application/json',
          responseType: ResponseType.plain, // Set to plain text response
        ),
      );
      
      final response = await activationDio.post(
        '$baseUrl/course-codes/enable',
        data: requestData,
        options: Options(
          validateStatus: (status) => true, 
          receiveDataWhenStatusError: true,
          responseType: ResponseType.plain, // Ensure plain text response
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response text: ${response.data}');
      
      // Check if status code is 200 (success)
      if (response.statusCode == 200) {
        return true;
      } 
      // Handle error responses (status code 400)
      else {
        // Handle response as plain text
        final errorMessage = response.data?.toString() ?? 'Unknown error';
        print('Error message: $errorMessage');
        
        // Handle specific error cases in the plain text
        if (errorMessage.contains('Mã khóa học đã được kích hoạt')) {
          throw Exception('Mã khóa học đã được kích hoạt');
        } else if (errorMessage.contains('Mã khóa học đã hết hạn')) {
          throw Exception('Mã khóa học đã hết hạn');
        } else if (errorMessage.contains('Tài khoản đã đăng ký khóa học này')) {
          throw Exception('Tài khoản đã đăng ký khóa học này');
        } else if (errorMessage.contains('Mã khóa học không tồn tại')) {
          throw Exception('Mã khóa học không tồn tại');
        } else if (errorMessage.contains('Không phải sinh viên HUIT')) {
          throw Exception('Không phải sinh viên HUIT');
        } else if (errorMessage.contains('Tài khoản không tồn tại')) {
          throw Exception('Tài khoản không tồn tại');
        } else {
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('Error activating course: $e');
      
      // Check for specific error types
      if (e is DioException) {
        print('Error type: ${e.type}');
        print('Error response data: ${e.response?.data}');
        
        // Handle specific DioError types
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Kết nối tới server bị gián đoạn, vui lòng thử lại');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Không thể kết nối tới máy chủ, vui lòng kiểm tra kết nối mạng');
        }
        
        // If we have a text response in the error, use it as the message
        if (e.response?.data != null) {
          final errorText = e.response?.data.toString() ?? '';
          if (errorText.isNotEmpty) {
            throw Exception(errorText);
          }
        }
      }
      
      // If it's already an Exception with our custom message, rethrow it
      if (e is Exception && e.toString().contains('Exception:')) {
        rethrow;
      }
      
      print('Error details: $e');
      throw Exception('Lỗi kích hoạt khóa học');
    }
  }
}
