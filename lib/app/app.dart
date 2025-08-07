import 'package:baby_log/app/app.locator.dart';
import 'package:baby_log/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';

import '../ui/views/home/home_view.dart';
import '../ui/views/recording/recording_view.dart';
import '../ui/views/diary/diary_view.dart'; // Added
import '../ui/views/statistics/statistics_view.dart'; // Added
import '../services/camera_service.dart';
import '../services/emotion_analysis_service.dart';
import '../services/storage_service.dart';
import '../services/daily_emotion_service.dart'; // Added

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView, initial: true),
    MaterialRoute(page: RecordingView),
    MaterialRoute(page: DiaryView), // Added
    MaterialRoute(page: StatisticsView), // Added
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: CameraService),
    LazySingleton(classType: EmotionAnalysisService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: DailyEmotionService), // Added
  ],
)
class App {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리 아기 하루',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      navigatorKey: GetIt.I<NavigationService>().navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
    );
  }
}
