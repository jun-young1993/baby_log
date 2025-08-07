import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:camera/camera.dart';

import 'recording_viewmodel.dart';
import '../../widgets/emotion_display.dart';

class RecordingView extends StackedView<RecordingViewModel> {
  const RecordingView({super.key});

  @override
  Widget builder(
    BuildContext context,
    RecordingViewModel viewModel,
    Widget? child,
  ) {
    // 카메라가 준비되지 않았으면 초기화 시도
    if (!viewModel.isCameraReady &&
        !viewModel.isBusy &&
        viewModel.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.initializeCamera(context);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 카메라 프리뷰
            _buildCameraPreview(viewModel),

            // 상단 컨트롤
            _buildTopControls(context, viewModel),

            // 하단 컨트롤
            _buildBottomControls(viewModel),

            // 실시간 감정 표시
            if (viewModel.isRecording) _buildEmotionOverlay(viewModel),

            // 로딩 인디케이터
            if (viewModel.isBusy) _buildLoadingOverlay(),

            // 에러 메시지
            if (viewModel.errorMessage != null) _buildErrorOverlay(viewModel),
          ],
        ),
      ),
    );
  }

  @override
  RecordingViewModel viewModelBuilder(BuildContext context) =>
      RecordingViewModel();

  Widget _buildCameraPreview(RecordingViewModel viewModel) {
    if (!viewModel.isCameraReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                '카메라를 초기화하는 중...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // 시뮬레이터 모드인 경우
    if (viewModel.cameraService.isSimulatorMode) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                '시뮬레이터 모드',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '실제 기기에서 카메라 기능을 테스트하세요',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text(
                  '시뮬레이션 녹화 가능',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(viewModel.cameraService.cameraController!);
  }

  Widget _buildTopControls(BuildContext context, RecordingViewModel viewModel) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 뒤로가기 버튼
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),

            // 녹화 시간 표시
            if (viewModel.isRecording)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDuration(viewModel.recordingDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            // 카메라 전환 버튼
            IconButton(
              onPressed: viewModel.switchCamera,
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(RecordingViewModel viewModel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 녹화 버튼
            GestureDetector(
              onTap: viewModel.isRecording
                  ? viewModel.stopRecording
                  : viewModel.startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: viewModel.isRecording ? Colors.red : Colors.white,
                  border: Border.all(
                    color: viewModel.isRecording ? Colors.red : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: viewModel.isRecording
                          ? Colors.red.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  viewModel.isRecording
                      ? Icons.stop
                      : Icons.fiber_manual_record,
                  color: viewModel.isRecording ? Colors.white : Colors.red,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionOverlay(RecordingViewModel viewModel) {
    return Positioned(
      top: 100,
      right: 16,
      child: EmotionDisplay(
        emotions: viewModel.currentEmotions,
        dominantEmotion: viewModel.dominantEmotion,
        isAnalyzing: viewModel.isAnalyzing,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorOverlay(RecordingViewModel viewModel) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () => viewModel.clearError(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
