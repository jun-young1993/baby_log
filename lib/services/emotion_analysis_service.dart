import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class EmotionAnalysisService with ListenableServiceMixin {
  final ReactiveValue<bool> _isAnalyzing = ReactiveValue<bool>(false);
  final ReactiveValue<Map<String, double>> _currentEmotions =
      ReactiveValue<Map<String, double>>({});
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);

  // Azure Face API 설정
  static const String _azureEndpoint = 'YOUR_AZURE_FACE_API_ENDPOINT';
  static const String _azureKey = 'YOUR_AZURE_FACE_API_KEY';

  // Getters
  bool get isAnalyzing => _isAnalyzing.value;
  Map<String, double> get currentEmotions => _currentEmotions.value;
  String? get errorMessage => _errorMessage.value;

  EmotionAnalysisService() {
    listenToReactiveValues([_isAnalyzing, _currentEmotions, _errorMessage]);
  }

  /// 실시간 감정 분석 시작
  void startAnalysis() {
    _isAnalyzing.value = true;
    _errorMessage.value = null;
  }

  /// 감정 분석 중지
  void stopAnalysis() {
    _isAnalyzing.value = false;
  }

  /// 이미지에서 감정 분석 수행
  Future<Map<String, double>?> analyzeEmotionFromImage(
    Uint8List imageBytes,
  ) async {
    if (!_isAnalyzing.value) return null;

    try {
      // Azure Face API 호출
      final result = await _callAzureFaceAPI(imageBytes);

      if (result != null) {
        _currentEmotions.value = result;
        return result;
      }
    } catch (e) {
      _errorMessage.value = '감정 분석 중 오류가 발생했습니다: $e';
    }

    return null;
  }

  /// Azure Face API 호출
  Future<Map<String, double>?> _callAzureFaceAPI(Uint8List imageBytes) async {
    try {
      // TODO: 실제 Azure Face API 연동
      // 현재는 시뮬레이션 데이터 반환

      // 실제 구현 시:
      // final response = await http.post(
      //   Uri.parse('$_azureEndpoint/detect?returnFaceAttributes=emotion'),
      //   headers: {
      //     'Content-Type': 'application/octet-stream',
      //     'Ocp-Apim-Subscription-Key': _azureKey,
      //   },
      //   body: imageBytes,
      // );

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return _parseEmotionData(data);
      // }

      // 시뮬레이션 데이터
      await Future.delayed(const Duration(milliseconds: 500)); // API 호출 시뮬레이션

      return {'웃음': 0.7, '울음': 0.1, '졸림': 0.1, '놀람': 0.1};
    } catch (e) {
      _errorMessage.value = 'Azure Face API 호출 중 오류: $e';
      return null;
    }
  }

  /// Azure Face API 응답 파싱
  Map<String, double> _parseEmotionData(List<dynamic> data) {
    if (data.isEmpty) return {};

    final face = data.first;
    final emotion = face['faceAttributes']?['emotion'];

    if (emotion == null) return {};

    return {
      '웃음': (emotion['happiness'] ?? 0.0).toDouble(),
      '울음': (emotion['sadness'] ?? 0.0).toDouble(),
      '졸림': (emotion['neutral'] ?? 0.0).toDouble(),
      '놀람': (emotion['surprise'] ?? 0.0).toDouble(),
      '화남': (emotion['anger'] ?? 0.0).toDouble(),
      '두려움': (emotion['fear'] ?? 0.0).toDouble(),
      '역겨움': (emotion['disgust'] ?? 0.0).toDouble(),
      '경멸': (emotion['contempt'] ?? 0.0).toDouble(),
    };
  }

  /// 가장 높은 감정 찾기
  String getDominantEmotion(Map<String, double> emotions) {
    if (emotions.isEmpty) return '';

    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage.value = null;
  }

  /// 감정 분석 결과 초기화
  void clearResults() {
    _currentEmotions.value = {};
  }
}
