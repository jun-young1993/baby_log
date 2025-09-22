import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_model.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

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

  /// 이미지 처리 및 저장
  Future<PhotoModel> _processImage(XFile image) async {
    try {
      // 앱 전용 디렉토리 생성
      final appDir = await _getAppDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
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
}
