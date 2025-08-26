import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:snapshare/resources/storage_methods.dart';
import 'package:snapshare/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return model.User.fromSnap(snapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List? file,
  }) async {
    String res = 'Something went wrong.';

    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          print('User created : {$cred.user!.uid}');
        }

        String? photoUrl;

        if (file != null) {
          photoUrl = await StorageMethods().uploadImageToStorage(
            'profilePics',
            file,
          );
        }

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = 'success';
      } else {
        res = 'Please fill all the fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        res = 'Invalid email or password.';
      } else if (e.message != null) {
        res = e.message!;
      }

      if (kDebugMode) {
        print(e.toString());
      }
    }

    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Something went wrong.';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        res = 'success';
      } else {
        res = 'Please fill all the fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        res = 'Invalid email or password.';
      } else if (e.message != null) {
        res = e.message!;
      }

      if (kDebugMode) {
        print(e.toString());
      }
    }

    return res;
  }
}
