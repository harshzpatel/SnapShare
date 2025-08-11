import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String? profImage;
  final List<String> likes;

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Post.fromSnap(DocumentSnapshot snap)
    : username = snap.get('username'),
      description = snap.get('description'),
      uid = snap.get('uid'),
      postId = snap.get('postId'),
      datePublished = snap.get('datePublished'),
      postUrl = snap.get('postUrl'),
      profImage = snap.get('profImage'),
      likes = snap.get('likes');

  Map<String, dynamic> toJson() => {
    'description': description,
    'uid': uid,
    'username': username,
    'postId': postId,
    'datePublished': datePublished,
    'postUrl': postUrl,
    'profImage': profImage,
    'likes': likes,
  };
}
