import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../services/chat_service.dart';
import '../widgets/user_tile.dart';
import 'chat_screen.dart';

class ChatUsersScreen extends StatelessWidget {
  ChatUsersScreen({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
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
            builder: (context) => ChatScreen(receiverEmail: userData['email']),
          ),
        );
      },
    );
  }
}

