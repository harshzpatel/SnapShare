import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapshare/firebase_options.dart';
import 'package:snapshare/providers/user_provider.dart';
import 'package:snapshare/screens/chat_screen.dart';
import 'package:snapshare/screens/home_screen.dart';
import 'package:snapshare/screens/login_screen.dart';
import 'package:snapshare/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:snapshare/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }

  final data = message.data;

  if (data['username'] != null &&
      data['message'] != null &&
      data['profImage'] != null) {
    await NotificationService().showChatNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      username: data['username'],
      message: data['message'],
      profImage: data['profImage'],
      senderId: data['senderId'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? initialSenderId;

  final notificationAppLaunchDetails = await NotificationService()
      .getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    initialSenderId =
        notificationAppLaunchDetails!.notificationResponse?.payload;
  }

  runApp(MainApp(initialSenderId: initialSenderId));
}

class MainApp extends StatefulWidget {
  final String? initialSenderId;

  const MainApp({super.key, this.initialSenderId});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _didCache = false;
  DocumentSnapshot<Map<String, dynamic>>? notiUserData;

  @override
  void initState() {
    super.initState();

    if (widget.initialSenderId != null) getNotiUserData();

    NotificationService().initialize();
  }

  Future<void> getNotiUserData() async {
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.initialSenderId)
        .get();

    setState(() {
      notiUserData = userSnap;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didCache) {
      precacheImage(const AssetImage('assets/profile_icon.jpg'), context);
      _didCache = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'SnapShare',
        theme: AppTheme.dark,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasData) {
              if (widget.initialSenderId != null) {
                if (notiUserData == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                return ChatScreen(
                  receiverId: widget.initialSenderId!,
                  receiverUsername: notiUserData?['username'],
                  receiverProfileImage: notiUserData?['photoUrl'],
                );
              }

              return const HomeScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
