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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            _HeaderAvatar(conversation: widget.conversation),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.otherParticipantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final typing = state is MessagesLoaded && state.isTyping;
                      return Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: typing
                                  ? const Color(0xFF22C55E)
                                  : cs.onSurfaceVariant.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            typing ? 'typing…' : 'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: typing
                                  ? const Color(0xFF22C55E)
                                  : cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone_rounded, color: cs.primary),
            tooltip: 'Call',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Tính năng gọi sẽ sớm được hỗ trợ.')),
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz_rounded, color: cs.onSurface),
            tooltip: 'More',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_off_outlined),
                      title: const Text('Mute conversation'),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Report issue'),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.waving_hand_rounded,
                                  color: cs.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Say hi to ${widget.conversation.otherParticipantName.split(" ").first}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId !=
                            widget.conversation.participants.first.userId;
                        return MessageBubble(message: message, isMe: isMe);
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
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.conversation});
  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasAvatar = conversation.otherParticipantAvatar != null;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.12),
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(conversation.otherParticipantAvatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasAvatar
                ? null
                : Text(
                    conversation.otherParticipantName[0].toUpperCase(),
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
