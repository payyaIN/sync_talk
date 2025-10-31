import 'package:hive_flutter/hive_flutter.dart';
import '../../features/chat/data/chat_repository.dart';
import 'connectivity_service.dart';

class OutboxItem {
  final String conversationId;
  final String content;
  final List<String> attachments;
  final String? parentMessage;
  OutboxItem(
    this.conversationId,
    this.content,
    this.attachments,
    this.parentMessage,
  );

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'content': content,
    'attachments': attachments,
    'parentMessage': parentMessage,
  };
  static OutboxItem fromJson(Map<String, dynamic> j) => OutboxItem(
    j['conversationId'] as String,
    (j['content'] ?? '') as String,
    List<String>.from(j['attachments'] ?? const []),
    j['parentMessage'] as String?,
  );
}

class OfflineQueue {
  static const _boxName = 'outbox';
  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(_boxName);
    connectivityService.onChanged.listen((online) {
      if (online) processQueue();
    });
  }

  Future<void> enqueue(OutboxItem item) async {
    await init();
    await _box!.add(item.toJson());
  }

  Future<void> processQueue() async {
    await init();
    final toRemove = <int>[];
    for (var k in _box!.keys) {
      final idx = k as int;
      final data = Map<String, dynamic>.from(_box!.get(idx));
      final item = OutboxItem.fromJson(data);
      try {
        await chatRepo.sendMessage(
          item.conversationId,
          content: item.content,
          attachments: item.attachments,
          parentMessage: item.parentMessage,
        );
        toRemove.add(idx);
      } catch (_) {
        break;
      }
    }
    for (final idx in toRemove) {
      await _box!.delete(idx);
    }
  }
}

final offlineQueue = OfflineQueue();
