import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  // Hàm gọi GET API với xử lý encoding
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ??
            {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Hàm gọi POST API với xử lý encoding
  Future<dynamic> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ??
            {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
        body: jsonEncode(body),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Xử lý response với đúng encoding
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Đảm bảo decode đúng UTF-8
        String responseBody = utf8.decode(response.bodyBytes);

        // Parse JSON sau khi đã sửa encoding
        dynamic jsonData = jsonDecode(responseBody);

      

        return jsonData;
      } catch (e) {
        throw Exception('Lỗi xử lý dữ liệu: $e');
      }
    } else {
      throw Exception(
          'Lỗi API: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

 
}
