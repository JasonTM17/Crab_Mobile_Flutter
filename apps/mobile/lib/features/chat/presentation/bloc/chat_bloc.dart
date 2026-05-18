import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../../../core/network/socket_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final SocketClient _socketClient;
  io.Socket? _chatSocket;

  ChatBloc(this._chatRepository, this._socketClient)
      : super(const ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<MarkConversationRead>(_onMarkConversationRead);
    on<TypingStarted>(_onTypingStarted);
    on<TypingStopped>(_onTypingStopped);
  }

  Future<void> _connectSocket() async {
    _chatSocket ??= await _socketClient.connect(ApiConstants.chatNamespace);
    _chatSocket!.on('newMessage', (data) {
      add(MessageReceived(messageData: data as Map<String, dynamic>));
    });
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      await _connectSocket();
      final conversations = await _chatRepository.getConversations();
      emit(ConversationsLoaded(conversations: conversations));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      await _connectSocket();
      _chatSocket!.emit('joinConversation', {'conversationId': event.conversationId});
      final messages = await _chatRepository.getMessages(event.conversationId);
      emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = await _chatRepository.sendMessage(
        conversationId: event.conversationId,
        content: event.content,
      );
      final currentState = state;
      if (currentState is MessagesLoaded) {
        emit(currentState.copyWith(
          messages: [message, ...currentState.messages],
        ));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final message = MessageModel.fromJson(event.messageData);
    final currentState = state;
    if (currentState is MessagesLoaded &&
        currentState.conversationId == message.conversationId) {
      emit(currentState.copyWith(
        messages: [message, ...currentState.messages],
      ));
    }
  }

  Future<void> _onMarkConversationRead(
    MarkConversationRead event,
    Emitter<ChatState> emit,
  ) async {
    await _chatRepository.markAsRead(event.conversationId);
  }

  void _onTypingStarted(TypingStarted event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(currentState.copyWith(isTyping: true));
    }
  }

  void _onTypingStopped(TypingStopped event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(currentState.copyWith(isTyping: false));
    }
  }

  @override
  Future<void> close() {
    _chatSocket?.emit('leaveConversation', {});
    _chatSocket?.dispose();
    return super.close();
  }
}
