import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final String datePublished;
  final List postUrl;
  final List profilePhoto;
  final likes;

  Post(
    this.description,
    this.uid,
    this.username,
    this.postId,
    this.datePublished,
    this.postUrl,
    this.profilePhoto,
    this.likes,
  );

  Post.fromSnap(DocumentSnapshot snap)
    : username = snap.get('username'),
      description = snap.get('description'),
      uid = snap.get('uid'),
      postId = snap.get('postId'),
      datePublished = snap.get('datePublished'),
      postUrl = snap.get('postUrl'),
      profilePhoto = snap.get('profilePhoto'),
      likes = snap.get('likes');

  Map<String, dynamic> toJson() => {
    'description': description,
    'uid': uid,
    'username': username,
    'postId': postId,
    'datePublished': datePublished,
    'postUrl': postUrl,
    'profilePhoto': profilePhoto,
    'likes': likes,
  };
}
