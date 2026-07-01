import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String text;
  final String type;
  final String? fileUrl;
  final Timestamp timestamp;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSender;
  final List<String> readBy;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.text,
    required this.type,
    this.fileUrl,
    required this.timestamp,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.replyToText,
    this.replyToSender,
    this.readBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'text': text,
      'type': type,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'replyToSender': replyToSender,
      'readBy': readBy,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      senderImage: map['senderImage'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      fileUrl: map['fileUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      replyToId: map['replyToId'],
      replyToText: map['replyToText'],
      replyToSender: map['replyToSender'],
      readBy: List<String>.from(map['readBy'] ?? []),
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
