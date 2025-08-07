import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'statistics_viewmodel.dart';
import '../../widgets/emotion_stats_chart.dart';

class StatisticsView extends StackedView<StatisticsViewModel> {
  const StatisticsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StatisticsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '감정 통계',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: viewModel.refreshData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기간 선택 섹션
                  _buildPeriodSelector(viewModel),
                  const SizedBox(height: 20),

                  // 요약 카드들
                  _buildSummaryCards(viewModel),
                  const SizedBox(height: 20),

                  // 감정 통계 차트
                  _buildEmotionChart(viewModel),
                  const SizedBox(height: 20),

                  // 평균 감정 점수
                  _buildAverageScores(viewModel),
                  const SizedBox(height: 20),

                  // 데이터 커버리지
                  _buildDataCoverage(viewModel),
                ],
              ),
            ),
    );
  }

  @override
  StatisticsViewModel viewModelBuilder(BuildContext context) =>
      StatisticsViewModel();

  Widget _buildPeriodSelector(StatisticsViewModel viewModel) {
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
          const Text(
            '분석 기간',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: viewModel.selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: '기간 선택',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('주간')),
                    DropdownMenuItem(value: 'month', child: Text('월간')),
                    DropdownMenuItem(value: 'quarter', child: Text('분기')),
                    DropdownMenuItem(value: 'year', child: Text('연간')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.changePeriod(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '선택된 기간: ${viewModel.getPeriodDisplayText()}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(StatisticsViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '가장 자주 나타나는 감정',
                viewModel.getMostFrequentEmotion(),
                Icons.favorite,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '가장 높은 평균 점수',
                viewModel.getHighestAverageEmotion(),
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '데이터가 있는 날',
                '${viewModel.getDaysWithData()}일',
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '데이터 커버리지',
                '${viewModel.getDataCoverage().toStringAsFixed(1)}%',
                Icons.data_usage,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '데이터 없음' : value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: value.isEmpty ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChart(StatisticsViewModel viewModel) {
    final emotionStats = viewModel.getEmotionStatsForPeriod();

    return EmotionStatsChart(
      emotionStats: emotionStats,
      title: '${viewModel.getPeriodDisplayText()} 감정 분포',
      showPercentage: true,
    );
  }

  Widget _buildAverageScores(StatisticsViewModel viewModel) {
    final averageScores = viewModel.getAverageEmotionScores();

    if (averageScores.isEmpty) {
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
        child: const Column(
          children: [
            Text(
              '평균 감정 점수',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '데이터가 없습니다',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
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
          const Text(
            '평균 감정 점수',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...averageScores.entries.map(
            (entry) => _buildAverageScoreBar(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageScoreBar(String emotion, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(score * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getColorForEmotion(emotion),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _getColorForEmotion(emotion),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCoverage(StatisticsViewModel viewModel) {
    final coverage = viewModel.getDataCoverage();
    final daysWithData = viewModel.getDaysWithData();
    final totalDays = viewModel.getTotalDays();

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
          const Text(
            '데이터 커버리지',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coverage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: coverage > 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '$daysWithData일 / $totalDays일',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (coverage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: coverage > 50 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
