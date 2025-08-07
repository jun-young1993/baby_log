import 'package:flutter/material.dart';

class EmotionCalendarWidget extends StatelessWidget {
  final String dominantEmotion;
  final Map<String, double> emotions;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const EmotionCalendarWidget({
    super.key,
    required this.dominantEmotion,
    required this.emotions,
    this.isSelected = false,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: _getBorderWidth(),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dominantEmotion.isNotEmpty) ...[
                Text(
                  _getEmojiForEmotion(dominantEmotion),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
              ],
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _getIndicatorColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return Colors.blue;
    }
    if (isToday) {
      return Colors.orange;
    }
    if (dominantEmotion.isNotEmpty) {
      return _getColorForEmotion(dominantEmotion).withOpacity(0.3);
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return Colors.blue;
    }
    if (isToday) {
      return Colors.orange;
    }
    if (dominantEmotion.isNotEmpty) {
      return _getColorForEmotion(dominantEmotion);
    }
    return Colors.transparent;
  }

  double _getBorderWidth() {
    if (isSelected || isToday) {
      return 2.0;
    }
    if (dominantEmotion.isNotEmpty) {
      return 1.0;
    }
    return 0.0;
  }

  Color _getIndicatorColor() {
    if (isSelected) {
      return Colors.white;
    }
    if (isToday) {
      return Colors.white;
    }
    if (dominantEmotion.isNotEmpty) {
      return _getColorForEmotion(dominantEmotion);
    }
    return Colors.grey;
  }

  Color _getColorForEmotion(String emotion) {
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
        return Colors.grey;
    }
  }

  String _getEmojiForEmotion(String emotion) {
    switch (emotion) {
      case '웃음':
        return '😊';
      case '울음':
        return '😢';
      case '졸림':
        return '😴';
      case '놀람':
        return '😲';
      case '화남':
        return '😠';
      case '두려움':
        return '😨';
      case '역겨움':
        return '🤢';
      case '경멸':
        return '😏';
      default:
        return '😐';
    }
  }
}
