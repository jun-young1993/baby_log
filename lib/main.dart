import 'dart:io';

import 'package:baby_log/firebase_options.dart';
import 'package:baby_log/push_notification_service.dart';
import 'package:baby_log/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/repositories/app_reward_repository.dart';
import 'package:flutter_common/repositories/user_group_repository.dart';
import 'package:flutter_common/repositories/user_storage_limit_repository.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_storage_limit/user_storage_limit_bloc.dart';
import 'package:flutter_common/widgets/ad/ad_open_app.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baby_log/baby_photo_vault_app.dart';
import 'package:baby_log/core/models/photo_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('백그라운드 메시지: ${message.messageId}');
  print('제목: ${message.notification?.title}');
  print('내용: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 먼저 초기화 (AdMob보다 안정적)

  // iOS에서 APNS 토큰 설정 및 FCM 토큰 가져오기

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 푸시 알림 서비스 초기화
  String? fcmToken = await PushNotificationService.initialize();

  // AdMaster 초기화 - 에러가 발생해도 앱이 계속 실행되도록
  try {
    final adMaster = AdMaster();
    await adMaster.initialize(AdConfig(isTestMode: kDebugMode));
    AdOpenApp(
      adMaster: AdMaster(),
      adUnitId: Platform.isIOS
          ? 'ca-app-pub-4656262305566191/2066955512'
          : 'ca-app-pub-4656262305566191/9127241785',
    ).listenToAppStateChanges();

    debugPrint('✅ AdMaster 초기화 성공');
  } catch (e) {
    debugPrint('⚠️ AdMaster 초기화 실패: $e');
    // 광고 없이 앱은 계속 실행
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PhotoModelAdapter());

  // Initialize date formatting for Korean locale
  // await initializeDateFormatting('ko_KR', null);

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[FLUTTER ERROR] ${details.exception}');
    debugPrint('[STACKTRACE] ${details.stack}');
  };

  await EasyLocalization.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final AppKeys appKey = AppKeys.babyLog;
  DioClient dioClient = DioClient(
    baseUrl: JunyConstants.apiBaseUrl,
    debugBaseUrl: JunyConstants.apiBaseUrl,
    // debugBaseUrl: 'http://127.0.0.1:3000',
    // debugBaseUrl: 'http://10.0.2.2:3000',
    xIncludeUserGroupAdmin: true,
    useLogInterceptor: false,
    appKey: appKey,
    sharedPreferences: sharedPreferences,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppRepository>(
          create: (context) =>
              AppDefaultRepository(sharedPreferences: sharedPreferences),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserDefaultRepository(
            dioClient: dioClient,
            sharedPreferences: sharedPreferences,
            appKey: appKey,
          ),
        ),
        RepositoryProvider<VerificationRepository>(
          create: (context) => VerificationDefaultRepository(
            dioClient: dioClient,
            appKey: appKey,
          ),
        ),
        RepositoryProvider<NoticeGroupRepository>(
          create: (context) =>
              NoticeGroupDefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<NoticeRepository>(
          create: (context) => NoticeDefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<NoticeReplyRepository>(
          create: (context) =>
              NoticeReplyDefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<AwsS3Repository>(
          create: (context) => AwsS3DefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<UserGroupRepository>(
          create: (context) => UserGroupDefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<UserStorageLimitRepository>(
          create: (context) =>
              UserStorageLimitDefaultRepository(dioClient: dioClient),
        ),
        RepositoryProvider<AppRewardRepository>(
          create: (context) => AppRewardDefaultRepository(dioClient: dioClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AppConfigBloc(appRepository: context.read<AppRepository>()),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              userRepository: context.read<UserRepository>(),
              fcmToken: fcmToken,
            ),
          ),
          BlocProvider(
            create: (context) => VerificationBloc(
              verificationRepository: context.read<VerificationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => NoticeGroupBloc(
              noticeGroupRepository: context.read<NoticeGroupRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                NoticeBloc(noticeRepository: context.read<NoticeRepository>()),
          ),
          BlocProvider(
            create: (context) => NoticePageBloc(
              noticeRepository: context.read<NoticeRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => NoticeReplyBloc(
              noticeReplyRepository: context.read<NoticeReplyRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => S3ObjectBloc(
              s3ObjectRepository: context.read<AwsS3Repository>(),
              appKeys: appKey,
            ),
          ),
          BlocProvider(
            create: (context) => UserGroupBloc(
              userGroupRepository: context.read<UserGroupRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => S3ObjectPageBloc(
              s3ObjectRepository: context.read<AwsS3Repository>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserStorageLimitBloc(
              userStorageLimitRepository: context
                  .read<UserStorageLimitRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AppRewardBloc(
              appRewardRepository: context.read<AppRewardRepository>(),
              userRepository: context.read<UserRepository>(),
              adMaster: AdMaster(),
              appKeys: appKey,
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            return EasyLocalization(
              supportedLocales: const [Locale('ko'), Locale('en')],
              path: 'packages/flutter_common/assets/translations',
              fallbackLocale: const Locale('ko'),
              child: const ProviderScope(child: BabyPhotoVaultApp()),
            );
          },
        ),
      ),
    ),
  );
}
