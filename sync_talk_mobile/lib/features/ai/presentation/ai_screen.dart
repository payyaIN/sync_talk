import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_talk_mobile/core/services/api.dart';
import 'package:sync_talk_mobile/core/widgets/chat_bubble.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final List<Map<String, String>> messages = [
    {
      'sender': 'ai',
      'message': 'Hello! I am your AI assistant. How can I help you today?',
    },
  ];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool loading = false;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await ApiClient.dio.get('/ai/history');
      final List<dynamic> history = res.data['history'];

      if (mounted) {
        setState(() {
          for (var item in history) {
            messages.add({
              'sender': item['sender'].toString(),
              'message': item['message'].toString(),
            });
          }
          initialLoading = false;
        });
        // Scroll to bottom after a short delay to ensure rendering
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          initialLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'me', 'message': text});
      loading = true;
    });
    _scrollToBottom();
    _controller.clear();

    try {
      // Use /suggest as a general chat endpoint for now, or assume backend has a generic chat endpoint.
      // ai.routes.ts has /suggest { prompt } -> { suggestion }
      final res = await ApiClient.dio.post(
        '/ai/suggest',
        data: {'prompt': text},
      );
      final reply = res.data['suggestion'];

      if (mounted) {
        setState(() {
          messages.add({'sender': 'ai', 'message': reply});
          loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messages.add({'sender': 'ai', 'message': 'Error: $e'});
          loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: initialLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (loading && index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: ChatBubble(
                            message: 'Typing...',
                            isMine: false,
                            time: '',
                            status: 'read',
                            color: Colors.black,
                          ),
                        );
                      }
                      final msg = messages[index];
                      final isMine = msg['sender'] == 'me';
                      return ChatBubble(
                        message: msg['message']!,
                        isMine: isMine,
                        time: '', // No time for now
                        status: 'read',
                        color: isMine ? Colors.black : Colors.black,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
