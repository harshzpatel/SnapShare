import 'package:flutter/material.dart';
import 'package:snapshare/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NotificationService().showChatNotification(
              id: 0,
              username: 'Harsh',
              message: 'hello bro',
              profImage:
                  'https://cdn-icons-png.flaticon.com/512/7915/7915522.png',
            );
          },
          child: Text('noti'),
        ),
      ),
    );
  }
}
