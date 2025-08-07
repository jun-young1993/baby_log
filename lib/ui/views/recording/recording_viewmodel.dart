import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../services/camera_service.dart';
import '../../../services/emotion_analysis_service.dart';
import '../../../services/storage_service.dart';

class RecordingViewModel extends BaseViewModel {
  final CameraService _cameraService = GetIt.I<CameraService>();
  final EmotionAnalysisService _emotionService =
      GetIt.I<EmotionAnalysisService>();
  final StorageService _storageService = GetIt.I<StorageService>();
  final NavigationService _navigationService = GetIt.I<NavigationService>();
  final DialogService _dialogService = GetIt.I<DialogService>();

  // 녹화 상태
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;

  // Getters
  bool get isRecording => _isRecording;
  Duration get recordingDuration => _recordingDuration;
  String? get recordingPath => _recordingPath;

  // 감정 분석 상태
  Map<String, double> get currentEmotions => _emotionService.currentEmotions;
  String get dominantEmotion =>
      _emotionService.getDominantEmotion(currentEmotions);
  bool get isAnalyzing => _emotionService.isAnalyzing;

  // 카메라 서비스 상태
  bool get isCameraReady => _cameraService.isReady;
  bool get hasPermission => _cameraService.hasPermission;
  String? get errorMessage => _cameraService.errorMessage;

  /// 카메라 초기화
  Future<void> initializeCamera() async {
    setBusy(true);
    try {
      final success = await _cameraService.initializeCamera();
      if (!success) {
        await _showErrorDialog(
          '카메라 초기화 실패',
          _cameraService.errorMessage ?? '카메라를 초기화할 수 없습니다. 권한을 확인해주세요.',
        );
      }
    } catch (e) {
      await _showErrorDialog('카메라 오류', '카메라 초기화 중 오류가 발생했습니다: $e');
    } finally {
      setBusy(false);
    }
  }

  /// 녹화 시작
  Future<void> startRecording() async {
    if (!isCameraReady || _isRecording) return;

    try {
      setBusy(true);

      // 녹화 파일 경로 설정
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = path.join(directory.path, 'recording_$timestamp.mp4');

      // 녹화 시작
      await _cameraService.cameraController!.startVideoRecording();

      _isRecording = true;
      _recordingDuration = Duration.zero;
      _emotionService.clearResults();

      // 녹화 시간 타이머 시작
      _startRecordingTimer();

      // 실시간 감정 분석 시작
      _startEmotionAnalysis();
    } catch (e) {
      await _showErrorDialog('녹화 실패', '녹화를 시작할 수 없습니다: $e');
    } finally {
      setBusy(false);
    }
  }

  /// 녹화 중지
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      setBusy(true);

      // 녹화 중지
      final videoFile = await _cameraService.cameraController!
          .stopVideoRecording();

      _isRecording = false;
      _recordingPath = videoFile.path;

      // 감정 분석 중지
      _stopEmotionAnalysis();

      // 녹화 결과 저장
      final success = await _storageService.saveRecordingResult(
        videoPath: _recordingPath!,
        emotions: currentEmotions,
        duration: _recordingDuration,
      );

      if (success) {
        // 결과 화면으로 이동
        await _navigationService.navigateTo(
          '/recording-result',
          arguments: {
            'videoPath': _recordingPath,
            'emotions': currentEmotions,
            'duration': _recordingDuration,
          },
        );
      } else {
        await _showErrorDialog(
          '저장 실패',
          _storageService.errorMessage ?? '녹화 결과를 저장할 수 없습니다.',
        );
      }
    } catch (e) {
      await _showErrorDialog('녹화 중지 실패', '녹화를 중지할 수 없습니다: $e');
    } finally {
      setBusy(false);
    }
  }

  /// 카메라 전환
  Future<void> switchCamera() async {
    if (!isCameraReady) return;

    try {
      setBusy(true);
      await _cameraService.switchCamera();
    } catch (e) {
      await _showErrorDialog('카메라 전환 실패', '카메라를 전환할 수 없습니다: $e');
    } finally {
      setBusy(false);
    }
  }

  /// 녹화 시간 타이머
  void _startRecordingTimer() {
    // 1초마다 녹화 시간 업데이트
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
        _startRecordingTimer(); // 재귀적으로 타이머 계속
      }
    });
  }

  /// 실시간 감정 분석 시작
  void _startEmotionAnalysis() {
    _emotionService.startAnalysis();
    // TODO: 실시간 프레임 처리 및 Azure Face API 호출
    _simulateEmotionAnalysis();

    // 실시간 감정 분석 타이머 시작
    _startEmotionAnalysisTimer();
  }

  /// 실시간 감정 분석 타이머
  void _startEmotionAnalysisTimer() {
    // TODO: 실제 Azure Face API 연동
    // 현재는 시뮬레이션으로 2초마다 감정 업데이트
    Future.delayed(const Duration(seconds: 2), () {
      if (_emotionService.isAnalyzing) {
        _simulateEmotionAnalysis();
        _startEmotionAnalysisTimer(); // 재귀적으로 타이머 계속
      }
    });
  }

  /// 감정 분석 중지
  void _stopEmotionAnalysis() {
    _emotionService.stopAnalysis();
  }

  /// 감정 분석 시뮬레이션 (실제로는 Azure Face API 사용)
  void _simulateEmotionAnalysis() {
    // TODO: 실제 Azure Face API 연동
    // 현재는 시뮬레이션 데이터 사용
    // 감정 분석 서비스에서 처리하므로 여기서는 notifyListeners만 호출
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void clearError() {
    _cameraService.clearError();
  }

  /// 카메라 서비스 getter
  CameraService get cameraService => _cameraService;

  /// 에러 다이얼로그 표시
  Future<void> _showErrorDialog(String title, String message) async {
    await _dialogService.showDialog(
      title: title,
      description: message,
      buttonTitle: '확인',
    );
  }

  /// 성공 다이얼로그 표시
  Future<void> _showSuccessDialog(String title, String message) async {
    await _dialogService.showDialog(
      title: title,
      description: message,
      buttonTitle: '확인',
    );
  }

  /// 확인 다이얼로그 표시
  Future<bool> _showConfirmDialog(String title, String message) async {
    final response = await _dialogService.showDialog(
      title: title,
      description: message,
      buttonTitle: '확인',
    );
    return response?.confirmed ?? false;
  }

  /// 화면 해제 시 정리
  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }
}
