import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Track availability
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Send a text message or a reply
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required String type,
    String? fileUrl,
    MessageModel? replyToMessage,
  }) async {
    String messageId = _firestore.collection('chats').doc().id;

    MessageModel newMessage = MessageModel(
      messageId: messageId,
      senderId: senderId,
      text: text,
      type: type,
      fileUrl: fileUrl,
      timestamp: Timestamp.now(),
      isEdited: false,
      isDeleted: false,
      replyToId: replyToMessage?.messageId,
      replyToText: replyToMessage?.isDeleted == true ? "Deleted message" : replyToMessage?.text,
    );

    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set(newMessage.toMap());
    
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': type == 'text' ? text : 'Shared a photo/file',
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Edit Message
  Future<void> editMessage(String chatId, String messageId, String newText) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'text': newText,
      'isEdited': true,
    });
  }

  // Delete Message (Soft delete)
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'text': 'This message was deleted',
      'isDeleted': true,
    });
  }

  // Upload Photo to Storage
  Future<String> uploadFile(File file, String chatId) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('chats/$chatId/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Listen to live stream
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
