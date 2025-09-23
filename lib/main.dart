import 'package:flutter/material.dart';

import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/repositories/user_group_repository.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baby_log/baby_photo_vault_app.dart';
import 'package:baby_log/core/models/photo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  DioClient dioClient = DioClient(
    baseUrl: JunyConstants.apiBaseUrl,
    // debugBaseUrl: JunyConstants.apiBaseUrl,
    debugBaseUrl: 'http://localhost:3000',
    useLogInterceptor: true,
    appKey: AppKeys.babyLog,
    sharedPreferences: sharedPreferences,
  );

  final AppKeys appKey = AppKeys.babyLog;

  final fcmToken = null;

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
