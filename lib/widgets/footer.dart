import 'package:flutter/material.dart';

import '../theme/theme.dart';

class Footer extends StatelessWidget {
  final String text;
  final String button;
  final VoidCallback onTap;

  const Footer({
    super.key,
    required this.text,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(text),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              " $button",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.link,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
