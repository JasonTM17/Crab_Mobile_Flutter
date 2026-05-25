import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../data/models/conversation_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_detail_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(const LoadConversations());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: theme.colorScheme.onSurface,
            onPressed: () => showSearch<void>(
              context: context,
              delegate: _ConversationSearchDelegate(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ChatBloc>().add(const LoadConversations());
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const SkeletonList(
                itemCount: 6,
                itemHeight: 76,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              );
            }
            if (state is ChatError) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load chats',
                    subtitle: state.message,
                    actionLabel: 'Retry',
                    onAction: () =>
                        context.read<ChatBloc>().add(const LoadConversations()),
                  ),
                ],
              );
            }
            if (state is ConversationsLoaded) {
              if (state.conversations.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: 60),
                    EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No conversations yet',
                      subtitle:
                          'When you book a ride or order food, your driver and merchant chats will appear here.',
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: state.conversations.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ConversationTile(
                    conversation: state.conversations[index],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ConversationSearchDelegate extends SearchDelegate<void> {
  @override
  String get searchFieldLabel => 'Search conversations';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildContent();

  @override
  Widget buildSuggestions(BuildContext context) => _buildContent();

  Widget _buildContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          query.trim().isEmpty
              ? 'Nhập tên tài xế, nhà hàng hoặc nội dung chat để tìm kiếm.'
              : 'Tính năng tìm kiếm "$query" sẽ sớm được hỗ trợ.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final unread = conversation.unreadCount > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(conversation: conversation),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread
                  ? cs.primary.withValues(alpha: 0.32)
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(conversation: conversation, online: unread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherParticipantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(conversation.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: unread
                                ? cs.primary
                                : cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage?.content ??
                                'Start a conversation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  unread ? cs.onSurface : cs.onSurfaceVariant,
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            constraints: const BoxConstraints(minWidth: 22),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.conversation, required this.online});
  final ConversationModel conversation;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasAvatar = conversation.otherParticipantAvatar != null;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
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
                      fontSize: 18,
                    ),
                  ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
