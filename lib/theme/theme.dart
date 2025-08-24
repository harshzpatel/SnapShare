import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Colors.black;
  static const search = Color.fromRGBO(38, 38, 38, 1);
  static const blue = Color(0xff4a5df9);
  static const primary = Colors.white;
  static const secondary = Colors.grey;
  static const link = Colors.blueAccent;
  static const paleWhite = Color(0xfff4f5f7);
}

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.search,
      contentTextStyle: TextStyle(color: AppColors.primary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      // selectedItemColor: Colors.red,
      // unselectedItemColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
