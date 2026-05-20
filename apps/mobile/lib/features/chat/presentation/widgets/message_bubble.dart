import 'package:flutter/material.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../data/models/conversation_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              gradient: isMe ? AppGradients.primary : null,
              color: isMe ? null : cs.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
              boxShadow: [
                BoxShadow(
                  color: isMe
                      ? cs.primary.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isMe ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : cs.onSurface,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.82)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? const Color(0xFFB9F4D0)
                            : Colors.white.withValues(alpha: 0.82),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
