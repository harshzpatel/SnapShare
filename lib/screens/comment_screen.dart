import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapshare/core/theme.dart';
import 'package:snapshare/core/utils.dart';
import 'package:snapshare/widgets/comment_card.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/firestore_methods.dart';

class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> snap;

  const CommentScreen({super.key, required this.snap});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.hasData ? snapshot.data!.docs.length : 0,
            itemBuilder: (context, index) =>
                CommentCard(snap: snapshot.data!.docs[index].data()),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kBottomNavigationBarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: const AssetImage('assets/profile_icon.jpg'),
                foregroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : const AssetImage('assets/profile_icon.jpg'),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: AppColors.primary),
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      hintStyle: const TextStyle(color: AppColors.secondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  String res = await FirestoreMethods().postComment(
                    postId: widget.snap['postId'],
                    text: _commentController.text,
                    username: user.username,
                    profImage: user.photoUrl,
                  );

                  if (res == 'success') {
                    _commentController.clear();
                  } else {
                    if (!context.mounted) return;

                    showSnackBar(res, context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text('Post', style: TextStyle(color: AppColors.link)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
