import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:tms_app/domain/repositories/notification_repository.dart';

class NotificationUsecase {
  final NotificationRepository repository;

  NotificationUsecase({required this.repository});

  Future<List<NotificationItemModel>> call() async {
    return await repository.getNotifications();
  }

  Future<List<NotificationItemModel>> getUnreadNotifications() async {
    return await repository.getUnreadNotifications();
  }

  Future<void> markAsRead(NotificationItemModel notification) async {
    await repository.markAsRead(notification);
  }

  Stream<NotificationItemModel> get notificationStream =>
      repository.notificationStream;
}
