import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';

class ChatService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  ChatService(this.dio);

  // Lấy danh sách hội thoại của người dùng
  Future<List<ChatConversationModel>> getConversations(int userId) async {
    try {
      final endpoint = '$baseUrl/chat/conversations/$userId';

      final response = await dio.get(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ChatConversationModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách hội thoại: $e');
    }
  }

  // Gửi tin nhắn mới
  Future<ChatMessageModel> sendMessage(
      int fromId, int receiveId, String content) async {
    try {
      final endpoint = '$baseUrl/messages';

      final response = await dio.post(
        endpoint,
        data: {
          'fromId': fromId,
          'receiveId': receiveId,
          'content': content,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatMessageModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Đánh dấu tin nhắn là đã đọc
  Future<bool> markAsRead(int messageId) async {
    try {
      final endpoint = '$baseUrl/messages/$messageId/read';

      final response = await dio.put(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu đã đọc: $e');
    }
  }

  // Lấy tin nhắn của một hội thoại
  Future<List<ChatMessageModel>> getMessages(String conversationId, String accountId) async {
    try {
      final endpoint = '$baseUrl/chat/$conversationId/messages?accountId=$accountId';

      final response = await dio.get(
        endpoint,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tải tin nhắn: $e');
    }
  }

  // Tạo hội thoại mới
  Future<ChatConversationModel> createConversation(
      int fromId, int receiveId, String type) async {
    try {
      final endpoint = '$baseUrl/conversations';

      final response = await dio.post(
        endpoint,
        data: {
          'fromId': fromId,
          'receiveId': receiveId,
          'type': type,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatConversationModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          error: 'Lỗi API: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi khi tạo hội thoại: $e');
    }
  }
}
