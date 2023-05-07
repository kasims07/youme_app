import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:you_me/common/enums/message_enum.dart';
import 'package:you_me/common/utils/utils.dart';
import 'package:you_me/models/chat_contact.dart';
import 'package:you_me/models/message.dart';

import '../../../models/user_model.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void _saveDataToContactsSubcollaction(
    UserModel senderUserData,
    UserModel reciverUserData,
    String text,
    DateTime timeSend,
    String reciverUserId,
  ) async {
    //users -> reciver user id -> chats -> current user id -> set data
    var reciverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSend,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(reciverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(reciverChatContact.toMap());

    //users -> current user id -> chats -> reciver user id -> set data
    var senderChatContact = ChatContact(
        name: reciverUserData.name,
        profilePic: reciverUserData.profilePic,
        contactId: reciverUserData.uid,
        timeSent: timeSend,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMesageToMessageSubCollaction(
      {required String reciverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String username,
      required reciverUserName,
      required MessageEnum messageType}) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: reciverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('users')
        .doc(reciverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receverUserId,
    required UserModel senderUser,
  }) async {
    //users -> senderId -> reciverUserId -> message -> messageId -> store massage
    try {
      var timeSend = DateTime.now();
      UserModel reciverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receverUserId).get();
      reciverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      _saveDataToContactsSubcollaction(
        senderUser,
        reciverUserData,
        text,
        timeSend,
        receverUserId,
      );
      _saveMesageToMessageSubCollaction(
          reciverUserId: receverUserId,
          text: text,
          timeSent: timeSend,
          messageType: MessageEnum.text,
          messageId: messageId,
          reciverUserName: reciverUserData.name,
          username: senderUser.name);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
