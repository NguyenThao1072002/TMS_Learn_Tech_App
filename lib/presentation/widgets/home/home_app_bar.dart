import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final int unreadNotifications;

  const HomeAppBarWidget({
    super.key,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'TMS Learn Tech',
            style: TextStyle(
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Color(0xFF3498DB),
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
