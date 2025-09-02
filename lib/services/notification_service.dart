import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    await _initializeLocalNotifications();

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

    String? token = await _fcm.getToken();

    if (token != null) {
      await saveTokenToFirestore(token);
    }

    if (kDebugMode) {
      print("Firebase Messaging Token: $token");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      final data = message.data;

      if (data['username'] != null &&
          data['message'] != null &&
          data['profImage'] != null) {
        showChatNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          username: data['username'],
          message: data['message'],
          profImage: data['profImage'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app from terminated state: ${message.data}');
      }
      // You can add navigation logic here
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('Initial message from terminated state: ${initialMessage.data}');
      }
      // You can add navigation logic here
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap when the app is in the foreground/background
        if (kDebugMode) {
          print('Notification tapped with payload: ${response.payload}');
        }
      },
    );
  }

  Future<String> _downloadAndSaveCircularFile(
    String url,
    String fileName, {
    int size = 128,
  }) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName.png';

    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download image: ${response.statusCode}');
    }

    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size,
      targetHeight: size,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..isAntiAlias = true;
    final double w = size.toDouble();

    final Path clipPath = Path()..addOval(Rect.fromLTWH(0, 0, w, w));
    canvas.clipPath(clipPath);

    final Rect src = Rect.fromLTWH(
      0,
      0,
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );
    final Rect dst = Rect.fromLTWH(0, 0, w, w);
    canvas.drawImageRect(originalImage, src, dst, paint);

    final ui.Image roundedImage = await recorder.endRecording().toImage(
      size,
      size,
    );
    final ByteData? pngBytes = await roundedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (pngBytes == null) throw Exception('Failed to encode rounded image');

    final File file = File(filePath);
    await file.writeAsBytes(pngBytes.buffer.asUint8List());
    return filePath;
  }

  // Future<String> _downloadAndSaveFile(String url, String fileName) async {
  //   final Directory directory = await getTemporaryDirectory();
  //   final String filePath = '${directory.path}/$fileName';
  //   final http.Response response = await http.get(Uri.parse(url));
  //   final File file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }

  Future<void> showChatNotification({
    required int id,
    required String username,
    required String message,
    required String profImage,
  }) async {
    final String roundedPath = await _downloadAndSaveCircularFile(
      profImage,
      'profile_circle',
      size: 128,
    );

    final Person sender = Person(
      name: username,
      icon: BitmapFilePathAndroidIcon(roundedPath),
      important: true,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_messages_channel', // A unique channel ID
          'Chat Messages', // Channel name
          channelDescription: 'Notifications for new chat messages.',
          // Channel description
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: MessagingStyleInformation(
            sender,
            conversationTitle: null, // No title for a 1-on-1 chat
            messages: [Message(message, DateTime.now(), sender)],
          ),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id,
      username, // Title
      message, // Body
      notificationDetails,
      // payload: 'Optional payload data'
    );
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
