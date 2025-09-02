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
                  'https://yt3.ggpht.com/yti/ANjgQV8sJ3Ji-ggJxkWTzwW6qwsSQQiARYU9gobaM2O6HUflT6hB=s108-c-k-c0x00ffffff-no-rj',
            );
          },
          child: Text('noti'),
        ),
      ),
    );
  }
}
