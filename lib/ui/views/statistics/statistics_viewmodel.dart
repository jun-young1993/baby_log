import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

import '../../../models/daily_emotion.dart';
import '../../../services/daily_emotion_service.dart';

class StatisticsViewModel extends BaseViewModel {
  final NavigationService _navigationService = GetIt.I<NavigationService>();
  final DialogService _dialogService = GetIt.I<DialogService>();
  final DailyEmotionService _dailyEmotionService =
      GetIt.I<DailyEmotionService>();

  // 통계 기간
  String _selectedPeriod = 'month';
  DateTime _selectedDate = DateTime.now();

  // Getters
  String get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  List<DailyEmotion> get dailyEmotions => _dailyEmotionService.dailyEmotions;
  bool get isLoading => _dailyEmotionService.isLoading;
  String? get errorMessage => _dailyEmotionService.errorMessage;

  StatisticsViewModel() {
    _initializeData();
  }

  /// 초기 데이터 설정
  Future<void> _initializeData() async {
    await _dailyEmotionService.initialize();
    notifyListeners();
  }

  /// 기간 변경
  void changePeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  /// 날짜 변경
  void changeDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// 선택된 기간의 감정 통계 가져오기
  Map<String, int> getEmotionStatsForPeriod() {
    final startDate = _getStartDateForPeriod();
    final endDate = _getEndDateForPeriod();

    return _dailyEmotionService
        .getEmotionsForPeriod(startDate, endDate)
        .fold<Map<String, int>>({}, (stats, emotion) {
          final dominantEmotion =
              emotion.dominantEmotion ?? emotion.calculatedDominantEmotion;
          if (dominantEmotion.isNotEmpty) {
            stats[dominantEmotion] = (stats[dominantEmotion] ?? 0) + 1;
          }
          return stats;
        });
  }

  /// 월별 감정 통계 가져오기
  Map<String, int> getMonthlyEmotionStats() {
    return _dailyEmotionService.getMonthlyEmotionStats(_selectedDate);
  }

  /// 전체 감정 통계 가져오기
  Map<String, int> getAllEmotionStats() {
    return _dailyEmotionService.getAllEmotionStats();
  }

  /// 감정 점수 평균 계산
  Map<String, double> getAverageEmotionScores() {
    final emotions = _getEmotionsForPeriod();
    if (emotions.isEmpty) return {};

    final averages = <String, double>{};
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final emotion in emotions) {
      for (final entry in emotion.emotions.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0.0) + entry.value;
        counts[entry.key] = (counts[entry.key] ?? 0) + 1;
      }
    }

    for (final entry in totals.entries) {
      final count = counts[entry.key] ?? 1;
      averages[entry.key] = entry.value / count;
    }

    return averages;
  }

  /// 가장 자주 나타나는 감정
  String getMostFrequentEmotion() {
    final stats = getEmotionStatsForPeriod();
    if (stats.isEmpty) return '';

    return stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 가장 높은 평균 점수를 가진 감정
  String getHighestAverageEmotion() {
    final averages = getAverageEmotionScores();
    if (averages.isEmpty) return '';

    return averages.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 감정 데이터가 있는 날짜 수
  int getDaysWithData() {
    return _getEmotionsForPeriod().length;
  }

  /// 전체 기간 (일)
  int getTotalDays() {
    final startDate = _getStartDateForPeriod();
    final endDate = _getEndDateForPeriod();
    return endDate.difference(startDate).inDays + 1;
  }

  /// 데이터 커버리지 (백분율)
  double getDataCoverage() {
    final totalDays = getTotalDays();
    if (totalDays == 0) return 0.0;

    return (getDaysWithData() / totalDays) * 100;
  }

  /// 기간별 시작 날짜 계산
  DateTime _getStartDateForPeriod() {
    switch (_selectedPeriod) {
      case 'week':
        return _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
      case 'month':
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      case 'quarter':
        final quarter = ((_selectedDate.month - 1) / 3).floor();
        return DateTime(_selectedDate.year, quarter * 3 + 1, 1);
      case 'year':
        return DateTime(_selectedDate.year, 1, 1);
      default:
        return _selectedDate;
    }
  }

  /// 기간별 끝 날짜 계산
  DateTime _getEndDateForPeriod() {
    switch (_selectedPeriod) {
      case 'week':
        final startDate = _getStartDateForPeriod();
        return startDate.add(const Duration(days: 6));
      case 'month':
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      case 'quarter':
        final quarter = ((_selectedDate.month - 1) / 3).floor();
        final startDate = DateTime(_selectedDate.year, quarter * 3 + 1, 1);
        return DateTime(_selectedDate.year, quarter * 3 + 4, 0);
      case 'year':
        return DateTime(_selectedDate.year, 12, 31);
      default:
        return _selectedDate;
    }
  }

  /// 선택된 기간의 감정 데이터 가져오기
  List<DailyEmotion> _getEmotionsForPeriod() {
    final startDate = _getStartDateForPeriod();
    final endDate = _getEndDateForPeriod();
    return _dailyEmotionService.getEmotionsForPeriod(startDate, endDate);
  }

  /// 기간 표시 텍스트
  String getPeriodDisplayText() {
    switch (_selectedPeriod) {
      case 'week':
        final startDate = _getStartDateForPeriod();
        final endDate = _getEndDateForPeriod();
        return '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}';
      case 'month':
        return '${_selectedDate.year}년 ${_selectedDate.month}월';
      case 'quarter':
        final quarter = ((_selectedDate.month - 1) / 3).floor() + 1;
        return '${_selectedDate.year}년 ${quarter}분기';
      case 'year':
        return '${_selectedDate.year}년';
      default:
        return '전체';
    }
  }

  /// 감정 데이터 새로고침
  Future<void> refreshData() async {
    setBusy(true);
    try {
      await _dailyEmotionService.refreshEmotionData();
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: '오류',
        description: '데이터를 불러오는데 실패했습니다.',
      );
    } finally {
      setBusy(false);
    }
  }

  /// 뒤로가기
  void goBack() {
    _navigationService.back();
  }
}
