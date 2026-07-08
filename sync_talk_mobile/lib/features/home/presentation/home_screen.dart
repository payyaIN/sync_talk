import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../core/services/api.dart';
import '../../../core/services/session.dart';
import '../../../core/config/app_env.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _statuses = [];
  List<Map<String, dynamic>> _calls = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('Executing _loadData() action');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user info
      final userResponse = await dio.get('/users/me');
      if (!mounted) return;
      _currentUser = userResponse.data;

      // Load conversations
      final convResponse = await dio.get('/conversations');
      if (!mounted) return;
      _conversations = List<Map<String, dynamic>>.from(convResponse.data);

      // Load statuses
      final statusResponse = await dio.get('/status');
      if (!mounted) return;
      _statuses = List<Map<String, dynamic>>.from(statusResponse.data);

      // Load calls
      final callResponse = await dio.get('/calls');
      if (!mounted) return;
      _calls = List<Map<String, dynamic>>.from(callResponse.data);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (!session.isLoggedInSync) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _extractErrorMessage(e);
      });
    }
  }

  Future<void> _handleRefresh() async {
    print('Executing _handleRefresh() action');
    await _loadData();
  }

  Future<String> _uploadFile(String path, String filename) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: filename),
    });
    final resp = await dio.post('/api/uploads', data: form);
    return resp.data['url'] as String;
  }

  Future<void> _createNewStatus() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final captionController = TextEditingController();
      final caption = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Status Caption'),
          content: TextField(
            controller: captionController,
            decoration: const InputDecoration(hintText: 'Enter status caption...'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, captionController.text.trim()),
              child: const Text('Share'),
            ),
          ],
        ),
      );

      if (caption == null) return;

      setState(() => _isLoading = true);
      final mediaUrl = await _uploadFile(image.path, image.name);
      await dio.post('/api/status', data: {
        'mediaUrl': mediaUrl,
        'caption': caption,
      });

      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share status: ${_extractErrorMessage(e)}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startNewChat() async {
    print('Executing _startNewChat() action');
    final searchText = await showDialog<String>(
      context: context,
      builder: (context) => _SearchUserDialog(controller: _searchController),
    );

    if (searchText == null || searchText.trim().isEmpty) return;

    try {
      // Search for user
      final response = await dio.get(
        '/users/search',
        queryParameters: {'q': searchText.trim()},
      );

      final users = List<Map<String, dynamic>>.from(response.data);

      if (!mounted) return;

      if (users.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No users found')));
        return;
      }

      // Show user selection dialog
      final selectedUser = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _SelectUserDialog(users: users),
      );

      if (selectedUser == null) return;

      // Create or get existing conversation
      final convResponse = await dio.post(
        '/conversations',
        data: {
          'participants': [selectedUser['id'] ?? selectedUser['_id']],
          'isGroup': false,
        },
      );

      if (!mounted) return;

      final conversationId = convResponse.data['id'];
      print('Navigating to chat screen with id: $conversationId');
      context.push('/chat/$conversationId');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${_extractErrorMessage(e)}')),
      );
    }
  }

  Future<void> _initiateCall(Map<String, dynamic>? otherUser, bool isVideo) async {
    if (otherUser == null) return;
    final otherId = otherUser['_id'] ?? otherUser['id'];
    try {
      // Log call history entry
      await dio.post('/api/calls', data: {
        'receiverId': otherId,
        'isVideo': isVideo,
        'isMissed': false,
      });
    } catch (_) {}
    if (mounted) {
      context.push('/call/roomId_${otherId}');
    }
  }

  Future<void> _handleLogout() async {
    print('Executing _handleLogout() action');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await session.clear();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map) {
          return data['error'] ?? data['message'] ?? 'Failed to load data';
        } else if (data is String) {
          try {
            final parsed = jsonDecode(data);
            if (parsed is Map) {
              return parsed['error'] ?? parsed['message'] ?? data;
            }
          } catch (_) {}
          return data;
        }
        return 'Failed to load data';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Please check your internet connection and try again.';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please try again.';
      }
    }
    return 'An unexpected error occurred';
  }

  String _getMediaUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppEnv.baseUrl}$path';
  }

  bool _hasStatus(String userId) {
    return _statuses.any((s) => s['user']?['_id'] == userId || s['user']?['id'] == userId);
  }

  Map<String, dynamic>? _getStatus(String userId) {
    try {
      return _statuses.firstWhere((s) => s['user']?['_id'] == userId || s['user']?['id'] == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SyncTalk',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
            },
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Assistant',
            onPressed: () {
              print('Navigating to AI screen');
              context.push('/ai');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              print('Navigating to profile screen');
              context.push('/profile');
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex == 0
              ? RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: _buildChatsTab(theme),
                )
              : _currentIndex == 1
                  ? RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: _buildStatusTab(theme),
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: _buildCallsTab(theme),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_outlined),
            activeIcon: Icon(Icons.phone),
            label: 'Calls',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.message),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: _createNewStatus,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      );
    } else {
      return FloatingActionButton(
        onPressed: () async {
          // Open a dialog to initiate a call with a user
          if (_conversations.isEmpty) return;
          final confirm = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Start voice/video call'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    final myId = _currentUser?['_id'];
                    Map<String, dynamic>? other;
                    final participants = conversation['participants'] as List?;
                    if (participants != null) {
                      final others = participants.where((p) => p['_id'] != myId).toList();
                      if (others.isNotEmpty) other = others[0];
                    }
                    if (other == null) return const SizedBox.shrink();
                    final activeOther = other;
                    return ListTile(
                      title: Text(activeOther['displayName'] ?? activeOther['email'] ?? 'User'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.blue),
                            onPressed: () => Navigator.pop(context, {'user': activeOther, 'video': false}),
                          ),
                          IconButton(
                            icon: const Icon(Icons.videocam, color: Colors.blue),
                            onPressed: () => Navigator.pop(context, {'user': activeOther, 'video': true}),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          if (confirm != null) {
            _initiateCall(confirm['user'], confirm['video']);
          }
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_call),
      );
    }
  }

  Widget _buildChatsTab(ThemeData theme) {
    if (_errorMessage != null) {
      return _buildErrorState(theme);
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState(theme, 'No Chats Yet', 'Start a new conversation by tapping the button below');
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationTile(conversation, theme);
      },
    );
  }

  Widget _buildStatusTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[300],
                backgroundImage: _currentUser?['avatarUrl'] != null && _currentUser!['avatarUrl'].isNotEmpty
                    ? NetworkImage(_getMediaUrl(_currentUser!['avatarUrl']))
                    : null,
                child: _currentUser?['avatarUrl'] == null || _currentUser!['avatarUrl'].isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              )
            ],
          ),
          title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Tap to share status update'),
          onTap: _createNewStatus,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Text(
            'Recent updates',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
        ),
        if (_statuses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No status updates shared in the last 24 hours',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ..._statuses.map((status) {
          final user = status['user'] as Map<String, dynamic>?;
          final name = user?['displayName'] ?? user?['email'] ?? 'User';
          final avatarUrl = user?['avatarUrl'] as String?;
          final timeStr = status['createdAt'] != null
              ? timeago.format(DateTime.parse(status['createdAt']))
              : '';
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(_getMediaUrl(avatarUrl))
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$timeStr - ${status['caption'] ?? ''}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StatusViewer(
                    name: name,
                    mediaUrl: _getMediaUrl(status['mediaUrl']),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCallsTab(ThemeData theme) {
    if (_calls.isEmpty) {
      return _buildEmptyState(theme, 'No Calls Logged', 'Initiate a voice or video call to populate call history');
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _calls.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final call = _calls[index];
        final myId = _currentUser?['_id'] ?? _currentUser?['id'];
        final isCaller = call['caller']?['_id'] == myId || call['caller']?['id'] == myId;
        final participant = (isCaller ? call['receiver'] : call['caller']) as Map<String, dynamic>?;
        final name = participant?['displayName'] ?? participant?['email'] ?? 'User';
        final avatarUrl = participant?['avatarUrl'] as String?;

        final timeStr = call['createdAt'] != null
            ? timeago.format(DateTime.parse(call['createdAt']))
            : '';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(_getMediaUrl(avatarUrl))
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              Icon(
                isCaller
                    ? Icons.call_made
                    : (call['isMissed'] == true ? Icons.call_missed : Icons.call_received),
                size: 16,
                color: call['isMissed'] == true ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(timeStr),
            ],
          ),
          trailing: IconButton(
            icon: Icon(call['isVideo'] == true ? Icons.videocam : Icons.phone, color: Colors.blueAccent),
            onPressed: () => _initiateCall(participant, call['isVideo'] == true),
          ),
        );
      },
    );
  }

  Widget _buildConversationTile(
    Map<String, dynamic> conversation,
    ThemeData theme,
  ) {
    final myId = _currentUser?['_id'];
    String title = 'Chat';
    String? subtitle;
    String? avatarText;
    Map<String, dynamic>? otherParticipant;

    // Determine conversation title
    if (conversation['isGroup'] == true) {
      title = conversation['title'] ?? 'Group Chat';
      avatarText = title[0].toUpperCase();
    } else {
      final participants = conversation['participants'] as List?;
      if (participants != null) {
        final others = participants.where((p) => p['_id'] != myId).toList();
        if (others.isNotEmpty) {
          otherParticipant = others[0] as Map<String, dynamic>?;
          title = otherParticipant?['displayName'] ?? otherParticipant?['email'] ?? 'User';
          avatarText = title[0].toUpperCase();
        }
      }
    }

    if (conversation['lastMessage'] != null) {
      subtitle = conversation['lastMessage'];
    }

    String? timeText;
    if (conversation['lastMessageAt'] != null) {
      try {
        final date = DateTime.parse(conversation['lastMessageAt']);
        timeText = timeago.format(date, locale: 'en_short');
      } catch (_) {}
    }

    final participantMap = otherParticipant;
    final hasStatusUpdate = participantMap != null && _hasStatus(participantMap['_id'] ?? participantMap['id'] ?? '');

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          if (hasStatusUpdate && participantMap != null) {
            final activeStatus = _getStatus(participantMap['_id'] ?? participantMap['id'] ?? '');
            if (activeStatus != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StatusViewer(
                    name: title,
                    mediaUrl: _getMediaUrl(activeStatus['mediaUrl']),
                  ),
                ),
              );
            }
          }
        },
        child: Container(
          padding: hasStatusUpdate ? const EdgeInsets.all(2) : EdgeInsets.zero,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: hasStatusUpdate ? Border.all(color: Colors.blueAccent, width: 2) : null,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: participantMap?['avatarUrl'] != null && (participantMap?['avatarUrl'] as String).isNotEmpty
                ? NetworkImage(_getMediaUrl(participantMap?['avatarUrl'] as String))
                : null,
            child: participantMap?['avatarUrl'] == null || (participantMap?['avatarUrl'] as String).isEmpty
                ? Text(
                    avatarText ?? '?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600]))
          : Text('No messages yet', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timeText != null)
            Text(
              timeText,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
        ],
      ),
      onTap: () {
        print('Navigating to chat from list item');
        context.push('/chat/${conversation['id'] ?? conversation['_id']}');
      },
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Conversations',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusViewer extends StatefulWidget {
  final String name;
  final String mediaUrl;
  const StatusViewer({super.key, required this.name, required this.mediaUrl});

  @override
  State<StatusViewer> createState() => _StatusViewerState();
}

class _StatusViewerState extends State<StatusViewer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.network(
                widget.mediaUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (ctx, e, st) => const Icon(Icons.broken_image, size: 100, color: Colors.white),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchUserDialog extends StatelessWidget {
  final TextEditingController controller;

  const _SearchUserDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search by email or name',
          prefixIcon: Icon(Icons.search),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text.trim());
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class _SelectUserDialog extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const _SelectUserDialog({required this.users});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select User'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user['displayName'] ?? user['email'] ?? 'User';
            return ListTile(
              leading: CircleAvatar(child: Text(name[0].toUpperCase())),
              title: Text(name),
              subtitle: Text(user['email'] ?? ''),
              onTap: () => Navigator.of(context).pop(user),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
