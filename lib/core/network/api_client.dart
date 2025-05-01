import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tms_app/core/utils/vietnamese_decoder.dart';

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

        // Kiểm tra và sửa lỗi encoding tiếng Việt
        responseBody = VietnameseDecoder.fixEncoding(responseBody);

        // Parse JSON sau khi đã sửa encoding
        dynamic jsonData = jsonDecode(responseBody);

        // Đối với mảng hoặc đối tượng, áp dụng sửa lỗi cho các trường text
        if (jsonData is Map && jsonData.containsKey('data')) {
          jsonData = _fixEncodingInJson(jsonData);
        }

        return jsonData;
      } catch (e) {
        throw Exception('Lỗi xử lý dữ liệu: $e');
      }
    } else {
      throw Exception(
          'Lỗi API: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Hàm đệ quy để sửa lỗi encoding cho tất cả các trường trong JSON
  dynamic _fixEncodingInJson(dynamic json) {
    if (json is Map) {
      Map result = {};
      json.forEach((key, value) {
        if (value is String) {
          result[key] = VietnameseDecoder.fixEncoding(value);
        } else if (value is Map || value is List) {
          result[key] = _fixEncodingInJson(value);
        } else {
          result[key] = value;
        }
      });
      return result;
    } else if (json is List) {
      return json.map((item) => _fixEncodingInJson(item)).toList();
    }
    return json;
  }
}
