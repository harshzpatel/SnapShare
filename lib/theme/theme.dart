import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Colors.black;
  static const search = Color.fromRGBO(38, 38, 38, 1);
  static const blue = Color(0xff4a5df9);
  static const primary = Colors.white;
  static const secondary = Colors.grey;
}

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.background,
  );
}
