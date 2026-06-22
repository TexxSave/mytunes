import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../models/media_item.dart';

class PlayerScreen extends StatefulWidget {
  final List<MediaItem> queue;
  final int startIndex;

  const PlayerScreen({super.key, required this.queue, required this.startIndex});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late int _index;
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  bool _ready = false;

  MediaItem get _current => widget.queue[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    setState(() => _ready = false);
    await _audioPlayer?.dispose();
    await _videoController?.dispose();
    _audioPlayer = null;
    _videoController = null;

    if (_current.kind == MediaKind.audio) {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setFilePath(_current.path);
      _audioPlayer!.play();
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _next();
        }
      });
    } else {
      _videoController = VideoPlayerController.file(File(_current.path));
      await _videoController!.initialize();
      _videoController!.play();
      _videoController!.addListener(() {
        final v = _videoController!.value;
        if (v.duration.inMilliseconds > 0 && v.position >= v.duration) {
          _next();
        }
      });
    }
    if (mounted) setState(() => _ready = true);
  }

  void _next() {
    if (_index < widget.queue.length - 1) {
      setState(() => _index++);
      _loadCurrent();
    }
  }

  void _previous() {
    if (_index > 0) {
      setState(() => _index--);
      _loadCurrent();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_current.title)),
      body: Center(
        child: !_ready
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_current.kind == MediaKind.video && _videoController != null)
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  else
                    const Icon(Icons.music_note, size: 120),
                  const SizedBox(height: 24),
                  Text(_current.title, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 36),
                        onPressed: _previous,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 36),
                        onPressed: _next,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
