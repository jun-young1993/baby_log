import 'package:flutter/material.dart';

class EmotionSummaryCard extends StatelessWidget {
  final Map<String, int> emotionStats;
  final int totalEmotions;
  final String dominantEmotion;

  const EmotionSummaryCard({
    super.key,
    required this.emotionStats,
    required this.totalEmotions,
    required this.dominantEmotion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘 감정 요약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '총 $totalEmotions개',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 감정 통계 그리드
          _buildEmotionGrid(),
          const SizedBox(height: 16),

          // 주요 감정 표시
          _buildDominantEmotion(),
        ],
      ),
    );
  }

  Widget _buildEmotionGrid() {
    final emotions = emotionStats.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        return _buildEmotionItem(emotion.key, emotion.value);
      },
    );
  }

  Widget _buildEmotionItem(String emotion, int count) {
    final color = _getEmotionColor(emotion);
    final emoji = _getEmotionEmoji(emotion);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emotion,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count회',
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDominantEmotion() {
    if (dominantEmotion == '없음') {
      return const SizedBox.shrink();
    }

    final color = _getEmotionColor(dominantEmotion);
    final emoji = _getEmotionEmoji(dominantEmotion);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '오늘의 주요 감정: $emoji $dominantEmotion',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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
