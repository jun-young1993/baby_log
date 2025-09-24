import 'package:flutter/material.dart';
import 'package:flutter_common/extensions/app_exception.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/photo_capture/presentation/pages/photo_capture_page.dart';
import '../../features/photo_detail/presentation/pages/photo_detail_page.dart';
import '../../features/album/presentation/pages/album_list_page.dart';
import '../../features/family/presentation/pages/family_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/gallery/presentation/pages/daily_record_page.dart';
import '../../features/gallery/core/models/daily_record.dart';

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      // Onboarding flow
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Main dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => UserInfoSelector((user) {
          final userBloc = context.read<UserBloc>();
          if (user == null) {
            return ErrorView<AppException>(
              error: AppException.unauthorized('User not found'),
              onRetry: () {
                userBloc.add(UserEvent.clearError());
                userBloc.add(UserEvent.initialize());
              },
            );
          }
          return DashboardPage(user: user);
        }),
      ),

      // Photo capture
      GoRoute(
        path: '/photo-capture',
        name: 'photo-capture',
        builder: (context, state) => const PhotoCapturePage(),
      ),

      // Gallery
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => UserInfoSelector((user) {
          final userBloc = context.read<UserBloc>();
          if (user == null) {
            return ErrorView<AppException>(
              error: AppException.unauthorized('User not found'),
              onRetry: () {
                userBloc.add(UserEvent.clearError());
                userBloc.add(UserEvent.initialize());
              },
            );
          }
          return GalleryPage(user: user);
        }),
      ),

      // Daily Record
      GoRoute(
        path: '/daily-record/:date',
        name: 'daily-record',
        builder: (context, state) {
          final userBloc = context.read<UserBloc>();
          final noticeGroupBloc = context.read<NoticeGroupBloc>();
          final noticeBloc = context.read<NoticeBloc>();
          final user = userBloc.state.user;
          final noticeGroup = noticeGroupBloc.state.noticeGroup;

          if (user == null || noticeGroup == null) {
            return ErrorView<AppException>(
              error: AppException.unauthorized('User or NoticeGroup not found'),
              onRetry: () {
                userBloc.add(UserEvent.clearError());
                userBloc.add(UserEvent.initialize());
                if (user != null) {
                  noticeGroupBloc.add(NoticeGroupEvent.initialize(user.id));
                }
              },
            );
          }
          final dateString = state.pathParameters['date']!;
          final date = DateTime.parse(dateString);
          return DailyRecordPage(
            date: date,
            user: user,
            noticeGroup: noticeGroup,
            onSaved: () {
              Future.delayed(const Duration(seconds: 1), () {
                noticeBloc.add(
                  NoticeEvent.checkNoticeExistence(
                    user.id,
                    date.year.toString(),
                    date.month.toString(),
                  ),
                );
              });
            },
          );
        },
      ),

      // Photo detail
      GoRoute(
        path: '/photo-detail',
        name: 'photo-detail',
        builder: (context, state) {
          // final photoId = state.pathParameters['photoId']!;
          return PhotoDetailPage();
        },
      ),

      // Album management
      GoRoute(
        path: '/albums',
        name: 'albums',
        builder: (context, state) => UserInfoSelector((user) {
          final userBloc = context.read<UserBloc>();
          if (user == null) {
            return ErrorView<AppException>(
              error: AppException.unauthorized('User not found'),
              onRetry: () {
                userBloc.add(UserEvent.clearError());
                userBloc.add(UserEvent.initialize());
              },
            );
          }
          return AlbumListPage(user: user);
        }),
      ),

      // Family sharing
      GoRoute(
        path: '/family',
        name: 'family',
        builder: (context, state) => const FamilyPage(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '요청하신 페이지가 존재하지 않습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('대시보드로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});
