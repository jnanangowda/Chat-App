import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final String type; // "text", "image", or "file"
  final String? fileUrl;
  final Timestamp timestamp;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId; 
  final String? replyToText;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.type,
    this.fileUrl,
    required this.timestamp,
    required this.isEdited,
    required this.isDeleted,
    this.replyToId,
    this.replyToText,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'replyToId': replyToId,
      'replyToText': replyToText,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      fileUrl: map['fileUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      replyToId: map['replyToId'],
      replyToText: map['replyToText'],
    );
  }
}
