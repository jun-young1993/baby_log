import 'package:baby_log/core/widgets/storage_usage_widget.dart';
import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_photo_card.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/app_reward/app_reward_bloc.dart';
import 'package:flutter_common/state/app_reward/app_reward_event.dart';
import 'package:flutter_common/state/app_reward/app_reward_state.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_event.dart';
import 'package:flutter_common/state/user_group/user_group_selector.dart';
import 'package:flutter_common/state/user_storage_limit/user_storage_limit_bloc.dart';
import 'package:flutter_common/state/user_storage_limit/user_storage_limit_event.dart';
import 'package:flutter_common/state/user_storage_limit/user_storage_limit_selector.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // TODO: Replace with your production Rewarded Ad unit ids before release.
  // These are Google's official test unit ids and are safe for local development.
  static const _rewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const _rewardedAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _storageRewardName = 'storage_boost';

  final TextEditingController _searchController = TextEditingController();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();
  NoticeGroupBloc get noticeGroupBloc => context.read<NoticeGroupBloc>();
  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();
  UserBloc get userBloc => context.read<UserBloc>();
  UserStorageLimitBloc get userStorageLimitBloc =>
      context.read<UserStorageLimitBloc>();
  AppRewardBloc get appRewardBloc => context.read<AppRewardBloc>();

  final maxRecentPhotoCount = 6;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    initialize();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 크기 애니메이션 (0.9 ~ 1.3) - 더 역동적으로
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // 투명도 애니메이션 (0.6 ~ 1.0) - 덜 깜박이게
    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 애니메이션 반복 시작 (약간의 지연 후)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void initialize() {
    userBloc.add(UserEvent.clearError());
    userBloc.add(UserEvent.initialize());
    userBloc.add(UserEvent.getAppUsers());
    userBloc.stream.listen((state) {
      if (state.user != null) {
        userGroupBloc.add(UserGroupEvent.findAll());
        s3ObjectBloc.add(S3ObjectEvent.getS3Objects(0, maxRecentPhotoCount));
        s3ObjectBloc.add(S3ObjectEvent.count());
        noticeGroupBloc.add(
          NoticeGroupEvent.initialize(widget.user.id, withNotices: false),
        );
        userStorageLimitBloc.add(
          UserStorageLimitEvent.groupAdminDefaultStorageLimit(
            StorageLimitType.s3Storage,
          ),
        );
      }
    });
    userGroupBloc.stream.listen((state) {
      if (state.isNotFound) {
        context.go('/family');
      }
    });
  }

  String _getRewardedAdUnitId() {
    if (kIsWeb) return '';
    return Platform.isIOS ? _rewardedAdUnitIdIos : _rewardedAdUnitIdAndroid;
  }

  void _showStorageBoostAd() {
    final adUnitId = _getRewardedAdUnitId();
    if (adUnitId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('현재 환경에서는 광고를 지원하지 않아요.')));
      return;
    }

    appRewardBloc.add(const AppRewardEvent.clearError());
    appRewardBloc.add(
      AppRewardEvent.showRewardAd(adUnitId, _storageRewardName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserGroupFindSelector((userGroup) {
          return Text(
            userGroup != null
                ? userGroup.name ?? Tr.app.babyLog.tr()
                : Tr.app.babyLog.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: UserListSelector((users) {
          if (users.isEmpty) {
            return const SizedBox.shrink();
          }
          return IconButton(
            onPressed: () {
              _showGroupBottomSelectModal(
                context: context,
                users: [widget.user, ...users],
                selectedUser: widget.user,
              );
            },
            icon: const Icon(Icons.group),
          );
        }),
        actions: [
          UserGroupFindSelector((userGroup) {
            return Stack(
              children: [
                IconButton(
                  onPressed: () {
                    context.push('/family');
                  },
                  icon: Icon(
                    Icons.family_restroom,
                    color: userGroup != null
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  tooltip: userGroup != null
                      ? Tr.family.familyShare.tr()
                      : Tr.family.familyShareDescription.tr(),
                ),
                if (userGroup == null)
                  Positioned(
                    left: -12,
                    bottom: -12,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _scaleAnimation.value * 2, // 좌우 움직임
                            -_scaleAnimation.value *
                                1, // 위아래 움직임 (아이콘을 가리키는 느낌)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(
                                    0.2 * _opacityAnimation.value,
                                  ),
                                  blurRadius: 10 * _scaleAnimation.value,
                                  spreadRadius: 4 * _scaleAnimation.value,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Transform.rotate(
                              angle: -45 * (3.14159 / 25), // -45도 회전 (아이콘을 가리킴)
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.orange,
                                size: 16 * _scaleAnimation.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: Tr.app.settings.tr(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          initialize();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatisticsCards(),
              const SizedBox(height: 24),

              // // Search Bar
              // _buildSearchBar(),
              // const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Photo Grid
              _buildPhotoGrid(),
            ],
          ),
        ),
      ),
      floatingActionButton: UserInfoSelector((user) {
        return user?.isAdmin ?? false
            ? FloatingActionButton.extended(
                onPressed: () {
                  context.push('/photo-capture');
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(Tr.photo.takePhoto.tr()),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              )
            : const SizedBox.shrink();
      }),
    );
  }

  Widget _buildStatisticsCards() {
    return BlocListener<AppRewardBloc, AppRewardState>(
      listenWhen: (prev, curr) =>
          (prev as dynamic).isRewardAdLoading !=
              (curr as dynamic).isRewardAdLoading ||
          prev.error != curr.error,
      listener: (context, state) async {
        final isRewardAdLoading = (state as dynamic).isRewardAdLoading == true;
        // Rewarded ad flow finished (either success or failure).
        if (!isRewardAdLoading) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error?.message ?? '광고를 불러오지 못했어요.')),
            );
            return;
          }

          // Refresh storage usage after reward (server-side may reflect shortly).
          userStorageLimitBloc.add(
            UserStorageLimitEvent.groupAdminDefaultStorageLimit(
              StorageLimitType.s3Storage,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('고마워요! 저장공간이 반영되면 자동으로 업데이트돼요.')),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserStorageLimitGroupAdminDefaultStorageLimitSelector((
            groupAdminDefaultStorageLimit,
          ) {
            if (groupAdminDefaultStorageLimit == null) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 50,
                ),
              );
            }

            final usedStorage = groupAdminDefaultStorageLimit.currentUsage
                .toDouble();
            final totalStorage = groupAdminDefaultStorageLimit.limitValue
                .toDouble();

            return Column(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedStorageUsageWidget(
                      usedStorage: usedStorage,
                      totalStorage: totalStorage,
                      label: Tr.common.storageUsage.tr(),
                      animationDuration: const Duration(milliseconds: 2000),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                UserInfoSelector((user) {
                  final isAdmin = user?.isAdmin ?? false;
                  if (!isAdmin) return const SizedBox.shrink();
                  return _buildStorageBoostCtaCard(
                    usedStorage: usedStorage,
                    totalStorage: totalStorage,
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: S3ObjectAllCountSelector((count) {
                  return S3ObjectIsAllCountLoadingSelector((isLoading) {
                    return AdaptiveLoadingBar(
                      isLoading: isLoading,
                      minHeight: 10,
                      type: LoadingBarType.minimal,
                      child: _buildStatCard(
                        title: Tr.photo.takenPhotos.tr(),
                        value: count.toString(),
                        unit: Tr.photo.unit.tr(),
                        icon: Icons.photo_camera,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBoostCtaCard({
    required double usedStorage,
    required double totalStorage,
  }) {
    final ratio = totalStorage <= 0
        ? 0.0
        : (usedStorage / totalStorage).clamp(0.0, 1.0);

    final title = ratio >= 0.85 ? '저장공간이 거의 찼어요' : '필요할 때 저장공간을 넉넉하게';
    final description = ratio >= 0.85
        ? '새 사진을 추가하기 전에, 짧은 광고를 보고 용량을 확보할 수 있어요.'
        : '원할 때만 짧게 보고, 저장공간을 조금 더 확보할 수 있어요.';

    return BlocBuilder<AppRewardBloc, AppRewardState>(
      buildWhen: (prev, curr) =>
          (prev as dynamic).isRewardAdLoading !=
          (curr as dynamic).isRewardAdLoading,
      builder: (context, state) {
        final isLoading = (state as dynamic).isRewardAdLoading == true;

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withOpacity(0.7),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.65),
                  Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.45),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _showStorageBoostAd,
                              icon: isLoading
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.play_circle_outline),
                              label: Text(
                                isLoading ? '불러오는 중…' : '짧게 보고 용량 확보',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '광고 시청은 선택사항이에요. 보상은 광고를 끝까지 시청했을 때 적용돼요.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Tr.common.quickAction.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: Tr.common.gallery.tr(),
                icon: Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  context.push('/gallery');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: Tr.common.album.tr(),
                icon: Icons.photo_album,
                color: Colors.orange,
                onTap: () {
                  s3ObjectPageBloc.add(ClearS3Object());
                  s3ObjectPageBloc.add(FetchNextS3Object());
                  context.push('/albums');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: Tr.family.familyShare.tr(),
                icon: Icons.family_restroom,
                color: Colors.green,
                onTap: () {
                  context.push('/family');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Tr.photo.recentPhotos.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        S3ObjectIsLoadingSelector((isLoading) {
          return S3ObjectsSelector((s3Objects) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: maxRecentPhotoCount,
              itemBuilder: (context, index) {
                final s3Object = s3Objects.length > index
                    ? s3Objects[index]
                    : null;
                return _buildPhotoCard(s3Object);
              },
            );
          });
        }),
      ],
    );
  }

  Widget _buildPhotoCard(S3Object? s3Object) {
    return AwsS3ObjectPhotoCard(
      s3Object: s3Object,
      onTap: () {
        if (s3Object != null) {
          s3ObjectBloc.add(
            S3ObjectEvent.findOneOrFail(s3Object.id, widget.user),
          );
          context.push('/photo-detail');
        }
      },
    );
  }

  void _showGroupBottomSelectModal({
    required BuildContext context,
    required List<User> users,
    required User selectedUser,
  }) {
    BottomSelectModal.show<User>(
      context: context,
      title: Tr.app.profileList.tr(),
      items: users,
      initialValue: selectedUser,
      labelBuilder: (user) {
        final userGroupName = user.userGroups?.firstOrNull?.name;
        return '${user.username ?? 'no name'} (${userGroupName ?? 'no group'})';
      },
      onConfirm: (user) {
        if (user != null) {
          userBloc.add(UserEvent.changeAppUser(user));
          if (context.mounted) {
            // Navigator.pop(context);
          }
        }
      },
    );
  }
}
