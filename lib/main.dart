import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapshare/firebase_options.dart';
import 'package:snapshare/providers/user_provider.dart';
import 'package:snapshare/screens/home_screen.dart';
import 'package:snapshare/screens/login_screen.dart';
import 'package:snapshare/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:snapshare/services/notification_service.dart';

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
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _didCache = false;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
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
        debugShowCheckedModeBanner: false,
        title: 'SnapShare',
        theme: AppTheme.dark,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasData) {
              return HomeScreen();
            }

            return LoginScreen();
          },
        ),
      ),
    );
  }
}
