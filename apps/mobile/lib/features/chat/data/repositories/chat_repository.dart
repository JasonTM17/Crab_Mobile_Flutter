import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';

@injectable
class ChatRepository {
  final DioClient _dioClient;

  ChatRepository(this._dioClient);

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dioClient.dio.get('/chat/conversations');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dioClient.dio.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
  }) async {
    final response = await _dioClient.dio.post(
      '/chat/conversations/$conversationId/messages',
      data: {'content': content, 'type': type},
    );
    return MessageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> markAsRead(String conversationId) async {
    await _dioClient.dio.patch('/chat/conversations/$conversationId/read');
  }
}
