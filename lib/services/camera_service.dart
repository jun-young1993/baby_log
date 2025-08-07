import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:get_it/get_it.dart';

import 'emotion_analysis_service.dart';

class CameraService with ListenableServiceMixin {
  final ReactiveValue<CameraController?> _cameraController =
      ReactiveValue<CameraController?>(null);
  final ReactiveValue<bool> _isInitialized = ReactiveValue<bool>(false);
  final ReactiveValue<bool> _hasPermission = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);

  CameraController? get cameraController => _cameraController.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasPermission => _hasPermission.value;
  String? get errorMessage => _errorMessage.value;

  CameraService() {
    listenToReactiveValues([
      _cameraController,
      _isInitialized,
      _hasPermission,
      _errorMessage,
    ]);
  }

  /// 카메라 권한 요청 및 확인
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _hasPermission.value = status.isGranted;

      if (!status.isGranted) {
        _errorMessage.value = '카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage.value = '카메라 권한 요청 중 오류가 발생했습니다: $e';
      return false;
    }
  }

  /// 카메라 초기화
  Future<bool> initializeCamera() async {
    try {
      // 권한 확인
      if (!await requestCameraPermission()) {
        return false;
      }

      // 사용 가능한 카메라 목록 가져오기
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _errorMessage.value = '사용 가능한 카메라가 없습니다.';
        return false;
      }

      // 전면 카메라 우선, 없으면 후면 카메라 사용
      CameraDescription selectedCamera = cameras.first;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      // 카메라 컨트롤러 초기화 (실시간 스트림용)
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // 실시간 이미지 스트림 시작
      await controller.startImageStream(_onImageStream);

      _cameraController.value = controller;
      _isInitialized.value = true;
      _errorMessage.value = null;

      return true;
    } catch (e) {
      _errorMessage.value = '카메라 초기화 중 오류가 발생했습니다: $e';
      return false;
    }
  }

  /// 실시간 이미지 스트림 처리
  void _onImageStream(CameraImage image) {
    // 감정 분석 서비스 가져오기
    final emotionService = GetIt.I<EmotionAnalysisService>();

    // 이미지를 바이트로 변환 (실제로는 더 복잡한 변환 필요)
    final imageBytes = _convertCameraImageToBytes(image);

    // 감정 분석 수행
    if (imageBytes != null) {
      emotionService.analyzeEmotionFromImage(imageBytes);
    }
  }

  /// CameraImage를 Uint8List로 변환
  Uint8List? _convertCameraImageToBytes(CameraImage image) {
    // TODO: 실제 이미지 변환 구현
    // 현재는 시뮬레이션을 위해 null 반환
    return null;
  }

  /// 카메라 해제
  Future<void> disposeCamera() async {
    try {
      final controller = _cameraController.value;
      if (controller != null) {
        await controller.dispose();
      }
      _cameraController.value = null;
      _isInitialized.value = false;
    } catch (e) {
      _errorMessage.value = '카메라 해제 중 오류가 발생했습니다: $e';
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage.value = null;
  }

  /// 현재 카메라 상태 확인
  bool get isReady =>
      _isInitialized.value &&
      _hasPermission.value &&
      _cameraController.value != null;

  /// 카메라 전환 (전면/후면)
  Future<bool> switchCamera() async {
    try {
      if (!isReady) return false;

      final cameras = await availableCameras();
      final currentCamera = _cameraController.value!.description;

      CameraDescription? newCamera;
      for (final camera in cameras) {
        if (camera.lensDirection != currentCamera.lensDirection) {
          newCamera = camera;
          break;
        }
      }

      if (newCamera == null) return false;

      // 기존 컨트롤러 해제
      await disposeCamera();

      // 새 카메라로 초기화
      final controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      _cameraController.value = controller;
      _isInitialized.value = true;

      return true;
    } catch (e) {
      _errorMessage.value = '카메라 전환 중 오류가 발생했습니다: $e';
      return false;
    }
  }
}
