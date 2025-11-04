import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';

final chatListProvider = StateProvider<List<dynamic>>((ref) => []);
final messageListProvider = StateProvider<List<dynamic>>((ref) => []);
final currentPageProvider = StateProvider<int>((ref) => 1);
final searchResultsProvider = StateProvider<List<dynamic>>((ref) => []);

class ChatViewModel {
  final Ref ref;
  ChatViewModel(this.ref);

  Future<void> loadConversations() async {
    final list = await ref.read(chatRepositoryProvider).getConversations();
    ref.read(chatListProvider.notifier).state = list;
  }

  Future<void> forwardMessage({
    required String targetConversationId,
    required String forwardOf,
    String text = "",
  }) async {
    await ref
        .read(chatRepositoryProvider)
        .forwardMessage(
          targetConversationId: targetConversationId,
          forwardOf: forwardOf,
          text: text,
        );
  }

  Future<void> loadMessages(
    String conversationId, {
    bool loadMore = false,
  }) async {
    final page = ref.read(currentPageProvider);
    final nextPage = loadMore ? page + 1 : 1;
    final msgs = await ref
        .read(chatRepositoryProvider)
        .getMessages(conversationId, page: nextPage);
    if (loadMore) {
      ref.read(messageListProvider.notifier).state = [
        ...msgs,
        ...ref.read(messageListProvider),
      ];
      ref.read(currentPageProvider.notifier).state = nextPage;
    } else {
      ref.read(messageListProvider.notifier).state = msgs;
    }
  }

  // ADD these methods:
  Future<List<dynamic>> searchUsers(String query) async {
    final results = await ref.read(chatRepositoryProvider).searchUsers(query);
    ref.read(searchResultsProvider.notifier).state = results;
    return results;
  }

  Future<Map<String, dynamic>> startPrivateChat(String userId) async {
    return await ref.read(chatRepositoryProvider).createConversation(userId);
  }
}

final chatViewModelProvider = Provider((ref) => ChatViewModel(ref));
