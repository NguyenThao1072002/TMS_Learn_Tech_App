import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:tms_app/domain/repositories/notification_repository.dart';
import 'package:tms_app/core/DI/service_locator.dart';

class NotificationController extends GetxController {
  // Observable list of notifications
  final RxList<NotificationItemModel> notifications =
      <NotificationItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  final NotificationRepository? repository;

  // Constructor with optional repository
  NotificationController({this.repository});

  @override
  void onInit() {
    super.onInit();
    loadNotifications();

    // Listen for new notifications from WebSocket
    if (repository != null) {
      repository!.notificationStream.listen((notification) {
        // Add new notification at the top
        notifications.insert(0, notification);
        // Update unread count
        if (!notification.isRead) {
          unreadCount.value++;
        }
        notifications.refresh();
      });
    }
  }

  // Load all notifications
  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      if (repository != null) {
        final notificationList = await repository!.getNotifications();
        notifications.assignAll(notificationList);
        _updateUnreadCount();
      } else {
        // If no repository provided, try to get from service locator
        try {
          final repo = sl<NotificationRepository>();
          final notificationList = await repo.getNotifications();
          notifications.assignAll(notificationList);

          // Listen for new notifications from WebSocket
          repo.notificationStream.listen((notification) {
            notifications.insert(0, notification);
            if (!notification.isRead) {
              unreadCount.value++;
            }
            notifications.refresh();
          });

          _updateUnreadCount();
        } catch (e) {
          debugPrint('Error getting repository from service locator: $e');
          notifications.clear();
          unreadCount.value = 0;
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      notifications.clear();
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // Update the unread count based on current notifications
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Mark a notification as read
  Future<void> markAsRead(NotificationItemModel notification) async {
    try {
      if (repository != null) {
        await repository!.markAsRead(notification);
      } else {
        // If no repository provided, try to get from service locator
        try {
          final repo = sl<NotificationRepository>();
          await repo.markAsRead(notification);
        } catch (e) {
          debugPrint('Error getting repository from service locator: $e');
        }
      }

      final index =
          notifications.indexWhere((item) => item.id == notification.id);
      if (index != -1) {
        if (!notifications[index].isRead) {
          // Decrease unread count only if it was previously unread
          unreadCount.value--;
        }
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifications.refresh();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Call the repository method to mark all as read if available
      if (repository != null) {
        await repository!.markAllAsRead();
      } else {
        // If no repository provided, try to get from service locator
        try {
          final repo = sl<NotificationRepository>();
          await repo.markAllAsRead();
        } catch (e) {
          debugPrint('Error getting repository from service locator: $e');
        }
      }

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      unreadCount.value = 0;
      notifications.refresh();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Filter notifications by type
  List<NotificationItemModel> getNotificationsByType(NotificationType? type) {
    if (type == null) return notifications;
    return notifications
        .where((notification) => notification.type == type)
        .toList();
  }
}
