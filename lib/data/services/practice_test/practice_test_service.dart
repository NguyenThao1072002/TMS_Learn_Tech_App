import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeTestService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  PracticeTestService(this.dio);

  /// Get a list of practice tests with optional filters
  /// Parameters:
  /// - title: Optional search term for test title
  /// - courseId: Optional filter by course ID
  /// - accountId: Optional account ID to check if tests are purchased
  /// - page: Page number (default 0)
  /// - size: Items per page (default 10)
  Future<List<PracticeTestCardModel>> getPracticeTests({
    String? title,
    int? courseId,
    int? accountId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      if (courseId != null) {
        queryParams['courseId'] = courseId;
      }

      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      // Construct the URL with query parameters
      final endpoint = '$apiUrl/tests/exam/public';

      try {
        final response = await dio.get(
          endpoint,
          queryParameters: queryParams,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, PracticeTestCardModel.fromJson);
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get details for a specific practice test
  /// Parameters:
  /// - testId: ID of the test to retrieve
  /// - accountId: Optional account ID to check if test is purchased
  Future<PracticeTestDetailModel?> getPracticeTestDetail(
    int testId, {
    int? accountId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};

      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      final endpoint = '$apiUrl/tests/exam/public/$testId';

      try {
        final response = await dio.get(
          endpoint,
          queryParameters: queryParams,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;

          Map<String, dynamic> testData;

          if (responseData != null && responseData['data'] != null) {
            // If API returns {status, message, data} structure
            testData = responseData['data'];
          } else if (responseData != null &&
              responseData is Map<String, dynamic>) {
            // If API returns the object directly
            testData = responseData;
          } else {
            return null;
          }

          return PracticeTestDetailModel.fromJson(testData);
        } else {
          return null;
        }
      } on DioException catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get reviews for a specific practice test
  /// Parameters:
  /// - testId: ID of the test to get reviews for
  /// - page: Page number (default 0)
  /// - size: Items per page (default 10)
  Future<List<PracticeTestReviewModel>> getPracticeTestReviews(
    int testId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      final endpoint = '$apiUrl/reviews/exam/$testId';

      try {
        final response = await dio.get(
          endpoint,
          queryParameters: queryParams,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData != null && responseData['data'] != null) {
            final paginationResponse =
                ReviewPaginationResponse.fromJson(responseData['data']);
            return paginationResponse.content;
          }
          return [];
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Submit a review for a practice test
  /// Parameters:
  /// - testId: ID of the test to review
  /// - accountId: ID of the account submitting the review
  /// - rating: Rating value (1-5)
  /// - review: Optional review text
  Future<bool> submitPracticeTestReview(
    int testId,
    int accountId,
    int rating, {
    String? review,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return false;
      }

      final endpoint = '$apiUrl/reviews/exam';

      final data = {
        'test_id': testId,
        'account_id': accountId,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      };

      try {
        final response = await dio.post(
          endpoint,
          data: data,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        return response.statusCode == 200 || response.statusCode == 201;
      } on DioException catch (e) {
        print('Error submitting review: ${e.message}');
        return false;
      }
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  /// Get all practice test categories
  Future<List<Map<String, dynamic>>> getPracticeTestCategories() async {
    try {
      final endpoint = '$apiUrl/courses/get-all-result-list-course';

      try {
        final response = await dio.get(
          endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          // Process the response using ApiResponseHelper
          final List<dynamic> categoryList = ApiResponseHelper.processList(
            response.data,
            (Map<String, dynamic> json) => json, // Pass through the raw map
          );

          // Map the response to the expected structure with name instead of title
          final categories = categoryList.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id'],
              'name':
                  item['title'], // Map 'title' field to 'name' for consistency
              'imageUrl': item['imageUrl'],
            };
          }).toList();

          print('Categories fetched successfully: ${categories.length}');
          if (categories.isNotEmpty) {
            print('Sample category: ${categories[0]}');
          }

          return categories;
        } else {
          print('Error fetching categories: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('Error fetching test categories: ${e.message}');
        return [];
      }
    } catch (e) {
      print('Error fetching test categories: $e');
      return [];
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }
}
