import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:you_me/common/widgets/loader.dart';
import 'package:you_me/features/chat/controller/chat_controller.dart';
import 'package:you_me/widgets/sender_message_card.dart';

import '../../../models/message.dart';
import '../../../widgets/my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String reciverUserId;
  const ChatList({Key? key, required this.reciverUserId}) : super(key: key);

  @override
  ConsumerState createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream:
            ref.read(chatControllProvider).getMessages(widget.reciverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });
          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              var timeSend =
                  DateFormat.Hm().format(snapshot.data![index].timeSent);
              if (message.senderId == FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: message.text,
                  date: timeSend,
                );
              }
              return SenderMessageCard(
                message: message.text,
                date: timeSend,
              );
            },
          );
        });
  }
}
