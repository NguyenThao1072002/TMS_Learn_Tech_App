import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/notification_item_model.dart';

class NotificationService {
  final Dio dio;

  NotificationService(this.dio);

  /// Lấy danh sách thông báo của người dùng
  Future<List<NotificationItemModel>> getNotifications(int userId,
      {int page = 0, int size = 100}) async {
    try {
      final response = await dio.get(
        '${Constants.BASE_URL}/api/notifications/user/$userId',
        queryParameters: {
          'userId': userId,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200) {
        // Parse the paginated response
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> content = responseData['content'] ?? [];

        // Convert each item to NotificationItemModel
        return content
            .map((item) => NotificationItemModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Đánh dấu thông báo đã đọc
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await dio.put(
        '${Constants.BASE_URL}/api/notifications/$notificationId/read',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<bool> markAllAsRead(int userId) async {
    try {
      final response = await dio.put(
        '${Constants.BASE_URL}/api/notifications/read-all',
        queryParameters: {'userId': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount(int userId) async {
    try {
      debugPrint('Calling API to get unread count for user ID: $userId');
      final response = await dio.get(
        '${Constants.BASE_URL}/api/notifications/user/$userId/unread-count',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('API response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final count = response.data ?? 0;
        debugPrint('Unread notifications count: $count');
        return count;
      } else {
        debugPrint('Failed to get unread count: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}
