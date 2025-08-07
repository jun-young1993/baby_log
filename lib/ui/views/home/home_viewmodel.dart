import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';
import '../../../app/app.router.dart';

class HomeViewModel extends BaseViewModel {
  final NavigationService _navigationService = GetIt.I<NavigationService>();
  final DialogService _dialogService = GetIt.I<DialogService>();

  // 감정 통계 데이터
  Map<String, int> _emotionStats = {'웃음': 5, '울음': 2, '졸림': 3, '놀람': 1};

  // 최근 영상 리스트
  List<Map<String, dynamic>> _recentVideos = [
    {
      'id': '1',
      'title': '오늘 아침 웃음',
      'emotion': '웃음',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'thumbnail': 'assets/images/placeholder.jpg',
    },
    {
      'id': '2',
      'title': '점심시간 울음',
      'emotion': '울음',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'thumbnail': 'assets/images/placeholder.jpg',
    },
    {
      'id': '3',
      'title': '오후 졸림',
      'emotion': '졸림',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'thumbnail': 'assets/images/placeholder.jpg',
    },
  ];

  // Getters
  Map<String, int> get emotionStats => _emotionStats;
  List<Map<String, dynamic>> get recentVideos => _recentVideos;

  // 오늘 감정 통계의 총합
  int get totalEmotions =>
      _emotionStats.values.fold(0, (sum, count) => sum + count);

  // 가장 많이 나타난 감정
  String get dominantEmotion {
    if (_emotionStats.isEmpty) return '없음';
    return _emotionStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // 영상 추가 버튼 클릭
  void onAddVideoPressed() {
    // 녹화 화면으로 이동
    _navigationService.navigateTo(Routes.recordingView);
  }

  // 감정 다이어리 버튼 클릭
  void onDiaryPressed() {
    // 감정 다이어리 화면으로 이동
    _navigationService.navigateTo(Routes.diaryView);
  }

  // 영상 아이템 클릭
  void onVideoPressed(String videoId) {
    // TODO: 영상 상세 보기 화면으로 이동 (아직 구현되지 않음)
    // _navigationService.navigateTo('/video/$videoId');

    // 임시로 다이얼로그 표시
    _dialogService.showDialog(
      title: '영상 상세 보기',
      description: '영상 ID: $videoId\n이 기능은 아직 개발 중입니다.',
    );
  }

  // 감정 통계 새로고침
  Future<void> refreshEmotionStats() async {
    setBusy(true);
    try {
      // TODO: API에서 최신 감정 통계 가져오기
      await Future.delayed(const Duration(seconds: 1));
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: '오류',
        description: '감정 통계를 불러오는데 실패했습니다.',
      );
    } finally {
      setBusy(false);
    }
  }

  // 앱 초기화
  Future<void> initialize() async {
    setBusy(true);
    try {
      // TODO: 초기 데이터 로드
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      await _dialogService.showDialog(
        title: '오류',
        description: '앱 초기화에 실패했습니다.',
      );
    } finally {
      setBusy(false);
    }
  }
}
