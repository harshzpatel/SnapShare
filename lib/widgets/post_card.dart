import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://yt3.ggpht.com/yti/ANjgQV8sJ3Ji-ggJxkWTzwW6qwsSQQiARYU9gobaM2O6HUflT6hB=s88-c-k-c0x00ffffff-no-rj',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
