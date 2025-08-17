import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../widgets/follow_button.dart';
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
    model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(title: Text(user.username)),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/profile_icon.jpg'),
                      foregroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : AssetImage('assets/profile_icon.jpg'),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // mainAxisSize: MainAxisSize.max,
                            children: [
                              buildStatColumn(num: 10, label: 'posts'),
                              buildStatColumn(num: 20, label: 'followers'),
                              buildStatColumn(num: 30, label: 'following'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FollowButton(
                                backgroundColor: AppColors.background,
                                borderColor: Colors.grey,
                                text: 'Edit profile',
                                textColor: AppColors.primary,
                                onPressed: null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(user.username),
    //         GestureDetector(
    //           onTap: logOut,
    //           child: Container(
    //             padding: EdgeInsets.symmetric(vertical: 8),
    //             child: Text('Log out'),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
  }

  Column buildStatColumn({required int num, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
