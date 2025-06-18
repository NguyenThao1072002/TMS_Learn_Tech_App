import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tms_app/core/services/notification_webSocket.dart';
import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:tms_app/data/services/notification_service.dart';
import 'package:tms_app/domain/repositories/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/constants.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationWebSocket notificationWebSocket;
  final NotificationService notificationService;
  final List<NotificationItemModel> _notifications = [];
  final StreamController<NotificationItemModel> _notificationController =
      StreamController<NotificationItemModel>.broadcast();

  NotificationRepositoryImpl(
      this.notificationWebSocket, this.notificationService) {
    _initWebSocket();
  }

  @override
  Stream<NotificationItemModel> get notificationStream =>
      _notificationController.stream;

  void _initWebSocket() {
    // Build WebSocket URL based on BASE_URL in Constants
    final wsUrl = Constants.BASE_URL
            .replaceFirst('http://', 'ws://')
            .replaceFirst('https://', 'wss://') +
        '/ws';

    debugPrint('[NotificationRepository] Connecting to WebSocket: $wsUrl');

    try {
      // Establish connection (idempotent)
      notificationWebSocket.connect(wsUrl);

      // Listen to broadcast stream from NotificationWebSocket
      notificationWebSocket.notificationsStream.listen((message) {
        debugPrint('[NotificationRepository] WS message: $message');

        try {
          // Parse incoming message to JSON
          final Map<String, dynamic> data = json.decode(message);

          Map<String, dynamic> notificationJson;

          // If message is wrapped with readStatus
          if (data.containsKey('notification') &&
              data.containsKey('readStatus')) {
            notificationJson = Map<String, dynamic>.from(data['notification']);
            // API uses true for read, false for unread => convert to isRead bool in model
            notificationJson['status'] = !(data['readStatus'] as bool);
          } else {
            notificationJson = data;
          }

          final notification = NotificationItemModel.fromJson(notificationJson);
          _addNotification(notification);
        } catch (e) {
          debugPrint('[NotificationRepository] Error parsing WS message: $e');
        }
      });
    } catch (e) {
      debugPrint('[NotificationRepository] Error connecting WebSocket: $e');
    }
  }

  // Add a new notification from WebSocket
  void _addNotification(NotificationItemModel notification) {
    // Add to the beginning of the list
    _notifications.insert(0, notification);
    // Notify listeners
    _notificationController.add(notification);
    // debugPrint(
    //     'New notification added: ID=${notification.id}, Title=${notification.title}, Message=${notification.message}');
  }

  // Get current user ID from SharedPreferences
  Future<int> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        return userMap['id'] ?? 7; // Default to 7 if not found
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return 7; // Default user ID if not found
  }

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    try {
      final userId = await _getUserId();
      // debugPrint('Fetching notifications for user ID: $userId');

      final notifications = await notificationService.getNotifications(userId);

      // Update the local notifications list
      _notifications.clear();
      _notifications.addAll(notifications);

      // debugPrint('Fetched ${notifications.length} notifications from API');
      return notifications;
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  @override
  Future<void> markAsRead(NotificationItemModel notification) async {
    try {
      final success = await notificationService.markAsRead(notification.id);
      if (success) {
        final index =
            _notifications.indexWhere((item) => item.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Future<List<NotificationItemModel>> getUnreadNotifications() async {
    return _notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Mark all notifications as read
  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = await _getUserId();
      final success = await notificationService.markAllAsRead(userId);
      if (success) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _notificationController.close();
    notificationWebSocket.disconnect();
  }
}
