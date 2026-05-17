abstract class ChatEvent {
  const ChatEvent();
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class LoadMessages extends ChatEvent {
  final String conversationId;
  const LoadMessages({required this.conversationId});
}

class SendMessage extends ChatEvent {
  final String conversationId;
  final String content;
  const SendMessage({required this.conversationId, required this.content});
}

class MessageReceived extends ChatEvent {
  final Map<String, dynamic> messageData;
  const MessageReceived({required this.messageData});
}

class MarkConversationRead extends ChatEvent {
  final String conversationId;
  const MarkConversationRead({required this.conversationId});
}

class TypingStarted extends ChatEvent {
  final String conversationId;
  final String userId;
  const TypingStarted({required this.conversationId, required this.userId});
}

class TypingStopped extends ChatEvent {
  final String conversationId;
  const TypingStopped({required this.conversationId});
}
