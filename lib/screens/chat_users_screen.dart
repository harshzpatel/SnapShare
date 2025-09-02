import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../widgets/user_tile.dart';
import 'chat_screen.dart';

class ChatUsersScreen extends StatelessWidget {
  ChatUsersScreen({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users'), titleSpacing: 0),
      body: _buildUsersList(),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ListView(
          children: snapshot.data!
              .where(
                (userData) =>
                    userData['uid'] != FirebaseAuth.instance.currentUser?.uid,
              )
              .map<Widget>((userData) => _buildUsersListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUsersListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    return UserTile(
      photoUrl: userData['photoUrl'],
      username: userData['username'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverUsername: userData['username'],
              receiverId: userData['uid'],
              receiverProfileImage: userData['photoUrl'],
            ),
          ),
        );
      },
    );
  }
}
