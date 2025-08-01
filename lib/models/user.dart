import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String? photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  User.fromSnap(DocumentSnapshot snap)
    : email = snap.get('email'),
      uid = snap.get('uid'),
      photoUrl = snap.get('photoUrl'),
      username = snap.get('username'),
      bio = snap.get('bio'),
      followers = snap.get('followers'),
      following = snap.get('following');

  Map<String, dynamic> toJson() => {
    'username': username,
    'uid': uid,
    'email': email,
    'bio': bio,
    'followers': followers,
    'following': following,
    'photoUrl': photoUrl,
  };
}
