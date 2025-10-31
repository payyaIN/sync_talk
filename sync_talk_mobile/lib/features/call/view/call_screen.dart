import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/services/sockets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CallScreen extends StatefulWidget {
  final String conversationId;
  const CallScreen({super.key, required this.conversationId});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _local = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _renderers = {}; // peerId -> renderer
  final Map<String, RTCPeerConnection> _pcs = {};
  MediaStream? _localStream;
  bool micOn = true, camOn = true;
  IO.Socket? _chat;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _local.initialize();
    _chat = sockets.chat;
    await _setupLocalMedia();
    _registerSignaling();
    _chat?.emit('call:join', {'conversationId': widget.conversationId});
  }

  Future<void> _setupLocalMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _local.srcObject = stream;
    _localStream = stream;
  }

  void _registerSignaling() {
    _chat?.on('call:peers', (data) async {
      final List peers = (data['peers'] as List? ?? []);
      for (final String pid in peers.cast<String>()) {
        await _createOfferFor(pid);
      }
    });
    _chat?.on('call:offer', (data) async {
      final from = data['from'] as String;
      final pc = await _ensurePC(from);
      await pc.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      _chat?.emit('call:answer', {
        'conversationId': widget.conversationId,
        'to': from,
        'sdp': answer.sdp,
        'type': answer.type,
      });
    });
    _chat?.on('call:answer', (data) async {
      final from = data['from'] as String;
      final pc = await _ensurePC(from);
      await pc.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
    });
    _chat?.on('call:ice', (data) async {
      final from = data['from'] as String;
      final pc = await _ensurePC(from);
      await pc.addCandidate(
        RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ),
      );
    });
    _chat?.on('call:peer-leave', (data) async {
      final pid = data['peerId'] as String;
      await _removePeer(pid);
      setState(() {});
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
        _chat?.emit('call:ice', {
          'conversationId': widget.conversationId,
          'to': peerId,
          'candidate': cand.candidate,
          'sdpMid': cand.sdpMid,
          'sdpMLineIndex': cand.sdpMLineIndex,
        });
      }
    };
    return pc;
  }

  Future<void> _createOfferFor(String peerId) async {
    final pc = await _ensurePC(peerId);
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    _chat?.emit('call:offer', {
      'conversationId': widget.conversationId,
      'to': peerId,
      'sdp': offer.sdp,
      'type': offer.type,
    });
  }

  Future<void> _removePeer(String pid) async {
    final pc = _pcs.remove(pid);
    await pc?.close();
    final r = _renderers.remove(pid);
    await r?.dispose();
  }

  @override
  void dispose() {
    _chat?.emit('call:leave', {'conversationId': widget.conversationId});
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
      ..._renderers.entries.map((e) => _videoTile(e.key, e.value)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Call ${widget.conversationId}')),
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
          Positioned.fill(child: RTCVideoView(renderer, mirror: mine)),
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
