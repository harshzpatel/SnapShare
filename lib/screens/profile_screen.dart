import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';
import 'package:instagram/utils/utils.dart';

import '../models/user.dart' as model;
import '../widgets/follow_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  model.User user = model.User.blank;
  bool isFollowing = false;
  late bool isOwnProfile;

  @override
  void initState() {
    super.initState();
    isOwnProfile = widget.uid == FirebaseAuth.instance.currentUser!.uid;
    getUserData();
  }

  void getUserData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        user = model.User.fromSnap(userSnap);
        isFollowing = user.followers.contains(
          FirebaseAuth.instance.currentUser!.uid,
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      if (!mounted) return;

      showSnackBar(e.toString(), context);
    }
  }

  void logOut() {
    FirebaseAuth.instance.signOut();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // model.User user = Provider.of<UserProvider>(context).getUser;

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
                              buildStatColumn(
                                num: user.followers.length,
                                label: 'followers',
                              ),
                              buildStatColumn(
                                num: user.following.length,
                                label: 'following',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              isOwnProfile
                                  ? FollowButton(
                                      backgroundColor: AppColors.background,
                                      borderColor: Colors.grey,
                                      text: 'Edit profile',
                                      textColor: AppColors.primary,
                                      onPressed: null,
                                    )
                                  : isFollowing
                                  ? FollowButton(
                                      backgroundColor: AppColors.primary,
                                      borderColor: Colors.grey,
                                      text: 'Unfollow',
                                      textColor: AppColors.primary,
                                      onPressed: null,
                                    )
                                  : FollowButton(
                                      backgroundColor: AppColors.blue,
                                      borderColor: Colors.blue,
                                      text: 'Follow',
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    user.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 1),
                  child: Text(user.bio),
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
