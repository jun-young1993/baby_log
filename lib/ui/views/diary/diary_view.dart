import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

import 'diary_viewmodel.dart';
import '../../widgets/emotion_calendar_widget.dart';
import '../../widgets/emotion_stats_chart.dart';

class DiaryView extends StackedView<DiaryViewModel> {
  const DiaryView({super.key});

  @override
  Widget builder(
    BuildContext context,
    DiaryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '감정 다이어리',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: viewModel.navigateToStatistics,
            icon: const Icon(Icons.analytics, color: Colors.white),
          ),
          IconButton(
            onPressed: viewModel.refreshEmotionData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 섹션
          _buildCalendarSection(viewModel),

          // 선택된 날짜 정보 섹션
          if (viewModel.selectedDay != null)
            _buildSelectedDaySection(viewModel),

          // 월별 통계 섹션
          _buildMonthlyStatsSection(viewModel),
        ],
      ),
    );
  }

  @override
  DiaryViewModel viewModelBuilder(BuildContext context) => DiaryViewModel();

  Widget _buildCalendarSection(DiaryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: viewModel.focusedDay,
        selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
        onDaySelected: viewModel.onDaySelected,
        onPageChanged: viewModel.onPageChanged,
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final emotionData = viewModel.getEmotionDataForDay(day);
            final dominantEmotion = viewModel.getDominantEmotionForDay(day);
            final isToday = isSameDay(day, DateTime.now());
            final isSelected = isSameDay(day, viewModel.selectedDay);

            return EmotionCalendarWidget(
              dominantEmotion: dominantEmotion,
              emotions: emotionData?.emotions ?? {},
              isSelected: isSelected,
              isToday: isToday,
              onTap: () => viewModel.onDaySelected(day, focusedDay),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDaySection(DiaryViewModel viewModel) {
    final selectedEmotions = viewModel.getSelectedDayEmotions();
    if (selectedEmotions == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.calendar_today, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                '${viewModel.selectedDay!.year}년 ${viewModel.selectedDay!.month}월 ${viewModel.selectedDay!.day}일',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '오늘의 감정',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...selectedEmotions.entries.map(
            (entry) => _buildEmotionBar(entry.key, entry.value, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBar(
    String emotion,
    double value,
    DiaryViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            viewModel.getEmojiForEmotion(emotion),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      emotion,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: viewModel.getColorForEmotion(emotion),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsSection(DiaryViewModel viewModel) {
    final monthlyStats = viewModel.getMonthlyEmotionStats();

    return Container(
      margin: const EdgeInsets.all(16),
      child: EmotionStatsChart(
        emotionStats: monthlyStats,
        title:
            '${viewModel.focusedDay.year}년 ${viewModel.focusedDay.month}월 감정 통계',
        showPercentage: true,
      ),
    );
  }
}
