import 'package:dio/dio.dart';
import '../models/user_model.dart';

class UserService {
  final Dio dio;
  final String baseUrl = 'http://103.166.143.198:8080';

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
}
