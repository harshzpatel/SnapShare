import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storageMethods = StorageMethods();

  // upload post
  Future<String> uploadPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String? profImage,
    required String username,
  }) async {
    String res = "Some error occurred";

    try {
      String photoUrl = await _storageMethods.uploadImageToStorage(
        'posts',
        file,
        true,
      );

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        likes: [],
        profImage: profImage,
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
