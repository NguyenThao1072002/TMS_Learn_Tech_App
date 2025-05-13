import 'dart:convert';
import 'dart:io';

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
      print('Data: $body');
      print('Token: $token');

      // Chuyển đổi sang form-data
      var formData = FormData();
      body.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Nếu có file ảnh cần upload
      if (body.containsKey('image') && body['image'] is File) {
        File imageFile = body['image'];
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.put(
        '$baseUrl/api/account/update/$userId', // Đảm bảo đường dẫn API đúng
        data: formData, // Sử dụng form-data
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Không cần set Content-Type khi sử dụng FormData, Dio sẽ tự động thêm
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
