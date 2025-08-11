import 'package:flutter/widgets.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user ?? User.temp;

  Future<void> refreshUser() async {
    _user = await _authMethods.getUserDetails();

    notifyListeners();
  }
}
