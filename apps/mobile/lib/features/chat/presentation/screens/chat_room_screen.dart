import 'package:flutter/material.dart';

import '../../data/models/conversation_model.dart';
import 'chat_detail_screen.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ChatDetailScreen(
      conversation: ConversationModel(
        id: roomId,
        type: 'direct',
        participants: const [
          ParticipantModel(userId: 'remote', name: 'Chat', role: 'user'),
        ],
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
