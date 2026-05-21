import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:crab_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

class MockSocket extends Mock implements io.Socket {}

void main() {
  late MockChatRepository mockRepo;
  late MockSocketClient mockSocketClient;
  late MockSocket mockSocket;

  setUp(() {
    mockRepo = MockChatRepository();
    mockSocketClient = MockSocketClient();
    mockSocket = MockSocket();

    // Mock socket connections
    when(() => mockSocketClient.connect(any()))
        .thenAnswer((_) async => mockSocket);
    when(() => mockSocket.on(any(), any())).thenReturn(() {});
    when(() => mockSocket.emit(any(), any())).thenAnswer((_) => mockSocket);
  });

  group('ChatBloc', () {
    test('initial state is ChatInitial', () {
      final bloc = ChatBloc(mockRepo, mockSocketClient);
      expect(bloc.state, isA<ChatInitial>());
      bloc.close();
    });

    group('LoadConversations', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ConversationsLoaded] on success',
        build: () {
          when(() => mockRepo.getConversations())
              .thenAnswer((_) async => [tConversation]);
          return ChatBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(const LoadConversations()),
        expect: () => [
          isA<ChatLoading>(),
          isA<ConversationsLoaded>()
              .having((s) => s.conversations.length, 'count', 1),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ConversationsLoaded] with empty list',
        build: () {
          when(() => mockRepo.getConversations()).thenAnswer((_) async => []);
          return ChatBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(const LoadConversations()),
        expect: () => [
          isA<ChatLoading>(),
          isA<ConversationsLoaded>()
              .having((s) => s.conversations, 'convs', isEmpty),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatError] on failure',
        build: () {
          when(() => mockRepo.getConversations()).thenThrow(Exception('Error'));
          return ChatBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(const LoadConversations()),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatError>(),
        ],
      );
    });

    group('LoadMessages', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, MessagesLoaded] on success',
        build: () {
          when(() => mockRepo.getMessages('conv-uuid-001'))
              .thenAnswer((_) async => [tMessage, tMessage2]);
          return ChatBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(
          const LoadMessages(conversationId: 'conv-uuid-001'),
        ),
        expect: () => [
          isA<ChatLoading>(),
          isA<MessagesLoaded>()
              .having((s) => s.messages.length, 'msgs', 2)
              .having((s) => s.conversationId, 'convId', 'conv-uuid-001'),
        ],
      );
    });

    group('SendMessage', () {
      blocTest<ChatBloc, ChatState>(
        'adds sent message to list',
        build: () {
          when(() => mockRepo.sendMessage(
                conversationId: 'conv-uuid-001',
                content: 'Hello',
              )).thenAnswer((_) async => tMessage2);
          return ChatBloc(mockRepo, mockSocketClient);
        },
        seed: () => MessagesLoaded(
          conversationId: 'conv-uuid-001',
          messages: [tMessage],
          isTyping: false,
        ),
        act: (bloc) => bloc.add(const SendMessage(
          conversationId: 'conv-uuid-001',
          content: 'Hello',
        )),
        expect: () => [
          isA<MessagesLoaded>().having((s) => s.messages.length, 'msgs', 2),
        ],
      );
    });

    group('MarkConversationRead', () {
      blocTest<ChatBloc, ChatState>(
        'calls markAsRead on repository',
        build: () {
          when(() => mockRepo.markAsRead('conv-uuid-001'))
              .thenAnswer((_) async {});
          return ChatBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc
            .add(const MarkConversationRead(conversationId: 'conv-uuid-001')),
        verify: (_) {
          verify(() => mockRepo.markAsRead('conv-uuid-001')).called(1);
        },
      );
    });
  });
}
