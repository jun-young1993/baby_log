import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/widgets/simple_video_player.dart';

class PhotoCapturePage extends StatefulWidget {
  const PhotoCapturePage({super.key});

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  final PhotoService _photoService = PhotoService();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  UserBloc get userBloc => context.read<UserBloc>();
  bool _isLoading = false;
  PhotoModel? _capturedPhoto;
  bool _isVideoMode = false; // 동영상 모드 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.photo.takePhoto.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: SizeConstants.getColumnSpacing(context)),
            Text(Tr.photo.processing.tr()),
          ],
        ),
      );
    }

    if (_capturedPhoto != null) {
      return _buildPhotoPreview();
    }

    return _buildCaptureOptions();
  }

  Widget _buildCaptureOptions() {
    return Column(
      children: [
        // 사진/동영상 토글 (상단 고정)
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeToggleButton(
                  icon: Icons.camera_alt,
                  label: Tr.photo.title.tr(),
                  isSelected: !_isVideoMode,
                  onTap: () => setState(() => _isVideoMode = false),
                ),
                _buildModeToggleButton(
                  icon: Icons.videocam,
                  label: Tr.video.title.tr(),
                  isSelected: _isVideoMode,
                  onTap: () => setState(() => _isVideoMode = true),
                ),
              ],
            ),
          ),
        ),

        // 스크롤 가능한 컨텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 카메라 아이콘
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    _isVideoMode ? Icons.videocam : Icons.camera_alt,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 제목
                Text(
                  Tr.baby.onBoardingTitle.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 설명
                Text(
                  Tr.baby.cameraHintText.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                // 웹 플랫폼 안내
                if (kIsWeb) ...[
                  SizedBox(height: SizeConstants.getColumnSpacing(context)),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(
                          width: SizeConstants.getColumnSpacing(context),
                        ),
                        Expanded(
                          child: Text(
                            '웹에서는 파일 선택만 가능합니다',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 촬영 버튼 (웹에서는 비활성화)
                if (!kIsWeb) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVideoMode ? _captureVideo : _capturePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVideoMode ? Icons.videocam : Icons.camera_alt,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              Tr.baby.cameraTitle.tr(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConstants.getColumnSpacing(context)),
                ],

                // 갤러리 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      final user = userBloc.state.user;
                      if (user == null) {
                        return;
                      }
                      _isVideoMode
                          ? _pickVideoFromGallery()
                          : _pickFromGallery();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library),
                        SizedBox(
                          width: SizeConstants.getColumnSpacing(context),
                        ),
                        Flexible(
                          child: Text(
                            Tr.baby.galleryTitle.tr(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 하단 여백
                SizedBox(height: SizeConstants.getColumnSpacing(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    final isVideo = _capturedPhoto?.isVideo ?? false;

    return Column(
      children: [
        // 미디어 미리보기 (상단 고정)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isVideo
                  ? SimpleVideoPlayer(
                      videoPath: _capturedPhoto!.filePath,
                      aspectRatio: _capturedPhoto!.aspectRatio,
                    )
                  : Image.file(
                      File(_capturedPhoto!.filePath),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        // 스크롤 가능한 정보 영역
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // 미디어 정보
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tr.file.fileInfo.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Tr.file.fileName.tr(),
                          _capturedPhoto!.fileName,
                        ),
                        _buildInfoRow(
                          Tr.file.fileSize.tr(),
                          _formatFileSize(_capturedPhoto!.fileSize),
                        ),
                        if (isVideo &&
                            _capturedPhoto!.durationInSeconds != null)
                          _buildInfoRow(
                            '재생 시간',
                            _capturedPhoto!.formattedDuration ?? '',
                          ),
                        _buildInfoRow(
                          Tr.file.fileCreatedAt.tr(),
                          _formatDateTime(
                            _capturedPhoto!.takenAt ??
                                _capturedPhoto!.createdAt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 액션 버튼들
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.refresh),
                          label: Text(Tr.baby.reTake.tr()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _savePhoto(userBloc.state.user!),
                          icon: const Icon(Icons.save),
                          label: Text(Tr.common.save.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await _photoService.capturePhoto();
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
        });
      } else {
        _showSnackBar(Tr.photo.photoTakenCancel.tr());
      }
    } catch (e) {
      _showSnackBar(
        Tr.photo.photoTakenError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await _photoService.pickPhotoFromGallery();
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
        });
      } else {
        _showSnackBar(Tr.photo.photoSelectCancel.tr());
      }
    } catch (e) {
      _showSnackBar(
        Tr.photo.photoSelectError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _captureVideo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final video = await _photoService.captureVideo();
      if (video != null) {
        setState(() {
          _capturedPhoto = video;
        });
      } else {
        _showSnackBar(Tr.video.videoTakenCancel.tr());
      }
    } catch (e) {
      _showSnackBar(
        Tr.video.videoTakenError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideoFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final video = await _photoService.pickVideoFromGallery();
      if (video != null) {
        setState(() {
          _capturedPhoto = video;
        });
      } else {
        _showSnackBar(Tr.video.videoSelectCancel.tr());
      }
    } catch (e) {
      _showSnackBar(
        Tr.video.videoSelectError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  void _savePhoto(User user) {
    if (_capturedPhoto != null) {
      // TODO: 데이터베이스에 저장하는 로직 추가
      s3ObjectBloc.add(
        S3ObjectEvent.uploadFile(File(_capturedPhoto!.filePath), user),
      );
      _showSnackBar(Tr.photo.photoSaved.tr());
      context.pop(_capturedPhoto);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
