import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapshare/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverUsername;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final _auth = FirebaseAuth.instance;

  final _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Scroll to the bottom when the input field gains focus
        Future.delayed(Duration(milliseconds: 300), () => scrollDown());
      }
    });
    
    Future.delayed(Duration(milliseconds: 300), () => scrollDown());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Function to send a message
  void _sendMessage() async {
    final String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, message);
      _messageController.clear();
      scrollDown();
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUsername)),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessagesStream(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final isMe = messageData['senderId'] == _auth.currentUser!.uid;

            return ListTile(
              title: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    messageData['message'],
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
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
              focusNode: _focusNode,
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
