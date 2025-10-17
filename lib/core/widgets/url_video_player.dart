import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// URL video player widget for network video streaming
/// Displays basic play/pause controls for remote videos
class UrlVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final double? aspectRatio;

  const UrlVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.aspectRatio,
  });

  @override
  State<UrlVideoPlayer> createState() => _UrlVideoPlayerState();
}

class _UrlVideoPlayerState extends State<UrlVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(UrlVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _hasError = false;
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      debugPrint('🎬 Initializing video from URL: ${widget.videoUrl}');
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Add listener to trigger rebuild when play/pause state changes
      _controller.addListener(_videoListener);

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      debugPrint('✅ Video initialized successfully');
    } catch (e) {
      debugPrint('❌ 동영상 초기화 오류: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _videoListener() {
    // Only rebuild when necessary (play/pause state changes)
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '동영상을 불러올 수 없습니다',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage ?? '네트워크 연결을 확인해주세요',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Thumbnail image if available
            if (widget.thumbnailUrl != null)
              Positioned.fill(
                child: Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            // Loading indicator overlay
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '동영상 로딩 중...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          VideoPlayer(_controller),

          // Thumbnail overlay when not playing
          if (!_controller.value.isPlaying && widget.thumbnailUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.thumbnailUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),

          // Play/Pause button overlay
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).colorScheme.primary,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Buffering indicator
          if (_controller.value.isBuffering)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
