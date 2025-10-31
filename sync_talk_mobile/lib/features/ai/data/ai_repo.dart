import 'package:dio/dio.dart';
import '../../../core/services/api.dart';

class AiRepo {
  Future<String> suggestReply(List<String> context) async {
    // Keep payload short
    final prompt = context.take(10).join('\n').substring(0, 500);
    final resp = await dio.post('/api/ai/suggest', data: {'prompt': prompt});
    return (resp.data['suggestion'] ?? '👍') as String;
  }

  Future<String> replyFromContext(List<String> context) async {
    final resp = await dio.post(
      '/api/ai/reply',
      data: {'context': context.take(20).toList()},
    );
    return (resp.data['reply'] ?? 'OK') as String;
  }
}

final aiRepo = AiRepo();
