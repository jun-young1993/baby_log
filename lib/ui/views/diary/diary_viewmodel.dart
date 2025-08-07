import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

import '../../../app/app.router.dart';
import '../../../models/daily_emotion.dart';
import '../../../services/daily_emotion_service.dart';

class DiaryViewModel extends BaseViewModel {
  final NavigationService _navigationService = GetIt.I<NavigationService>();
  final DialogService _dialogService = GetIt.I<DialogService>();
  final DailyEmotionService _dailyEmotionService =
      GetIt.I<DailyEmotionService>();

  // 캘린더 상태
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<DailyEmotion> get dailyEmotions => _dailyEmotionService.dailyEmotions;
  bool get isLoading => _dailyEmotionService.isLoading;
  String? get errorMessage => _dailyEmotionService.errorMessage;

  DiaryViewModel() {
    _initializeData();
  }

  /// 초기 데이터 설정
  Future<void> _initializeData() async {
    await _dailyEmotionService.initialize();

    // 샘플 데이터가 없으면 생성
    if (_dailyEmotionService.dailyEmotions.isEmpty) {
      await _dailyEmotionService.generateSampleData();
    }
  }

  /// 선택된 날짜 변경
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// 포커스된 날짜 변경 (월 변경)
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// 특정 날짜의 감정 데이터 가져오기
  DailyEmotion? getEmotionDataForDay(DateTime day) {
    return _dailyEmotionService.getEmotionForDate(day);
  }

  /// 특정 날짜의 주요 감정 가져오기
  String getDominantEmotionForDay(DateTime day) {
    final emotion = getEmotionDataForDay(day);
    if (emotion == null) return '';

    return emotion.dominantEmotion ?? emotion.calculatedDominantEmotion;
  }

  /// 감정에 따른 색상 반환
  Color getColorForEmotion(String emotion) {
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

  /// 감정에 따른 이모지 반환
  String getEmojiForEmotion(String emotion) {
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

  /// 선택된 날짜의 감정 통계 가져오기
  Map<String, double>? getSelectedDayEmotions() {
    if (_selectedDay == null) return null;
    final emotion = getEmotionDataForDay(_selectedDay!);
    return emotion?.emotions;
  }

  /// 월별 감정 통계 가져오기
  Map<String, int> getMonthlyEmotionStats() {
    return _dailyEmotionService.getMonthlyEmotionStats(_focusedDay);
  }

  /// 감정 데이터 새로고침
  Future<void> refreshEmotionData() async {
    setBusy(true);
    try {
      await _dailyEmotionService.refreshEmotionData();
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: '오류',
        description: '감정 데이터를 불러오는데 실패했습니다.',
      );
    } finally {
      setBusy(false);
    }
  }

  /// 홈 화면으로 이동
  void navigateToHome() {
    _navigationService.back();
  }

  /// 통계 화면으로 이동
  void navigateToStatistics() {
    _navigationService.navigateTo(Routes.statisticsView);
  }
}
