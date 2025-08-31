import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
    // await _fcm.requestPermission();
    String? token = await _fcm.getToken();

    if (token != null) {
      await saveTokenToFirestore(token);
    }

    if (kDebugMode) {
      print("Firebase Messaging Token: $token");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
      }
      if (kDebugMode) {
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        // You can display a custom notification UI here
      }
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app from terminated state: ${message.data}');
      }
      // Navigate to a specific screen based on the message data
    });

    // Handle initial message when the app is launched from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('Initial message from terminated state: ${initialMessage.data}');
      }
      // Navigate to a specific screen
    }
  }

  Future<void> saveTokenToFirestore(String token) async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc(token)
        .set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> deleteToken() async {
    String userId = _auth.currentUser!.uid;
    String? token = await _fcm.getToken();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc(token)
        .delete();
    }
}
