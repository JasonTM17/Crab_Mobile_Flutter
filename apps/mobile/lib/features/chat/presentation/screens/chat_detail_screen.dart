import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/conversation_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
          LoadMessages(conversationId: widget.conversation.id),
        );
    context.read<ChatBloc>().add(
          MarkConversationRead(conversationId: widget.conversation.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.conversation.otherParticipantAvatar != null
                  ? NetworkImage(widget.conversation.otherParticipantAvatar!)
                  : null,
              child: widget.conversation.otherParticipantAvatar == null
                  ? Text(widget.conversation.otherParticipantName[0])
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.otherParticipantName,
                  style: const TextStyle(fontSize: 16),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is MessagesLoaded && state.isTyping) {
                      return const Text(
                        'typing...',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Say hello!'),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId !=
                          widget.conversation.participants.first.userId;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          ChatInput(
            onSend: (text) {
              context.read<ChatBloc>().add(
                    SendMessage(
                      conversationId: widget.conversation.id,
                      content: text,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}
