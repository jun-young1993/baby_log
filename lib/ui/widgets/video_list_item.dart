import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoListItem extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback onTap;

  const VideoListItem({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 썸네일
            _buildThumbnail(),
            const SizedBox(width: 16),

            // 영상 정보
            Expanded(child: _buildVideoInfo()),

            // 감정 표시
            _buildEmotionBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 플레이스홀더 이미지 (실제로는 썸네일 이미지)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.videocam, color: Colors.grey, size: 24),
            ),

            // 재생 버튼
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    final title = video['title'] ?? '제목 없음';
    final timestamp = video['timestamp'] as DateTime? ?? DateTime.now();
    final timeAgo = _getTimeAgo(timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmotionBadge() {
    final emotion = video['emotion'] ?? '알 수 없음';
    final color = _getEmotionColor(emotion);
    final emoji = _getEmotionEmoji(emotion);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            emotion,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '웃음':
        return Colors.orange;
      case '울음':
        return Colors.red;
      case '졸림':
        return Colors.purple;
      case '놀람':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case '웃음':
        return '😊';
      case '울음':
        return '😢';
      case '졸림':
        return '😴';
      case '놀람':
        return '😲';
      default:
        return '😐';
    }
  }
}
