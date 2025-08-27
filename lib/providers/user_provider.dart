import 'package:flutter/widgets.dart';
import 'package:snapshare/models/user.dart';
import 'package:snapshare/services/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user ?? User.temp;

  Future<void> refreshUser() async {
    _user = await _authMethods.getUserDetails();

    notifyListeners();
  }
}
