import 'package:flutter/material.dart';
import 'package:snapshare/core/theme.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isOutlined;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return isOutlined
        ? SizedBox(
            height: 30,
            width: 215,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        : SizedBox(
            height: 30,
            width: 215,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
  }
}
