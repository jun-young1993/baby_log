import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../models/photo_model.dart';

/// PhotoService - Handles both photos and videos
/// Can be renamed to MediaService in the future for clarity
class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Check if video features are supported on current platform
  bool get isVideoSupported {
    // Windows와 웹에서는 동영상 기능이 제한적임
    if (kIsWeb) return false;
    if (Platform.isWindows) return false;
    return true;
  }

  /// 카메라로 사진 촬영
  Future<PhotoModel?> capturePhoto() async {
    try {
      // 카메라 권한 확인
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission != PermissionStatus.granted) {
        throw Exception('카메라 권한이 필요합니다.');
      }

      // 카메라로 사진 촬영
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;
      print('image.path: ${image.path}');
      return await _processImage(image);
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
      rethrow;
    }
  }

  /// 갤러리에서 사진 선택
  Future<PhotoModel?> pickPhotoFromGallery() async {
    try {
      // 갤러리 권한 확인
      final photosPermission = await Permission.photos.request();
      if (photosPermission != PermissionStatus.granted) {
        throw Exception('갤러리 권한이 필요합니다.');
      }

      // 갤러리에서 사진 선택
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;

      print('image.path: ${image.path}');

      return await _processImage(image);
    } catch (e) {
      debugPrint('갤러리에서 사진 선택 오류: $e');
      rethrow;
    }
  }

  /// 갤러리에서 여러 장의 사진 선택
  Future<List<PhotoModel>?> pickMultiplePhotosFromGallery() async {
    try {
      // 갤러리 권한 확인
      final photosPermission = await Permission.photos.request();
      if (photosPermission != PermissionStatus.granted) {
        throw Exception('갤러리 권한이 필요합니다.');
      }

      // 갤러리에서 여러 장 선택
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 100,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images.isEmpty) return null;

      debugPrint('${images.length}장의 사진 선택됨');

      // 모든 이미지 처리
      final List<PhotoModel> photos = [];
      for (final image in images) {
        try {
          final photo = await _processImage(image);
          photos.add(photo);
        } catch (e) {
          debugPrint('이미지 처리 실패: ${image.path}, 오류: $e');
          // 계속 진행
        }
      }

      return photos.isEmpty ? null : photos;
    } catch (e) {
      debugPrint('갤러리에서 여러 사진 선택 오류: $e');
      rethrow;
    }
  }

  /// 이미지 처리 및 저장
  Future<PhotoModel> _processImage(XFile image) async {
    try {
      // 앱 전용 디렉토리 생성
      final appDir = await _getAppDirectory();
      final photosDir = Directory('${appDir.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // 고유한 파일명 생성
      final fileExtension = image.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExtension';
      final filePath = '${photosDir.path}/$fileName';
      // final thumbnailPath = '${thumbnailsDir.path}/$fileName';

      // 원본 이미지 복사
      final originalFile = File(image.path);
      final savedFile = await originalFile.copy(filePath);

      // 썸네일 생성
      // await _createThumbnail(image.path, thumbnailPath);

      // 파일 정보 가져오기
      final fileSize = await savedFile.length();
      final fileStat = await savedFile.stat();

      // PhotoModel 생성
      return PhotoModel(
        id: _uuid.v4(),
        filePath: filePath,
        fileName: fileName,
        createdAt: DateTime.now(),
        takenAt: fileStat.modified,
        fileSize: fileSize,
        thumbnailPath: null,
      );
    } catch (e) {
      debugPrint('이미지 처리 오류: $e');
      rethrow;
    }
  }

  /// 앱 전용 디렉토리 경로 가져오기
  Future<Directory> _getAppDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/baby_photo_vault');
  }

  /// 사진 삭제
  Future<bool> deletePhoto(PhotoModel photo) async {
    try {
      // 원본 파일 삭제
      final originalFile = File(photo.filePath);
      if (await originalFile.exists()) {
        await originalFile.delete();
      }

      // 썸네일 파일 삭제
      if (photo.thumbnailPath != null) {
        final thumbnailFile = File(photo.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      return true;
    } catch (e) {
      debugPrint('사진 삭제 오류: $e');
      return false;
    }
  }

  /// 사진 파일 존재 여부 확인
  Future<bool> photoExists(PhotoModel photo) async {
    final file = File(photo.filePath);
    return await file.exists();
  }

  /// 앱 디렉토리의 모든 사진 파일 정리
  Future<void> cleanupOrphanedFiles() async {
    try {
      final appDir = await _getAppDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      final videosDir = Directory('${appDir.path}/videos');
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');

      if (await photosDir.exists()) {
        final files = await photosDir.list().toList();
        for (final file in files) {
          if (file is File) {
            // 30일 이상 된 파일 삭제 (임시 정리)
            final stat = await file.stat();
            final daysSinceModified = DateTime.now()
                .difference(stat.modified)
                .inDays;
            if (daysSinceModified > 30) {
              await file.delete();
            }
          }
        }
      }

      if (await videosDir.exists()) {
        final files = await videosDir.list().toList();
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final daysSinceModified = DateTime.now()
                .difference(stat.modified)
                .inDays;
            if (daysSinceModified > 30) {
              await file.delete();
            }
          }
        }
      }

      if (await thumbnailsDir.exists()) {
        final files = await thumbnailsDir.list().toList();
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final daysSinceModified = DateTime.now()
                .difference(stat.modified)
                .inDays;
            if (daysSinceModified > 30) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('파일 정리 오류: $e');
    }
  }

  // ==================== VIDEO METHODS ====================

  /// 카메라로 동영상 촬영
  Future<PhotoModel?> captureVideo({int maxDurationSeconds = 60}) async {
    // 플랫폼 지원 확인
    if (!isVideoSupported) {
      throw Exception('이 플랫폼에서는 동영상 촬영이 지원되지 않습니다.');
    }

    try {
      // 카메라 권한 확인
      debugPrint('🎥 카메라 권한 요청 중...');
      final cameraPermission = await Permission.camera.request();
      debugPrint('📷 카메라 권한 상태: $cameraPermission');
      if (cameraPermission != PermissionStatus.granted) {
        throw Exception('카메라 권한이 필요합니다. 현재 상태: $cameraPermission');
      }

      // 마이크 권한 확인 (동영상 녹화용)
      debugPrint('🎤 마이크 권한 요청 중...');
      final microphonePermission = await Permission.microphone.request();
      debugPrint('🎙️ 마이크 권한 상태: $microphonePermission');
      if (microphonePermission != PermissionStatus.granted) {
        throw Exception('마이크 권한이 필요합니다. 현재 상태: $microphonePermission');
      }

      debugPrint('✅ 모든 권한 승인됨. 동영상 촬영 시작...');

      // 카메라로 동영상 촬영
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: maxDurationSeconds),
      );

      if (video == null) return null;

      debugPrint('video.path: ${video.path}');
      return await _processVideo(video);
    } catch (e) {
      debugPrint('동영상 촬영 오류: $e');
      rethrow;
    }
  }

  /// 갤러리에서 동영상 선택
  Future<PhotoModel?> pickVideoFromGallery() async {
    // 플랫폼 지원 확인

    try {
      // 갤러리 권한 확인
      final photosPermission = await Permission.photos.request();
      if (photosPermission != PermissionStatus.granted) {
        throw Exception('갤러리 권한이 필요합니다.');
      }

      // 갤러리에서 동영상 선택
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) return null;

      debugPrint('video.path: ${video.path}');
      return await _processVideo(video);
    } catch (e) {
      debugPrint('갤러리에서 동영상 선택 오류: $e');
      rethrow;
    }
  }

  /// 동영상 처리 및 저장
  Future<PhotoModel> _processVideo(XFile video) async {
    try {
      // 앱 전용 디렉토리 생성
      final appDir = await _getAppDirectory();
      final videosDir = Directory('${appDir.path}/videos');
      debugPrint('videosDir: ${videosDir.path}');

      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }

      // 고유한 파일명 생성
      final fileExtension = video.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExtension';
      final filePath = '${videosDir.path}/$fileName';

      // 원본 동영상 복사
      final originalFile = File(video.path);
      final savedFile = await originalFile.copy(filePath);

      // 동영상 정보 가져오기
      final fileSize = await savedFile.length();
      final fileStat = await savedFile.stat();

      // 동영상 길이 및 기타 정보 가져오기
      // final videoDuration = await _getVideoDuration(filePath);
      // final aspectRatio = await _getVideoAspectRatio(filePath);

      // PhotoModel 생성 (동영상용)
      return PhotoModel(
        id: _uuid.v4(),
        filePath: filePath,
        fileName: fileName,
        createdAt: DateTime.now(),
        takenAt: fileStat.modified,
        fileSize: fileSize,
        thumbnailPath: null,
        mediaType: 'video',
      );
    } catch (e) {
      debugPrint('동영상 처리 오류: $e');
      rethrow;
    }
  }

  /// 동영상 썸네일 생성
  Future<String?> _generateVideoThumbnail(
    String videoPath,
    String thumbnailDir,
  ) async {
    try {
      final thumbnailFileName = '${_uuid.v4()}.jpg';
      final thumbnailPath = '$thumbnailDir/$thumbnailFileName';

      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 85,
        timeMs: 1000, // 1초 지점의 썸네일
      );

      return thumbnail;
    } catch (e) {
      debugPrint('썸네일 생성 오류: $e');
      return null;
    }
  }

  /// 동영상 길이 가져오기 (초 단위)
  Future<int?> _getVideoDuration(String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      debugPrint('동영상 길이 가져오기 오류: $e');
      return null;
    }
  }

  /// 동영상 화면 비율 가져오기
  Future<double?> _getVideoAspectRatio(String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final aspectRatio = controller.value.aspectRatio;
      await controller.dispose();
      return aspectRatio;
    } catch (e) {
      debugPrint('동영상 화면 비율 가져오기 오류: $e');
      return null;
    }
  }

  /// 동영상 압축
  Future<PhotoModel?> compressVideo(
    PhotoModel videoModel, {
    VideoQuality quality = VideoQuality.MediumQuality,
  }) async {
    try {
      if (!videoModel.isVideo) {
        throw Exception('동영상이 아닙니다.');
      }

      debugPrint('동영상 압축 시작: ${videoModel.filePath}');

      final info = await VideoCompress.compressVideo(
        videoModel.filePath,
        quality: quality,
        deleteOrigin: false,
      );

      if (info == null || info.file == null) {
        throw Exception('동영상 압축 실패');
      }

      debugPrint('압축 완료: ${info.file!.path}');
      debugPrint('원본 크기: ${videoModel.fileSize} bytes');
      debugPrint('압축 크기: ${info.filesize} bytes');

      // 압축된 파일로 새 PhotoModel 생성
      final compressedFile = info.file!;
      final fileSize = await compressedFile.length();

      return videoModel.copyWith(
        filePath: compressedFile.path,
        fileSize: fileSize,
        durationInSeconds: info.duration?.toInt(),
      );
    } catch (e) {
      debugPrint('동영상 압축 오류: $e');
      return null;
    }
  }

  /// 동영상 포맷 검증
  bool isValidVideoFormat(String fileName) {
    final validFormats = ['mp4', 'mov', 'avi', 'm4v', 'mkv'];
    final extension = fileName.split('.').last.toLowerCase();
    return validFormats.contains(extension);
  }

  /// 동영상 파일 크기 검증 (기본: 100MB)
  bool isValidVideoSize(int fileSize, {int maxSizeInMB = 100}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  /// 동영상 길이 검증 (기본: 5분)
  bool isValidVideoDuration(
    int? durationInSeconds, {
    int maxDurationInMinutes = 5,
  }) {
    if (durationInSeconds == null) return true;
    final maxDurationInSeconds = maxDurationInMinutes * 60;
    return durationInSeconds <= maxDurationInSeconds;
  }
}
