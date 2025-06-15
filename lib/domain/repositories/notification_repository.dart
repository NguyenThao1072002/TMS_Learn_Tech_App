import 'package:tms_app/data/models/notification_item_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationItemModel>> getNotifications();
  Future<List<NotificationItemModel>> getUnreadNotifications();
  Future<void> markAsRead(NotificationItemModel notification);
  Future<void> markAllAsRead();
  Stream<NotificationItemModel> get notificationStream;
}
