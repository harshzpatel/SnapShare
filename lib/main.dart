import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapshare/firebase_options.dart';
import 'package:snapshare/providers/user_provider.dart';
import 'package:snapshare/screens/home_screen.dart';
import 'package:snapshare/screens/login_screen.dart';
import 'package:snapshare/theme/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
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
