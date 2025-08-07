import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'emotion_analysis_service.dart';

class CameraService with ListenableServiceMixin {
  final ReactiveValue<CameraController?> _cameraController =
      ReactiveValue<CameraController?>(null);
  final ReactiveValue<bool> _isInitialized = ReactiveValue<bool>(false);
  final ReactiveValue<bool> _hasPermission = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);
  final ReactiveValue<bool> _isSimulatorMode = ReactiveValue<bool>(false);

  CameraController? get cameraController => _cameraController.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasPermission => _hasPermission.value;
  String? get errorMessage => _errorMessage.value;
  bool get isSimulatorMode => _isSimulatorMode.value;

  CameraService() {
    listenToReactiveValues([
      _cameraController,
      _isInitialized,
      _hasPermission,
      _errorMessage,
      _isSimulatorMode,
    ]);
  }

  /// 시뮬레이터 환경인지 확인
  bool get _isSimulator {
    return Platform.isIOS && !Platform.environment.containsKey('FLUTTER_TEST');
  }

  /// 카메라 권한 상태 확인
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// 카메라 권한 요청 및 확인 (사용자 친화적)
  Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      // 시뮬레이터 환경에서는 권한을 자동으로 허용
      if (_isSimulator) {
        _hasPermission.value = true;
        _isSimulatorMode.value = true;
        return true;
      }

      // 현재 권한 상태 확인
      final status = await Permission.camera.status;

      if (status.isGranted) {
        _hasPermission.value = true;
        return true;
      }

      if (status.isDenied) {
        // 권한 요청 다이얼로그 표시
        final granted = await _showPermissionDialog(context);
        if (granted) {
          _hasPermission.value = true;
          return true;
        }
        return false;
      }

      if (status.isPermanentlyDenied) {
        // 설정으로 이동하는 다이얼로그 표시
        await _showSettingsDialog(context);
        return false;
      }

      return false;
    } catch (e) {
      _errorMessage.value = '카메라 권한 요청 중 오류가 발생했습니다: $e';
      return false;
    }
  }

  /// 권한 요청 다이얼로그 표시
  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.blue[600], size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '카메라 권한이 필요합니다',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '아기의 감정을 분석하기 위해 카메라 접근 권한이 필요합니다.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '이 권한은 아기의 감정을 분석하기 위해 필요합니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('나중에', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // 권한 요청
                  final status = await Permission.camera.request();

                  if (status.isGranted) {
                    Navigator.of(context).pop(true);
                  } else {
                    // 권한이 거부된 경우 설정으로 이동하는 다이얼로그 표시
                    if (context.mounted) {
                      await _showSettingsDialog(context);
                    }
                    Navigator.of(context).pop(false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('권한 허용'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 설정으로 이동하는 다이얼로그 표시
  Future<void> _showSettingsDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한이 필요합니다'),
        content: const Text('카메라 권한이 거부되었습니다. 앱 설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 카메라 초기화
  Future<bool> initializeCamera(BuildContext context) async {
    try {
      // 권한 확인 및 요청
      if (!await requestCameraPermission(context)) {
        return false;
      }

      // 시뮬레이터 모드인 경우
      if (_isSimulatorMode.value) {
        _isInitialized.value = true;
        _errorMessage.value = null;
        return true;
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
