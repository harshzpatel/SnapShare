import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapshare/services/firestore_methods.dart';
import 'package:snapshare/core/utils.dart';

import '../models/user.dart' as model;
import '../services/push_notification_service.dart';
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
  late Future<QuerySnapshot> _postsFuture;

  bool isFollowing = false;
  late bool isOwnProfile;
  bool isLoading = false;

  int _numPosts = 0;
  int _numFollowers = 0;
  int _numFollowing = 0;

  @override
  void initState() {
    super.initState();
    isOwnProfile = widget.uid == FirebaseAuth.instance.currentUser!.uid;

    _postsFuture = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get();

    getUserData();
  }

  void getUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postAgg = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .count()
          .get();

      setState(() {
        user = model.User.fromSnap(userSnap);

        _numPosts = postAgg.count ?? 0;
        _numFollowers = user.followers.length;
        _numFollowing = user.following.length;

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

    setState(() {
      isLoading = false;
    });
  }

  void signOut() async {
    await PushNotificationService().deleteToken();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void followUser() async {
    setState(() {
      isFollowing = !isFollowing;

      if (isFollowing) {
        _numFollowers++;
      } else {
        _numFollowers--;
      }
    });

    String res = await FirestoreMethods().followUser(
      uid: FirebaseAuth.instance.currentUser!.uid,
      followId: widget.uid,
    );

    if (!mounted) return;

    if (res == 'success') {
      if (isFollowing) {
        showSnackBar('You are now following ${user.username}', context);
      } else {
        showSnackBar('You have unfollowed ${user.username}', context);
      }
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text(
                user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: ListView(
              children: [
                _userDetails(context),
                Divider(height: 4, thickness: 1, color: Colors.grey[900]),
                _posts(),
              ],
            ),
          );
  }

  Padding _userDetails(BuildContext context) {
    return Padding(
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
                      children: [
                        buildStatColumn(num: _numPosts, label: 'posts'),
                        buildStatColumn(num: _numFollowers, label: 'followers'),
                        buildStatColumn(num: _numFollowing, label: 'following'),
                      ],
                    ),
                    SizedBox(height: 15),
                    _button(),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 10),
            child: Text(user.bio),
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return isOwnProfile
        ? FollowButton(onPressed: signOut, text: 'Sign out', isOutlined: true)
        : isFollowing
        ? FollowButton(
            onPressed: followUser,
            text: 'Unfollow',
            isOutlined: true,
          )
        : FollowButton(onPressed: followUser, text: 'Follow');
  }

  Widget _posts() {
    return FutureBuilder(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot snap = snapshot.data!.docs[index];

            return Image(
              image: NetworkImage(snap['postUrl']),
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
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
          style: GoogleFonts.signikaNegative(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
