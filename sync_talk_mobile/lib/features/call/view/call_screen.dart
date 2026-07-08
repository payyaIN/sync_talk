import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/call_socket_service.dart';
import '../../auth/viewmodel/auth_providers.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const CallScreen({super.key, required this.conversationId});
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final _local = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _renderers = {}; // peerId -> renderer
  final Map<String, RTCPeerConnection> _pcs = {};
  MediaStream? _localStream;
  bool micOn = true, camOn = true;
  String? myId;

  @override
  void initState() {
    super.initState();
    myId = ref.read(currentUserIdProvider);
    _init();
  }

  Future<void> _init() async {
    await _local.initialize();
    CallSocketService.connect();
    await _setupLocalMedia();
    _registerSignaling();
    CallSocketService.joinCall(widget.conversationId);
    
    // In a real app, you might want to fetch existing peers or wait for 'user-joined' event using a presence service or call-specific event.
    // For now, valid signaling relies on 'offer' from others or us sending offer if we know who to call.
    // Backend "join_call" just joins the room. It does NOT emit "peers" currently.
    // We should implement "peers" or "user_joined" in backend call.socket.ts if we want mesh networking.
    // For 1-1, we can just wait for offer or send offer if we are the caller.
    // Let's assume we wait for offer or other peer to join.
    // But currently backend doesn't notify when someone joins call room.
    // We will rely on chat presence or just blindly wait for offers.
  }

  Future<void> _setupLocalMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _local.srcObject = stream;
    _localStream = stream;
    setState(() {});
  }

  void _registerSignaling() {
    CallSocketService.onOffer((data) async {
       // data: { from (senderId), sdp, type, roomId } - Backend passes senderId
       // Backend call.socket.ts emits: socket.to(roomId).emit('offer', data) where data was sent by client.
       // Client sends: { roomId, sdp, senderId }
       // So data is { roomId, sdp, senderId }
       final from = data['senderId'];
       if (from == myId) return;

       final pc = await _ensurePC(from);
       await pc.setRemoteDescription(
         RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']), 
       );
       final answer = await pc.createAnswer();
       await pc.setLocalDescription(answer);
       
       CallSocketService.sendAnswer(widget.conversationId, {'sdp': answer.sdp, 'type': answer.type}, myId!);
    });

    CallSocketService.onAnswer((data) async {
       final from = data['senderId'];
       if (from == myId) return;
       final pc = await _ensurePC(from);
       await pc.setRemoteDescription(
         RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']),
       );
    });

    CallSocketService.onIceCandidate((data) async {
       final from = data['senderId'];
       if (from == myId) return;
       final pc = await _ensurePC(from);
       
       // Candidate format from webrtc
       final candidateMap = data['candidate'];
       await pc.addCandidate(
         RTCIceCandidate(
           candidateMap['candidate'],
           candidateMap['sdpMid'],
           candidateMap['sdpMLineIndex'],
         ),
       );
    });
  }

  Future<RTCPeerConnection> _ensurePC(String peerId) async {
    if (_pcs.containsKey(peerId)) return _pcs[peerId]!;
    final pc = await createPeerConnection({
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ],
    });
    _pcs[peerId] = pc;
    // Local tracks
    final stream = _localStream;
    if (stream != null) {
      for (var t in stream.getTracks()) {
        await pc.addTrack(t, stream);
      }
    }
    // Remote track
    pc.onTrack = (event) async {
      if (event.track.kind == 'video') {
        final r = RTCVideoRenderer();
        await r.initialize();
        r.srcObject = event.streams.first;
        _renderers[peerId] = r;
        setState(() {});
      }
    };
    // ICE
    pc.onIceCandidate = (cand) {
      if (cand.candidate != null) {
        CallSocketService.sendIceCandidate(widget.conversationId, {
          'candidate': cand.candidate,
          'sdpMid': cand.sdpMid,
          'sdpMLineIndex': cand.sdpMLineIndex,
        }, myId!);
      }
    };
    return pc;
  }

  // To be called when we want to initiate call
  Future<void> _initiateCall() async {
     // We don't know peer ID here easily unless passed. For now, assume this button sends offer to everyone in room?
     // Or we need the peer ID.
     // In 1-1 chat, we know the friend ID.
     // For now, let's just make a button "Call Everyone".
     // But wait, to create offer, we need a PC?
     // If we don't know who we are calling, we can't create PC per peer.
     // Proper way: Backend sends "user_joined" event.
     // Or frontend fetches participants and iterates.
     // Let's implement a "Invite" or just manual trigger if we had the ID.
     // Simplest for now: User clicks "Call", we assume 1-1, but we need the other person's ID.
     // Let's rely on receiving offer for now, or add a temporary "Start Call" that might need logic update.
  }

  @override
  void dispose() {
    CallSocketService.disconnect();
    for (final id in _pcs.keys.toList()) {
      _pcs[id]?.close();
    }
    for (final r in _renderers.values) {
      r.dispose();
    }
    _localStream?.getTracks().forEach((t) => t.stop());
    _local.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _videoTile('You', _local, mine: true),
      ..._renderers.entries.map((e) => _videoTile('Peer', e.value)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Call')),
      body: GridView.count(crossAxisCount: 2, children: tiles),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(micOn ? Icons.mic : Icons.mic_off),
              onPressed: () {
                for (final t in _localStream?.getAudioTracks() ?? []) {
                  t.enabled = !t.enabled;
                }
                setState(() => micOn = !micOn);
              },
            ),
            IconButton(
              icon: Icon(camOn ? Icons.videocam : Icons.videocam_off),
              onPressed: () {
                for (final t in _localStream?.getVideoTracks() ?? []) {
                  t.enabled = !t.enabled;
                }
                setState(() => camOn = !camOn);
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.call_end),
              label: const Text('End'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoTile(
    String label,
    RTCVideoRenderer renderer, {
    bool mine = false,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned.fill(child: RTCVideoView(renderer, mirror: mine, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
