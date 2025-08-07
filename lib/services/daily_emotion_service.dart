import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import '../models/daily_emotion.dart';

class DailyEmotionService with ListenableServiceMixin {
  final ReactiveValue<List<DailyEmotion>> _dailyEmotions =
      ReactiveValue<List<DailyEmotion>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);

  // Getters
  List<DailyEmotion> get dailyEmotions => _dailyEmotions.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  DailyEmotionService() {
    listenToReactiveValues([_dailyEmotions, _isLoading, _errorMessage]);
  }

  /// 초기화 - 저장된 데이터 로드
  Future<void> initialize() async {
    await loadDailyEmotions();
  }

  /// 특정 날짜의 감정 데이터 가져오기
  DailyEmotion? getEmotionForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return _dailyEmotions.value.firstWhere(
        (emotion) =>
            DateTime(emotion.date.year, emotion.date.month, emotion.date.day) ==
            normalizedDate,
      );
    } catch (e) {
      return null;
    }
  }

  /// 특정 월의 감정 데이터 가져오기
  List<DailyEmotion> getEmotionsForMonth(DateTime month) {
    return _dailyEmotions.value.where((emotion) {
      return emotion.date.year == month.year &&
          emotion.date.month == month.month;
    }).toList();
  }

  /// 특정 기간의 감정 데이터 가져오기
  List<DailyEmotion> getEmotionsForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _dailyEmotions.value.where((emotion) {
      return emotion.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          emotion.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 감정 데이터 추가/업데이트
  Future<bool> saveDailyEmotion(DailyEmotion emotion) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final normalizedDate = DateTime(
        emotion.date.year,
        emotion.date.month,
        emotion.date.day,
      );
      final updatedEmotion = emotion.copyWith(date: normalizedDate);

      // 기존 데이터가 있는지 확인
      final existingIndex = _dailyEmotions.value.indexWhere(
        (e) => e.date == normalizedDate,
      );

      List<DailyEmotion> updatedList;
      if (existingIndex != -1) {
        // 기존 데이터 업데이트
        updatedList = List.from(_dailyEmotions.value);
        updatedList[existingIndex] = updatedEmotion.copyWith(
          updatedAt: DateTime.now(),
        );
      } else {
        // 새 데이터 추가
        updatedList = List.from(_dailyEmotions.value)
          ..add(updatedEmotion.copyWith(createdAt: DateTime.now()));
      }

      // 날짜순으로 정렬
      updatedList.sort((a, b) => b.date.compareTo(a.date));

      _dailyEmotions.value = updatedList;

      // 로컬 저장소에 저장
      await _saveToLocalStorage();

      return true;
    } catch (e) {
      _errorMessage.value = '감정 데이터 저장 중 오류가 발생했습니다: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 감정 데이터 삭제
  Future<bool> deleteDailyEmotion(DateTime date) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      final updatedList = _dailyEmotions.value
          .where((e) => e.date != normalizedDate)
          .toList();

      _dailyEmotions.value = updatedList;

      // 로컬 저장소에 저장
      await _saveToLocalStorage();

      return true;
    } catch (e) {
      _errorMessage.value = '감정 데이터 삭제 중 오류가 발생했습니다: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 월별 감정 통계 가져오기
  Map<String, int> getMonthlyEmotionStats(DateTime month) {
    final monthlyEmotions = getEmotionsForMonth(month);
    final stats = <String, int>{};

    for (final emotion in monthlyEmotions) {
      final dominantEmotion =
          emotion.dominantEmotion ?? emotion.calculatedDominantEmotion;
      if (dominantEmotion.isNotEmpty) {
        stats[dominantEmotion] = (stats[dominantEmotion] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// 전체 감정 통계 가져오기
  Map<String, int> getAllEmotionStats() {
    final stats = <String, int>{};

    for (final emotion in _dailyEmotions.value) {
      final dominantEmotion =
          emotion.dominantEmotion ?? emotion.calculatedDominantEmotion;
      if (dominantEmotion.isNotEmpty) {
        stats[dominantEmotion] = (stats[dominantEmotion] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// 감정 데이터 새로고침
  Future<void> refreshEmotionData() async {
    await loadDailyEmotions();
  }

  /// 로컬 저장소에서 데이터 로드
  Future<void> loadDailyEmotions() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final prefs = await SharedPreferences.getInstance();
      final emotionsJson = prefs.getString('daily_emotions');

      if (emotionsJson != null) {
        final List<dynamic> emotionsList = json.decode(emotionsJson);
        final emotions = emotionsList
            .map((json) => DailyEmotion.fromJson(json))
            .toList();

        // 날짜순으로 정렬
        emotions.sort((a, b) => b.date.compareTo(a.date));
        _dailyEmotions.value = emotions;
      } else {
        _dailyEmotions.value = [];
      }
    } catch (e) {
      _errorMessage.value = '감정 데이터 로드 중 오류가 발생했습니다: $e';
      _dailyEmotions.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  /// 로컬 저장소에 데이터 저장
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emotionsJson = json.encode(
        _dailyEmotions.value.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('daily_emotions', emotionsJson);
    } catch (e) {
      _errorMessage.value = '로컬 저장소 저장 중 오류가 발생했습니다: $e';
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage.value = null;
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('daily_emotions');
      _dailyEmotions.value = [];
    } catch (e) {
      _errorMessage.value = '데이터 삭제 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// 임시 데이터 생성 (테스트용)
  Future<void> generateSampleData() async {
    final now = DateTime.now();
    final sampleEmotions = [
      DailyEmotion(
        date: now,
        emotions: {'웃음': 0.8, '울음': 0.1, '졸림': 0.1},
        dominantEmotion: '웃음',
        notes: '오늘은 아기가 많이 웃었어요!',
        createdAt: now,
      ),
      DailyEmotion(
        date: now.subtract(const Duration(days: 1)),
        emotions: {'웃음': 0.3, '울음': 0.6, '졸림': 0.1},
        dominantEmotion: '울음',
        notes: '오늘은 조금 울었지만 괜찮아요.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      DailyEmotion(
        date: now.subtract(const Duration(days: 2)),
        emotions: {'웃음': 0.7, '울음': 0.1, '졸림': 0.2},
        dominantEmotion: '웃음',
        notes: '평온한 하루였어요.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final emotion in sampleEmotions) {
      await saveDailyEmotion(emotion);
    }
  }
}
