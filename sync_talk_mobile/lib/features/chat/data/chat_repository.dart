import '../../../core/services/api.dart';
import 'package:dio/dio.dart';

class ChatRepo {
  Future<List<dynamic>> listConversations() async {
    final resp = await dio.get('/api/conversations');
    return resp.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> listMessagesPaginated(
    String convId, {
    String? cursor,
    int limit = 50,
  }) async {
    final resp = await dio.get(
      '/api/messages/$convId',
      queryParameters: {'cursor': cursor, 'limit': limit},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMessages(
    String conversationId, {
    int page = 1,
  }) async {
    final res = await dio.get('/messages/$conversationId?page=$page&limit=30');
    return res.data['data'] as List<dynamic>;
  }

  Future<String> sendMessage(
    String convId, {
    String content = '',
    List<String> attachments = const [],
    String? parentMessage,
  }) async {
    final resp = await dio.post(
      '/api/messages/$convId',
      data: {
        'content': content,
        'attachments': attachments,
        'parentMessage': parentMessage,
      },
    );
    return resp.data['id'] as String;
  }

  Future<void> markRead(String messageId) async {
    await dio.post('/api/messages/$messageId/read');
  }

  Future<String> uploadFile(String path, String filename) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: filename),
    });
    final resp = await dio.post('/api/uploads', data: form);
    return resp.data['url'] as String;
  }

  Future<void> forwardMessage({
    required String targetConversationId,
    required String forwardOf,
    String text = "",
  }) async {
    await dio.post(
      '/messages',
      data: {
        "conversationId": targetConversationId,
        "message": text,
        "forwardOf": forwardOf,
      },
    );
  }

  Future<List<dynamic>> getConversations() async {
    final res = await dio.get('/conversations');
    return res.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createPrivateChat(String userId) async {
    final res = await dio.post(
      '/conversations/private',
      data: {"userId": userId},
    );
    return res.data['data'];
  }
}
// final chatRepositoryProvider = Provider((ref) => ChatRepository());

final chatRepo = ChatRepo();
