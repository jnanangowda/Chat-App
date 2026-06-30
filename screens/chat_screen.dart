import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String receiverName;

  const ChatScreen({
    Key? key, 
    required this.chatId, 
    required this.currentUserId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  MessageModel? replyingTo;
  String? editingMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatService.updateUserStatus(widget.currentUserId, true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chatService.updateUserStatus(widget.currentUserId, true);
    } else {
      _chatService.updateUserStatus(widget.currentUserId, false);
    }
  }

  void _handleSend() async {
    if (_messageController.text.trim().isEmpty) return;

    if (editingMessageId != null) {
      await _chatService.editMessage(widget.chatId, editingMessageId!, _messageController.text.trim());
      setState(() { editingMessageId = null; });
    } else {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        text: _messageController.text.trim(),
        type: 'text',
        replyToMessage: replyingTo,
      );
      setState(() { replyingTo = null; });
    }
    _messageController.clear();
  }

  void _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String url = await _chatService.uploadFile(file, widget.chatId);
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        text: 'Sent a photo',
        type: 'image',
        fileUrl: url,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var msg = MessageModel.fromMap(docs[index].data() as Map<String, dynamic>);
                    bool isMe = msg.senderId == widget.currentUserId;

                    return GestureDetector(
                      onLongPress: () => _showMessageActions(msg),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msg.replyToId != null)
                              Container(
                                padding: const EdgeInsets.all(6),
                                color: Colors.grey[300],
                                child: Text("Replying to: ${msg.replyToText}", style: const TextStyle(fontSize: 11)),
                              ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: msg.type == 'image'
                                  ? Image.network(msg.fileUrl!, width: 200, height: 200)
                                  : Text(msg.text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (replyingTo != null)
            Container(
              color: Colors.amber[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: Text("Replying to: ${replyingTo!.text}")),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => replyingTo = null))
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.photo), onPressed: _pickAndSendImage),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _handleSend),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showMessageActions(MessageModel msg) {
    if (msg.isDeleted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () { Navigator.pop(context); setState(() => replyingTo = msg); },
          ),
          if (msg.senderId == widget.currentUserId) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _messageController.text = msg.text;
                setState(() { editingMessageId = msg.messageId; });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () { Navigator.pop(context); _chatService.deleteMessage(widget.chatId, msg.messageId); },
            ),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
