import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_me/features/auth/controller/auth_controller.dart';
import 'package:you_me/features/chat/repository/chat_repository.dart';
import 'package:you_me/models/chat_contact.dart';

import '../../../models/message.dart';

final chatControllProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({required this.chatRepository, required this.ref});

  Stream<List<ChatContact>> getChatContacts() {
    return chatRepository.getChatContact();
  }

  Stream<List<Message>> getMessages(String reciverUserId) {
    return chatRepository.getChatStream(reciverUserId);
  }

  void sendTextMessage(
      BuildContext context, String text, String receverUserId) {
    print('chat Controler');
    ref.read(userDataAuthProvider).whenData((value) {
      print('Value ${value!.name}');
      chatRepository.sendTextMessage(
          context: context,
          text: text,
          receverUserId: receverUserId,
          senderUser: value);
    });
  }
}
