import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void logOut() {
    FirebaseAuth.instance.signOut();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user != null ? user.username : 'Loading...'),
            GestureDetector(
              onTap: logOut,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Log out'),
              ),
            ),
          ],
        ),
      );
  }
}
