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
    Function(double)? progressCallback,
  }) async {
    String res = "Some error occurred";

    String postId = const Uuid().v1();

    try {
      String photoUrl = await _storageMethods.uploadImageToStorage(
        'posts',
        file,
        postId: postId,
        progressCallback: progressCallback,
      );

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

  Future<void> likePost({
    required String postId,
    required String uid,
    required List likes,
  }) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<String> postComment({
    required String postId,
    required String text,
    required String username,
    required String? profImage,
  }) async {
    if (text.isEmpty) {
      if (kDebugMode) {
        print("Please enter text");
      }

      return "Please enter text";
    }

    String res = "Some error occurred";

    try {
      String commentId = const Uuid().v1();

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
            'profImage': profImage,
            'username': username,
            'text': text,
            'commentId': commentId,
            'datePublished': DateTime.now(),
          });

      res = "success";
    } catch (e) {
      res = e.toString();

      if (kDebugMode) {
        print(res);
      }
    }

    return res;
  }

  Future<void> deletePost(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    try {
      await deleteCollection(commentsRef);
      await postRef.delete();
      await _storageMethods.deletePost(postId);

      if (kDebugMode) {
        print('post deleted');
      }
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }

  Future<void> deleteCollection(CollectionReference collectionRef) async {
    try {
      QuerySnapshot snapshot = await collectionRef.limit(500).get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      if (kDebugMode) {
        print(
          'Successfully deleted ${snapshot.docs.length} documents from ${collectionRef.id}.',
        );
      }

      if (snapshot.docs.length == 500) {
        await deleteCollection(collectionRef);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting collection ${collectionRef.id}: $e');
      }
    }
  }

  Future<String> followUser({
    required String uid,
    required String followId,
  }) async {
    String res = "Some error occurred";

    try {
      DocumentSnapshot snap = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      List following = snap.get('following');

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });

      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }

      res = "success";
    } catch (e) {
      res = e.toString();

      if (kDebugMode) {
        print(res);
      }
    }

    return res;
  }
}
