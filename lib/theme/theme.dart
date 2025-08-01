import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const backgroundColor = Colors.black;
  static const searchColor = Color.fromRGBO(38, 38, 38, 1);
  static const blueColor = Color(0xff4a5df9);
  static const primaryColor = Colors.white;
  static const secondaryColor = Colors.grey;
}

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.backgroundColor,
  );
}
