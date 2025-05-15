import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/user_update_model.dart';
import '../models/user_model.dart';
import '../../core/utils/constants.dart';

class UserService {
  final Dio dio;
  final String baseUrl = Constants.BASE_URL;

  UserService(this.dio);

  // Fetch list of users
  Future<List<UserDto>> getUsers() async {
    try {
      final response = await dio.get('$baseUrl/users');
      // Assuming the API returns a JSON list of user objects
      final List<UserDto> users = (response.data as List)
          .map((userData) => UserDto.fromJson(userData))
          .toList();
      return users;
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  Future<UserProfile> getUserById(String userId) async {
    try {
      // Lấy token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null || token.isEmpty) {
        throw Exception("JWT token not found. Please login again.");
      }

      final response = await dio.get(
        '$baseUrl/api/account/user/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token' // Thêm token vào header
          },
        ),
      );

      // Assuming the API returns a single user object
      final UserProfile user = UserProfile.fromMap(response.data);
      return user;
    } catch (e) {
      throw Exception("Failed to load user detail: $e");
    }
  }

// Update Account
  Future<bool> updateAccount(Map<String, dynamic> body) async {
    try {
      // Lấy userId và token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final token = prefs.getString('jwt');

      if (userId.isEmpty) {
        print("User ID not found in SharedPreferences");
        return false;
      }

      if (token == null || token.isEmpty) {
        print("JWT token not found. Please login again.");
        return false;
      }

      print('URL: $baseUrl/api/account/update/$userId');

      // In chi tiết về kiểu dữ liệu của từng field
      body.forEach((key, value) {
        print('Field: $key, Type: ${value.runtimeType}, Value: $value');
      });

      print('Token: $token');

      // Chuyển đổi sang form-data
      var formData = FormData();

      // Xử lý file ảnh riêng để tránh chuyển đổi không đúng kiểu
      File? imageFile;
      if (body.containsKey('image')) {
        var imageValue = body['image'];
        print('Image value type: ${imageValue.runtimeType}');

        if (imageValue is File) {
          imageFile = imageValue;
          print('Image is File: ${imageFile.path}');
        } else if (imageValue is String && imageValue.isNotEmpty) {
          if (imageValue.startsWith('/')) {
            // Đây là đường dẫn local
            imageFile = File(imageValue);
            print('Image is path string: $imageValue');
          } else {
            // Đây có thể là URL, không cần xử lý đặc biệt
            formData.fields.add(MapEntry('image', imageValue.toString()));
            print('Image is URL string: $imageValue');
          }
        }

        // Xóa khỏi body để không xử lý ở vòng lặp dưới
        body.remove('image');
      }

      // Thêm các trường dữ liệu khác
      body.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
          print('Added field: $key = ${value.toString()}');
        }
      });

      // Nếu có file ảnh, thêm vào form-data
      if (imageFile != null) {
        try {
          var multipart = await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          );
          formData.files.add(MapEntry('image', multipart));
          print('Added image file: ${imageFile.path}');
        } catch (e) {
          print('Error adding image file: $e');
        }
      }

      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.length}');

      final response = await dio.put(
        '$baseUrl/api/account/update/$userId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating account: $e");

      // In chi tiết hơn về lỗi nếu là DioException
      if (e is DioException && e.response != null) {
        print("Error status code: ${e.response?.statusCode}");
        print("Error data: ${e.response?.data}");
      }

      return false;
    }
  }
}
