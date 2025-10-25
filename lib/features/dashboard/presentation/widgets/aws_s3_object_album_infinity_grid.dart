import 'dart:io';
// import kept below
import 'package:baby_log/core/widgets/native_ad_modal_widget.dart';
import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_photo_card.dart';
import 'package:flutter/material.dart';
import 'package:baby_log/features/dashboard/presentation/widgets/native_ad_widget.dart';
import 'package:flutter_common/widgets/ad/ad_master.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AwsS3ObjectAlbumInfinityGrid extends StatefulWidget {
  final User user;
  final VoidCallback initState;
  final VoidCallback fetchNextPage;

  final Widget? Function(int index)? customWidgetBuilder;

  const AwsS3ObjectAlbumInfinityGrid({
    super.key,
    required this.user,
    required this.initState,
    required this.fetchNextPage,

    this.customWidgetBuilder,
  });

  @override
  State<AwsS3ObjectAlbumInfinityGrid> createState() =>
      _AwsS3ObjectAlbumInfinityGridState();
}

class _AwsS3ObjectAlbumInfinityGridState
    extends State<AwsS3ObjectAlbumInfinityGrid> {
  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();

  final _nativeAdWidgetCache = <int, Widget>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAlbumGrid();
  }

  Widget _buildAlbumGrid() {
    return BlocBuilder<S3ObjectPageBloc, PagingState<int, S3Object>>(
      bloc: s3ObjectPageBloc,
      builder: (context, state) {
        return PagedGridView<int, S3Object>(
          state: state,
          fetchNextPage: widget.fetchNextPage,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // 전폭 1열
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            mainAxisExtent: 220, // 행 높이 고정 (광고/이미지 동일)
          ),
          builderDelegate: PagedChildBuilderDelegate<S3Object>(
            itemBuilder: (context, item, index) {
              if (_isAdPosition(index)) {
                if (_nativeAdWidgetCache.containsKey(index)) {
                  return _nativeAdWidgetCache[index]!;
                }
                final widget = _buildFullWidthAdTile(context);
                _nativeAdWidgetCache[index] = widget;
                return widget;
              }
              return _buildAlbumCard(item);
            },
            firstPageProgressIndicatorBuilder: (_) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 50,
                ),
              ),
            ),
            newPageProgressIndicatorBuilder: (_) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 50,
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Tr.message.lastData.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => Center(
              child: Text(
                Tr.message.noData.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 8,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(S3Object object) {
    return AwsS3ObjectPhotoCard(
      s3Object: object,
      enableDateTextVisibility: false,
      enableEmotionVisibility: false,
      onTap: () {
        s3ObjectBloc.add(S3ObjectEvent.findOneOrFail(object.id, widget.user));
        context.push('/photo-detail');
      },
    );
  }

  // 광고 주기 및 오프셋 (아이템 인덱스 기준)
  static const int _adFrequency = 12; // 12개마다 광고 1개
  static const int _adOffset = 8; // 첫 광고는 8개 이후부터

  bool _isAdPosition(int index) {
    final pos = index + 1;
    if (pos <= _adOffset) return false;
    return (pos - _adOffset) % _adFrequency == 0;
  }

  Widget _buildFullWidthAdTile(BuildContext context) {
    final String adUnitId = AdMaster().getAdUnitIdForType(
      AdType.native,
      adMobUnitId: Platform.isIOS
          ? 'ca-app-pub-4656262305566191/2883468229'
          : 'ca-app-pub-4656262305566191/7647682074',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: NativeAdWidget(adUnitId: adUnitId, height: 140),
      ),
    );
  }
}
