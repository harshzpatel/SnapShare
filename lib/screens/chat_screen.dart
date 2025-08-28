import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapshare/services/chat_service.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverUsername;

  ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverUsername,
  });

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final _auth = FirebaseAuth.instance;

  // Function to send a message
  void _sendMessage() async {
    final String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      await _chatService.sendMessage(receiverId, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverUsername)),
      body: Column(children: [Expanded(child: _buildMessageList()), _buildMessageInput()]),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessagesStream(receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final isMe =
                messageData['senderId'] == _auth.currentUser!.uid;

            return ListTile(
              title: Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    messageData['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // build func for Widget for the message input field and send button
  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
