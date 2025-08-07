import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:stacked/stacked.dart';

class StorageService with ListenableServiceMixin {
  final ReactiveValue<bool> _isSaving = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);

  // Getters
  bool get isSaving => _isSaving.value;
  String? get errorMessage => _errorMessage.value;

  StorageService() {
    listenToReactiveValues([_isSaving, _errorMessage]);
  }

  /// 녹화 결과 저장
  Future<bool> saveRecordingResult({
    required String videoPath,
    required Map<String, double> emotions,
    required Duration duration,
    String? title,
    String? description,
  }) async {
    try {
      _isSaving.value = true;
      _errorMessage.value = null;

      // 저장 디렉토리 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));

      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // 고유 ID 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final recordingId = 'recording_$timestamp';

      // 비디오 파일 복사
      final videoFile = File(videoPath);
      final savedVideoPath = path.join(recordingsDir.path, '$recordingId.mp4');
      await videoFile.copy(savedVideoPath);

      // 메타데이터 생성
      final metadata = {
        'id': recordingId,
        'title': title ?? '녹화 ${DateTime.now().toString().substring(0, 19)}',
        'description': description ?? '',
        'videoPath': savedVideoPath,
        'emotions': emotions,
        'dominantEmotion': _getDominantEmotion(emotions),
        'duration': duration.inSeconds,
        'createdAt': DateTime.now().toIso8601String(),
        'fileSize': await videoFile.length(),
      };

      // 메타데이터 저장
      final metadataFile = File(
        path.join(recordingsDir.path, '$recordingId.json'),
      );
      await metadataFile.writeAsString(json.encode(metadata));

      // 전체 녹화 목록 업데이트
      await _updateRecordingsList(recordingId, metadata);

      return true;
    } catch (e) {
      _errorMessage.value = '녹화 결과 저장 중 오류가 발생했습니다: $e';
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  /// 녹화 목록 가져오기
  Future<List<Map<String, dynamic>>> getRecordingsList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));

      if (!await recordingsDir.exists()) {
        return [];
      }

      final listFile = File(
        path.join(recordingsDir.path, 'recordings_list.json'),
      );

      if (!await listFile.exists()) {
        return [];
      }

      final content = await listFile.readAsString();
      final List<dynamic> data = json.decode(content);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      _errorMessage.value = '녹화 목록을 가져오는 중 오류가 발생했습니다: $e';
      return [];
    }
  }

  /// 녹화 목록 업데이트
  Future<void> _updateRecordingsList(
    String recordingId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));
      final listFile = File(
        path.join(recordingsDir.path, 'recordings_list.json'),
      );

      List<Map<String, dynamic>> recordings = [];

      if (await listFile.exists()) {
        final content = await listFile.readAsString();
        final List<dynamic> data = json.decode(content);
        recordings = data.cast<Map<String, dynamic>>();
      }

      // 새 녹화를 맨 앞에 추가
      recordings.insert(0, metadata);

      // 최대 100개까지만 유지
      if (recordings.length > 100) {
        recordings = recordings.take(100).toList();
      }

      await listFile.writeAsString(json.encode(recordings));
    } catch (e) {
      _errorMessage.value = '녹화 목록 업데이트 중 오류가 발생했습니다: $e';
    }
  }

  /// 녹화 삭제
  Future<bool> deleteRecording(String recordingId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));

      // 비디오 파일 삭제
      final videoFile = File(path.join(recordingsDir.path, '$recordingId.mp4'));
      if (await videoFile.exists()) {
        await videoFile.delete();
      }

      // 메타데이터 파일 삭제
      final metadataFile = File(
        path.join(recordingsDir.path, '$recordingId.json'),
      );
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      // 목록에서 제거
      await _removeFromRecordingsList(recordingId);

      return true;
    } catch (e) {
      _errorMessage.value = '녹화 삭제 중 오류가 발생했습니다: $e';
      return false;
    }
  }

  /// 녹화 목록에서 제거
  Future<void> _removeFromRecordingsList(String recordingId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));
      final listFile = File(
        path.join(recordingsDir.path, 'recordings_list.json'),
      );

      if (!await listFile.exists()) return;

      final content = await listFile.readAsString();
      final List<dynamic> data = json.decode(content);
      final recordings = data.cast<Map<String, dynamic>>();

      recordings.removeWhere((recording) => recording['id'] == recordingId);

      await listFile.writeAsString(json.encode(recordings));
    } catch (e) {
      _errorMessage.value = '녹화 목록에서 제거 중 오류가 발생했습니다: $e';
    }
  }

  /// 가장 높은 감정 찾기
  String _getDominantEmotion(Map<String, double> emotions) {
    if (emotions.isEmpty) return '';

    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage.value = null;
  }

  /// 저장 공간 정리
  Future<void> cleanupStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(directory.path, 'recordings'));

      if (!await recordingsDir.exists()) return;

      final recordings = await getRecordingsList();

      // 30일 이상 된 녹화 삭제
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      for (final recording in recordings) {
        final createdAt = DateTime.parse(recording['createdAt']);
        if (createdAt.isBefore(thirtyDaysAgo)) {
          await deleteRecording(recording['id']);
        }
      }
    } catch (e) {
      _errorMessage.value = '저장 공간 정리 중 오류가 발생했습니다: $e';
    }
  }
}
