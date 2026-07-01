import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const uuid = Uuid();

  String createChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String text,
    required String type,
    String? fileUrl,
    String? replyToId,
    String? replyToText,
    String? replyToSender,
  }) async {
    try {
      final messageId = uuid.v4();
      final newMessage = MessageModel(
        messageId: messageId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        text: text,
        type: type,
        fileUrl: fileUrl,
        timestamp: Timestamp.now(),
        replyToId: replyToId,
        replyToText: replyToText,
        replyToSender: replyToSender,
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toMap());

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': type == 'text' ? text : '📷 Shared a photo',
        'lastMessageSender': senderId,
        'lastMessageTime': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMessage(String chatId, String messageId, String newText) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newText,
        'isEdited': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': 'This message was deleted',
        'isDeleted': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile(File file, String chatId) async {
    try {
      final fileName = '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = _storage.ref().child('chats/$chatId/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('readBy', arrayContains: userId)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatModel?> getOrCreateChat(String currentUserId, String otherUserId, String otherUserName) async {
    try {
      final chatId = createChatId(currentUserId, otherUserId);
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        final newChat = ChatModel(
          chatId: chatId,
          participants: [currentUserId, otherUserId],
          lastMessage: '',
          lastMessageSender: '',
          lastMessageTime: Timestamp.now(),
          unreadCount: {currentUserId: 0, otherUserId: 0},
          chatName: otherUserName,
          isGroup: false,
        );
        await _firestore.collection('chats').doc(chatId).set(newChat.toMap());
        return newChat;
      }
      return ChatModel.fromFirestore(chatDoc);
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
