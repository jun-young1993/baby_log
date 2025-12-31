import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_common/constants/juny_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 서버 API URL (실제 서버 URL로 변경 필요)
  static const String _serverUrl = JunyConstants.apiBaseUrl;

  /// 푸시 알림 서비스 초기화
  static Future<String?> initialize() async {
    // iOS 알림 권한 요청
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('알림 권한 상태: ${settings.authorizationStatus}');

    // FCM 토큰 가져오기
    String? token = await _messaging.getToken();
    // if (token != null) {
    //   print('FCM Token: $token');
    //   await _registerTokenToServer(token);
    // }

    // // 토큰 갱신 리스너
    // _messaging.onTokenRefresh.listen((newToken) {
    //   print('FCM Token 갱신: $newToken');
    //   _registerTokenToServer(newToken);
    // });

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드에서 알림 클릭 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 종료 상태에서 알림 클릭으로 앱 시작
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    return token;
  }

  /// 포그라운드 메시지 처리
  static void _handleForegroundMessage(RemoteMessage message) {
    print('포그라운드 메시지 수신');
    print('제목: ${message.notification?.title}');
    print('내용: ${message.notification?.body}');
    print('데이터: ${message.data}');

    // 여기서 앱 내 알림 표시 또는 상태 업데이트
    // 예: 로컬 알림 표시, 다이얼로그 표시 등
  }

  /// 백그라운드/종료 상태에서 알림 클릭 처리
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('알림 클릭으로 앱 열림');
    print('데이터: ${message.data}');

    // 여기서 특정 화면으로 이동
    // 예: placeId가 있으면 해당 장소 상세 화면으로 이동
    if (message.data.containsKey('placeId')) {
      String placeId = message.data['placeId'];
      // Navigator를 사용하여 화면 이동
      // navigatorKey.currentState?.pushNamed('/place/$placeId');
    }
  }

  /// 특정 토픽 구독
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('토픽 구독: $topic');
  }

  /// 토픽 구독 해제
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('토픽 구독 해제: $topic');
  }
}
