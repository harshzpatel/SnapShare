import 'package:flutter/material.dart';
import 'package:snapshare/core/theme.dart';

class UserTile extends StatelessWidget {
  final String? photoUrl;
  final String username;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.username,
    this.onTap,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage('assets/profile_icon.jpg'),
              foregroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : const AssetImage('assets/profile_icon.jpg'),
              radius: 18,
            ),
            const SizedBox(width: 20),
            Text(
              username,
              style: TextStyle(color: AppColors.primary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
