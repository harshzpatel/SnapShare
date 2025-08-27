import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file, {
    String? postId,
    Function(double)? progressCallback,
  }) async {
    Reference ref = _storage.ref().child(childName);

    if (postId != null) {
      ref = ref.child(_auth.currentUser!.uid).child('$postId.jpg');
    } else {
      ref = ref.child('${_auth.currentUser!.uid}.jpg');
    }

    UploadTask uploadTask = ref.putData(file);

    // Add progress listener
    if (progressCallback != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        progressCallback(progress);
      });
    }

    TaskSnapshot snapshot = await uploadTask;

    String url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<void> deletePost(String postId) async {
    try {
      await _storage
          .ref()
          .child('posts/${_auth.currentUser!.uid}/$postId.jpg')
          .delete();
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }
}
