import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file,
    bool isPost,
  ) async {
    Reference ref = _storage
        .ref()
        .child(childName);
        // .child('${_auth.currentUser!.uid}.jpg');

    if (isPost) {
      String id = '${Uuid().v1()}.jpg';
      ref = ref.child(_auth.currentUser!.uid).child(id);
    } else {
      ref = ref.child('${_auth.currentUser!.uid}.jpg');
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;

    String url = await snapshot.ref.getDownloadURL();

    return url;
  }
}
