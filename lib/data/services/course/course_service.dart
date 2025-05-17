import 'package:dio/dio.dart';
import 'dart:math';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/course/course_detail/overview_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/structure_course_model.dart';
import 'package:tms_app/data/models/course/course_detail/review_course_model.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Thêm class mới để xử lý phản hồi phân trang
class CoursePaginationResponse {
  final List<CourseCardModel> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  CoursePaginationResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory CoursePaginationResponse.fromJson(Map<String, dynamic> json) {
    final List<CourseCardModel> courses = [];
    if (json['content'] != null) {
      json['content'].forEach((courseJson) {
        courses.add(CourseCardModel.fromJson(courseJson));
      });
    }

    return CoursePaginationResponse(
      content: courses,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['pageable']?['pageNumber'] ?? 0,
      pageSize: json['pageable']?['pageSize'] ?? 10,
    );
  }
}

class CourseService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  CourseService(this.dio);

  // Phương thức được cập nhật để hỗ trợ phân trang
  Future<List<CourseCardModel>> getAllCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    try {
      return await getPopularCourses(
        search: search,
        page: page,
        size: size,
        accountId: accountId,
      );
    } catch (e) {
      print('Lỗi khi lấy tất cả khóa học: $e');
      return [];
    }
  }

  // Phương thức mới hỗ trợ đầy đủ phân trang
  Future<CoursePaginationResponse> getCoursesWithPagination({
    String type = 'popular',
    String? search,
    int? categoryId,
    List<int>? categoryIds,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
        'page': page,
        'size': size,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Xử lý cho cả categoryId đơn lẻ và danh sách categoryIds
      if (categoryIds != null && categoryIds.isNotEmpty) {
        // Chuyển list categoryIds thành chuỗi ngăn cách bởi dấu phẩy
        queryParams['categoryIds'] = categoryIds.join(',');
      } else if (categoryId != null && categoryId > 0) {
        queryParams['categoryIds'] = categoryId;
      }

      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      final endpoint = '$apiUrl/courses/public/filter';
      print('Đang gọi API: $endpoint với tham số: $queryParams');

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
          return CoursePaginationResponse.fromJson(responseData['data']);
        } else {
          print('Lỗi: API không trả về dữ liệu hợp lệ');
          return CoursePaginationResponse(
            content: [],
            totalElements: 0,
            totalPages: 0,
            currentPage: 0,
            pageSize: size,
          );
        }
      } else {
        print('Lỗi API (${response.statusCode}): ${response.data}');
        return CoursePaginationResponse(
          content: [],
          totalElements: 0,
          totalPages: 0,
          currentPage: 0,
          pageSize: size,
        );
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách khóa học phân trang: $e');
      return CoursePaginationResponse(
        content: [],
        totalElements: 0,
        totalPages: 0,
        currentPage: 0,
        pageSize: size,
      );
    }
  }

  Future<List<CourseCardModel>> getPopularCourses({
    String? search,
    int page = 0,
    int size = 10,
    int? accountId,
  }) async {
    try {
      // Xây dựng tham số truy vấn
      final queryParams = <String, dynamic>{
        'type': 'popular',
        'page': page,
        'size': size,
      };

      // Thêm tham số search nếu có
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
        print('Đang tìm kiếm khóa học với từ khóa: "$search"');
      }

      // Thêm accountId nếu có
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      final endpoint = '$apiUrl/courses/public/filter';
      print('Đang gọi API: $endpoint với tham số: $queryParams');

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

          if (responseData != null &&
              responseData['data'] != null &&
              responseData['data']['content'] != null) {
            // Xử lý trường hợp API trả về cấu trúc phân trang
            final List<CourseCardModel> courses = [];
            responseData['data']['content'].forEach((courseJson) {
              courses.add(CourseCardModel.fromJson(courseJson));
            });

            print('Tìm thấy ${courses.length} khóa học');
            return courses;
          } else {
            // Xử lý trường hợp trả về danh sách trực tiếp (không phân trang)
            return ApiResponseHelper.processList(
                responseData, CourseCardModel.fromJson);
          }
        } else {
          print('Lỗi API (${response.statusCode}): ${response.data}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi Dio khi lấy khóa học: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy khóa học phổ biến: $e');
      return [];
    }
  }

  Future<List<CourseCardModel>> getDiscountCourses() async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?type=discount';
      print('Đang gọi API lấy khóa học giảm giá: $endpoint');

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          print('===== RAW API RESPONSE =====');
          print('Response data type: ${response.data.runtimeType}');
          print('Response data: ${response.data}');

          final courses = ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);

          print('Số lượng khóa học giảm giá trả về từ API: ${courses.length}');

          // Phân loại theo mức giảm giá
          final below10 = courses
              .where((c) => (c.discountPercent > 0 && c.discountPercent <= 10))
              .toList();
          final from10to30 = courses
              .where((c) => (c.discountPercent > 10 && c.discountPercent <= 30))
              .toList();
          final from30to50 = courses
              .where((c) => (c.discountPercent > 30 && c.discountPercent <= 50))
              .toList();
          final from50to70 = courses
              .where((c) => (c.discountPercent > 50 && c.discountPercent <= 70))
              .toList();
          final above70 =
              courses.where((c) => (c.discountPercent > 70)).toList();
          final zero = courses.where((c) => c.discountPercent == 0).toList();

          print('Thống kê mức giảm giá:');
          print('- Không giảm giá (0%): ${zero.length} khóa học');
          print('- Giảm giá 0-10%: ${below10.length} khóa học');
          print('- Giảm giá 10-30%: ${from10to30.length} khóa học');
          print('- Giảm giá 30-50%: ${from30to50.length} khóa học');
          print('- Giảm giá 50-70%: ${from50to70.length} khóa học');
          print('- Giảm giá trên 70%: ${above70.length} khóa học');

          // Kiểm tra % giảm giá của từng khóa học
          print('===== DANH SÁCH KHÓA HỌC GIẢM GIÁ =====');
          for (var course in courses) {
            print(
                'ID: ${course.id}, Tiêu đề: ${course.title}, Giảm giá: ${course.discountPercent}%, Giá: ${course.price}, Giá gốc: ${course.cost}');
          }

          return courses;
        } else {
          print('Lỗi API (${response.statusCode}): ${response.data}');
          return [];
        }
      } on DioException catch (e) {
        print('Lỗi Dio khi lấy khóa học giảm giá: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy khóa học giảm giá: $e');
      return [];
    }
  }

  Future<OverviewCourseModel?> getOverviewCourseDetail(int id) async {
    try {
      final endpoint = '$apiUrl/courses/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;

          Map<String, dynamic> courseData;

          if (responseData != null && responseData['data'] != null) {
            // Nếu API trả về cấu trúc {status, message, data}
            courseData = responseData['data'];
          } else if (responseData != null &&
              responseData is Map<String, dynamic>) {
            // Nếu API trả về đối tượng trực tiếp
            courseData = responseData;
          } else {
            return null;
          }

          return OverviewCourseModel.fromJson(courseData);
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

  Future<List<ReviewCourseModel>> getReviewCourse(int id) async {
    try {
      final endpoint = '$apiUrl/reviews/course/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

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

  Future<List<StructureCourseModel>> getStructureCourse(int id) async {
    try {
      final endpoint = '$apiUrl/courses/$id/lessons-view';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData != null && responseData is List) {
            // API trả về danh sách các chương
            return responseData
                .map((item) => StructureCourseModel.fromJson(item))
                .toList();
          } else if (responseData != null &&
              responseData['data'] != null &&
              responseData['data'] is List) {
            // Nếu API trả về cấu trúc {status, message, data} và data là một mảng
            return (responseData['data'] as List)
                .map((item) => StructureCourseModel.fromJson(item))
                .toList();
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

  Future<List<CourseCardModel>> getRelatedCourse(int categoryId) async {
    try {
      final endpoint = '$apiUrl/courses/public/filter?categoryId=$categoryId';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
              },
            ));

        if (response.statusCode == 200) {
          if (response.data is List) {
            return (response.data as List)
                .map((item) => CourseCardModel.fromJson(item))
                .toList();
          }

          return ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);
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

  // Thêm phương thức tìm kiếm khóa học
  Future<List<CourseCardModel>> searchCourses(String query) async {
    try {
      // Endpoint tìm kiếm, sử dụng tham số search
      final endpoint = '$apiUrl/courses/public/filter?search=$query';
      print('Đang gọi API tìm kiếm khóa học: $endpoint');

      try {
        final response = await dio.get(
          endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          print('Tìm kiếm khóa học thành công với query: $query');
          final courses = ApiResponseHelper.processList(
              response.data, CourseCardModel.fromJson);
          print('Tìm thấy ${courses.length} khóa học');
          return courses;
        } else {
          print('Lỗi API tìm kiếm (${response.statusCode}): ${response.data}');
          // Nếu API không hỗ trợ tìm kiếm trực tiếp, sử dụng danh sách khóa học phổ biến
          // và lọc trên client
          final allCourses = await getPopularCourses();
          if (query.isEmpty) return allCourses;

          final normalizedQuery = query.toLowerCase();
          return allCourses.where((course) {
            final title = course.title.toLowerCase();
            final author = course.author.toLowerCase();
            return title.contains(normalizedQuery) ||
                author.contains(normalizedQuery);
          }).toList();
        }
      } on DioException catch (e) {
        print('Lỗi Dio khi tìm kiếm khóa học: $e');
        return [];
      }
    } catch (e) {
      print('Lỗi khi tìm kiếm khóa học: $e');
      return [];
    }
  }

  // Combo Course API Methods

  // Lấy danh sách combo khóa học với phân trang
  Future<CoursePaginationResponse> getComboCoursesWithPagination({
    String? title,
    int? accountId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      // Thêm tham số tìm kiếm nếu có
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      // Thêm ID người dùng nếu có
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      final endpoint = '$apiUrl/course-bundle/public';
      print('Đang gọi API combo khóa học: $endpoint với tham số: $queryParams');

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

        if (responseData != null) {
          Map<String, dynamic> data;

          // Xử lý cấu trúc response
          if (responseData is Map && responseData['data'] != null) {
            data = responseData['data'];
            print('Đã tìm thấy data trong responseData[data]');
          } else {
            data = responseData;
            print('Sử dụng responseData trực tiếp');
          }

          print('Cấu trúc data: ${data.keys}');

          // Biến đổi combo course thành course card để phù hợp với CoursePaginationResponse
          List<CourseCardModel> courses = [];
          if (data['content'] != null && data['content'] is List) {
            print(
                'Tìm thấy ${(data['content'] as List).length} combo courses trong data[content]');

            List<dynamic> contentList = data['content'] as List;
            for (var comboJson in contentList) {
              try {
                // Debug
                print(
                    'Đang xử lý combo: ${comboJson['id']} - ${comboJson['name']}');

                // Parse giá
                double salePrice = 0.0;
                if (comboJson['price'] != null) {
                  salePrice = _parseDouble(comboJson['price']) ?? 0.0;
                }

                double originalPrice = salePrice;
                if (comboJson['cost'] != null) {
                  originalPrice = _parseDouble(comboJson['cost']) ?? salePrice;
                }

                int discount = 0;
                if (comboJson['discount'] != null) {
                  discount = _parseInt(comboJson['discount']) ?? 0;
                }

                // Tính discount nếu không có sẵn
                if (originalPrice > salePrice && discount == 0) {
                  discount = ((originalPrice - salePrice) / originalPrice * 100)
                      .round();
                }

                // Format image URL
                String imageUrl = comboJson['imageUrl'] ?? '';
                if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                  imageUrl = 'http://103.166.143.198:8080' +
                      (imageUrl.startsWith('/') ? '' : '/') +
                      imageUrl;
                }

                // Tạo CourseCardModel trực tiếp từ JSON
                CourseCardModel course = CourseCardModel(
                  id: _parseInt(comboJson['id']) ?? 0,
                  title: comboJson['name']?.toString() ?? '',
                  imageUrl: imageUrl,
                  price: salePrice,
                  cost: originalPrice,
                  author: 'TMS Learn Tech',
                  courseOutput: comboJson['description']?.toString() ?? '',
                  description: comboJson['description']?.toString() ?? '',
                  duration: 0,
                  language: 'Vietnamese',
                  status: true,
                  type: 'COMBO',
                  categoryName: 'Combo Khóa học',
                  discountPercent: discount,
                  isCombo: true,
                );

                courses.add(course);
                print(
                    'Đã thêm combo: ${course.title}, price=${course.price}, cost=${course.cost}');
              } catch (e) {
                print('Lỗi khi parse combo: $e');
              }
            }
          } else {
            print('Không tìm thấy mảng content trong data');
          }

          print('Tổng số combo courses đã parse: ${courses.length}');

          // Tạo response phân trang
          return CoursePaginationResponse(
            content: courses,
            totalElements: data['totalElements'] ?? 0,
            totalPages: data['totalPages'] ?? 0,
            currentPage: data['number'] ?? page,
            pageSize: data['size'] ?? size,
          );
        } else {
          print('Lỗi: API không trả về dữ liệu hợp lệ');
          return CoursePaginationResponse(
            content: [],
            totalElements: 0,
            totalPages: 0,
            currentPage: page,
            pageSize: size,
          );
        }
      } else {
        print('Lỗi API (${response.statusCode}): ${response.data}');
        return CoursePaginationResponse(
          content: [],
          totalElements: 0,
          totalPages: 0,
          currentPage: page,
          pageSize: size,
        );
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách combo khóa học: $e');
      return CoursePaginationResponse(
        content: [],
        totalElements: 0,
        totalPages: 0,
        currentPage: page,
        pageSize: size,
      );
    }
  }

  // Helper methods for parsing
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Lấy thông tin chi tiết về một combo khóa học
  Future<ComboCourseDetailModel?> getComboDetail(int id) async {
    try {
      final endpoint = '$apiUrl/course-bundle/$id';
      print('Đang gọi API chi tiết combo khóa học: $endpoint');

      final response = await dio.get(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        Map<String, dynamic> comboData;
        if (responseData != null && responseData['data'] != null) {
          // Nếu API trả về cấu trúc {status, message, data}
          comboData = responseData['data'];
        } else if (responseData != null &&
            responseData is Map<String, dynamic>) {
          // Nếu API trả về đối tượng trực tiếp
          comboData = responseData;
        } else {
          print('Lỗi: API không trả về dữ liệu hợp lệ');
          return null;
        }

        return ComboCourseDetailModel.fromJson(comboData);
      } else {
        print('Lỗi API (${response.statusCode}): ${response.data}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy chi tiết combo khóa học: $e');
      return null;
    }
  }

  // Tìm kiếm combo khóa học
  Future<List<CourseCardModel>> searchComboCourses(String query) async {
    try {
      final result = await getComboCoursesWithPagination(
        title: query,
        size: 20, // Lấy nhiều kết quả hơn cho tìm kiếm
      );

      return result.content;
    } catch (e) {
      print('Lỗi khi tìm kiếm combo khóa học: $e');
      return [];
    }
  }
}
