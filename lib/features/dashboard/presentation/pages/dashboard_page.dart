import 'package:flutter/material.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_event.dart';
import 'package:flutter_common/state/user_group/user_group_selector.dart';
import 'package:flutter_common/utils/date_formatter.dart';
import 'package:flutter_common/widgets/loader/loading_overay.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_common/flutter_common.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();
  NoticeGroupBloc get noticeGroupBloc => context.read<NoticeGroupBloc>();

  bool isShowUserGroupGuide = false;

  String _searchQuery = '';
  final maxRecentPhotoCount = 6;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    s3ObjectBloc.add(
      S3ObjectEvent.getS3Objects(widget.user, 0, maxRecentPhotoCount),
    );
    userGroupBloc.add(UserGroupEvent.findAll());
    s3ObjectBloc.add(S3ObjectEvent.count());
    noticeGroupBloc.add(NoticeGroupEvent.initialize(widget.user.id));

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
                  tooltip: userGroup != null ? '가족 공유' : '가족 그룹을 먼저 설정해주세요',
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
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatisticsCards(),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 24),

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
                label: const Text('사진 촬영'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              )
            : const SizedBox.shrink();
      }),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 주 통계',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
                      title: '촬영한 사진',
                      value: count.toString(),
                      unit: '장',
                      icon: Icons.photo_camera,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                });
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '행복한 순간',
                value: '18',
                unit: '개',
                icon: Icons.sentiment_very_satisfied,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '첫 순간',
                value: '3',
                unit: '개',
                icon: Icons.star,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '가족 공유',
                value: '12',
                unit: '장',
                icon: Icons.share,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      decoration: InputDecoration(
        hintText: '사진 검색 (예: 행복, 첫 미소)',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: '갤러리',
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
                title: '앨범 만들기',
                icon: Icons.photo_album,
                color: Colors.orange,
                onTap: () {
                  context.push('/albums');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: '가족 공유',
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
                fontSize: 11,
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
          return LoadingOverlay(
            isLoading: isLoading,
            child: S3ObjectsSelector((s3Objects) {
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
            }),
          );
        }),
      ],
    );
  }

  Widget _buildPhotoCard(S3Object? s3Object) {
    return _buildPhotoCardWithParams(s3Object: s3Object);
  }

  Widget _buildPhotoCardWithParams({S3Object? s3Object}) {
    return InkWell(
      onTap: () {
        if (s3Object != null) {
          s3ObjectBloc.add(S3ObjectEvent.findOneOrFail(s3Object.id));
          context.push('/photo-detail');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Placeholder image
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: s3Object?.url == null
                      ? Icon(
                          Icons.photo,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : Image.network(
                          s3Object!.url!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First moment badge
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        s3Object != null ? s3Object.originalName ?? '' : '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Date
                      Text(
                        s3Object != null
                            ? DateFormatter.getRelativeTime(
                                s3Object.createdAt ?? DateTime.now(),
                              )
                            : Tr.photo.noPhoto.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Emotion indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.sentiment_neutral,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
