import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = _getValidUri(widget.videoUrl);

      _videoPlayerController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          // 伪造 Referer 和 User-Agent 以绕过部分防盗链限制
          'Referer': uri.origin,
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
        },
      );

      await _videoPlayerController.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: widget.autoPlay,
          looping: widget.looping,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: Text(
                '无法播放视频',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
      });
    } catch (e) {
      setState(() {
        _isError = true;
      });
      debugPrint('Error initializing video player: $e');
    }
  }

  Uri _getValidUri(String url) {
    Uri uri = Uri.parse(url);
    if (!uri.hasScheme) {
      // 如果没有协议头，默认添加 https
      uri = Uri.parse('https://$url');
    }
    return uri;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey),
              SizedBox(height: 8),
              Text('视频加载失败', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    }

    return Container(
      height: 200,
      color: Colors.black12,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
