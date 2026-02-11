import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频缩略图组件 - 显示视频第一帧
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    this.width = 160,
    this.height = 90,
    this.onTap,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          'Referer': uri.origin,
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
        },
      );
      await _controller!.initialize();
      // 跳到第一帧并暂停
      await _controller!.seekTo(Duration.zero);
      await _controller!.pause();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading video thumbnail: $e');
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 视频第一帧或占位
              if (_isInitialized && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else if (_isError)
                Center(
                  child: Icon(
                    Icons.video_library,
                    size: 32,
                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                  ),
                )
              else
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              // 播放按钮遮罩
              if (_isInitialized)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

              // 视频标签
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '视频',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
