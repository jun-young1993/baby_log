import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/photo_capture/presentation/pages/photo_capture_page.dart';
import 'features/photo_detail/presentation/pages/photo_detail_page.dart';
import 'features/album/presentation/pages/album_list_page.dart';
import 'features/family/presentation/pages/family_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

class BabyPhotoVaultApp extends StatelessWidget {
  const BabyPhotoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Photo Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/photo-capture': (context) => const PhotoCapturePage(),
        '/albums': (context) => const AlbumListPage(),
        '/family': (context) => const FamilyPage(),
        '/settings': (context) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/photo-detail/') == true) {
          final photoId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => PhotoDetailPage(photoId: photoId),
          );
        }
        return null;
      },
    );
  }
}
