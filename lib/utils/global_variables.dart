import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapshare/screens/add_post_screen.dart';
import 'package:snapshare/screens/feed_screen.dart';
import 'package:snapshare/screens/profile_screen.dart';

import '../screens/search_screen.dart';

final homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  Center(child: const Text('No Notifications')),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
