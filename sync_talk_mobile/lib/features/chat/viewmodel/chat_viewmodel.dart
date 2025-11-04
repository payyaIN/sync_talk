// File: lib/features/chat/viewmodel/chat_viewmodel.dart
// Fixed ChatViewModel with chatRepositoryProvider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';

// ✅ ADD THIS PROVIDER - This was missing!
final chatRepositoryProvider = Provider<ChatRepo>((ref) => chatRepo);

// State providers
final chatListProvider = StateProvider<List<dynamic>>((ref) => []);
final messageListProvider = StateProvider<List<dynamic>>((ref) => []);
final currentPageProvider = StateProvider<int>((ref) => 1);
final searchResultsProvider = StateProvider<List<dynamic>>((ref) => []);

class ChatViewModel {
  final Ref ref;
  ChatViewModel(this.ref);

  /// Load all conversations
  Future<void> loadConversations() async {
    try {
      final list = await ref.read(chatRepositoryProvider).getConversations();
      ref.read(chatListProvider.notifier).state = list;
    } catch (e) {
      print('Error loading conversations: $e');
      rethrow;
    }
  }

  /// Forward a message to another conversation
  Future<void> forwardMessage({
    required String targetConversationId,
    required String forwardOf,
    String text = "",
  }) async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .forwardMessage(
            targetConversationId: targetConversationId,
            forwardOf: forwardOf,
            text: text,
          );
    } catch (e) {
      print('Error forwarding message: $e');
      rethrow;
    }
  }

  /// Load messages for a conversation with pagination
  Future<void> loadMessages(
    String conversationId, {
    bool loadMore = false,
  }) async {
    try {
      final page = ref.read(currentPageProvider);
      final nextPage = loadMore ? page + 1 : 1;

      final msgs = await ref
          .read(chatRepositoryProvider)
          .getMessages(conversationId, page: nextPage);

      if (loadMore) {
        // Prepend older messages
        ref.read(messageListProvider.notifier).state = [
          ...msgs,
          ...ref.read(messageListProvider),
        ];
        ref.read(currentPageProvider.notifier).state = nextPage;
      } else {
        // Replace with fresh messages
        ref.read(messageListProvider.notifier).state = msgs;
        ref.read(currentPageProvider.notifier).state = 1;
      }
    } catch (e) {
      print('Error loading messages: $e');
      rethrow;
    }
  }

  /// Search for users by query
  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final results = await ref.read(chatRepositoryProvider).searchUsers(query);
      ref.read(searchResultsProvider.notifier).state = results;
      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Start a private chat with a user
  Future<Map<String, dynamic>> startPrivateChat(String userId) async {
    try {
      return await ref.read(chatRepositoryProvider).createConversation(userId);
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<String> sendMessage(
    String conversationId, {
    String content = '',
    List<String> attachments = const [],
    String? parentMessage,
  }) async {
    try {
      return await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            conversationId,
            content: content,
            attachments: attachments,
            parentMessage: parentMessage,
          );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await ref.read(chatRepositoryProvider).markRead(messageId);
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  /// Upload a file
  Future<String> uploadFile(String path, String filename) async {
    try {
      return await ref.read(chatRepositoryProvider).uploadFile(path, filename);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }
}

final chatViewModelProvider = Provider((ref) => ChatViewModel(ref));
