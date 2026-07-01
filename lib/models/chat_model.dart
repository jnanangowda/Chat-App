import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSender;
  final Timestamp lastMessageTime;
  final Map<String, int> unreadCount;
  final String chatName;
  final String? groupImage;
  final bool isGroup;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.chatName,
    this.groupImage,
    this.isGroup = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'chatName': chatName,
      'groupImage': groupImage,
      'isGroup': isGroup,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSender: map['lastMessageSender'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? Timestamp.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      chatName: map['chatName'] ?? '',
      groupImage: map['groupImage'],
      isGroup: map['isGroup'] ?? false,
    );
  }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
