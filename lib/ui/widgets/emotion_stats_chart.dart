import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EmotionStatsChart extends StatelessWidget {
  final Map<String, int> emotionStats;
  final String title;
  final bool showPercentage;

  const EmotionStatsChart({
    super.key,
    required this.emotionStats,
    required this.title,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    if (emotionStats.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildChart()),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final total = emotionStats.values.fold(0, (sum, count) => sum + count);

    return PieChart(
      PieChartData(
        sections: emotionStats.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total) : 0.0;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: showPercentage
                ? '${(percentage * 100).toInt()}%'
                : '${entry.value}',
            color: _getColorForEmotion(entry.key),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: emotionStats.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForEmotion(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} (${entry.value})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            '데이터가 없습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
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
}
