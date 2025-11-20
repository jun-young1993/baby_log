import 'package:flutter/material.dart';
import 'package:baby_log/core/widgets/url_video_player.dart';

/// MediaViewer - Displays either image or video based on mimetype
/// Handles image zoom and video playback
class MediaViewer extends StatelessWidget {
  final String? url;
  final String? mimetype;
  final String? thumbnailUrl;
  final bool isHidden;

  const MediaViewer({
    super.key,
    required this.url,
    this.mimetype,
    this.thumbnailUrl,
    this.isHidden = false,
  });

  /// Determines if the media is a video based on mimetype
  bool get isVideo {
    if (mimetype == null) return false;
    return mimetype!.toLowerCase().contains('video') ||
        mimetype!.toLowerCase().contains('mp4') ||
        mimetype!.toLowerCase().contains('mov') ||
        mimetype!.toLowerCase().contains('avi');
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _buildErrorState(context);
    }

    // 숨김 처리된 미디어는 별도의 프라이버시 UI로 표시
    if (isHidden) {
      return _buildHiddenState(context);
    }

    // Video doesn't need InteractiveViewer (zoom), and it can cause conflicts
    if (isVideo) {
      return Center(child: _buildVideoPlayer(context));
    }

    // Only images use InteractiveViewer for zoom functionality
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(child: _buildImageViewer(context)),
    );
  }

  /// Builds video player for video media
  Widget _buildVideoPlayer(BuildContext context) {
    return UrlVideoPlayer(videoUrl: url!, thumbnailUrl: thumbnailUrl);
  }

  /// Builds image viewer for image media
  Widget _buildImageViewer(BuildContext context) {
    return Image.network(
      url!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        final int? expected = loadingProgress.expectedTotalBytes;
        final int loaded = loadingProgress.cumulativeBytesLoaded;
        final double? progress = expected != null && expected > 0
            ? loaded / expected
            : null;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorState(context);
      },
    );
  }

  /// Builds error state when media cannot be loaded
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 120,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            isVideo ? '동영상을 불러올 수 없습니다' : '사진을 불러올 수 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '네트워크 연결을 확인해주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds hidden state when media is marked as hidden (privacy mode)
  Widget _buildHiddenState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.4,
                ),
              ),
              child: Icon(
                Icons.visibility_off_rounded,
                size: 34,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isVideo ? '숨김 처리된 동영상입니다' : '숨김 처리된 사진입니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 콘텐츠는 현재 숨김 상태입니다.\n설정에서 다시 표시하도록 변경할 수 있어요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.75),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
