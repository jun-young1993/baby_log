import 'package:flutter/material.dart';

class EmotionDisplay extends StatelessWidget {
  final Map<String, double> emotions;
  final String dominantEmotion;
  final bool isAnalyzing;

  const EmotionDisplay({
    super.key,
    required this.emotions,
    required this.dominantEmotion,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text(
                '실시간 감정 분석',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isAnalyzing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (dominantEmotion.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getEmotionColor(dominantEmotion).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getEmotionColor(dominantEmotion),
                  width: 1,
                ),
              ),
              child: Text(
                '주요 감정: $dominantEmotion',
                style: TextStyle(
                  color: _getEmotionColor(dominantEmotion),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (emotions.isNotEmpty) ...[
            ...emotions.entries.map(
              (entry) => _buildEmotionBar(entry.key, entry.value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionBar(String emotion, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              emotion,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getEmotionColor(emotion),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '웃음':
        return Colors.yellow;
      case '울음':
        return Colors.blue;
      case '졸림':
        return Colors.grey;
      case '놀람':
        return Colors.orange;
      case '화남':
        return Colors.red;
      case '두려움':
        return Colors.purple;
      case '역겨움':
        return Colors.brown;
      case '경멸':
        return Colors.indigo;
      default:
        return Colors.white;
    }
  }
}
