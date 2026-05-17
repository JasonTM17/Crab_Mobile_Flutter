import '../../data/models/conversation_model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;
  const ConversationsLoaded({required this.conversations});
}

class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<MessageModel> messages;
  final bool isTyping;
  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.isTyping = false,
  });

  MessagesLoaded copyWith({
    List<MessageModel>? messages,
    bool? isTyping,
  }) {
    return MessagesLoaded(
      conversationId: conversationId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
}
