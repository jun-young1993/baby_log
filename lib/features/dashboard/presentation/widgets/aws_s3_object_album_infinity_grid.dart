import 'dart:io';

import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_photo_card.dart';
import 'package:baby_log/features/dashboard/presentation/widgets/native_ad_widget.dart';
import 'package:flutter/material.dart';
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

  /// 특정 인덱스에 커스텀 위젯 삽입
  /// 예: {9: Widget, 18: Widget} -> 9번째, 18번째 위치에 커스텀 위젯
  final Map<int, Widget>? customWidgets;

  /// 또는 함수로 동적 생성
  /// 예: (index) => index % 9 == 0 ? AdWidget() : null
  /// null을 반환하면 기본 아이템 카드 표시
  final Widget? Function(int index)? customWidgetBuilder;

  AwsS3ObjectAlbumInfinityGrid({
    super.key,
    required this.user,
    required this.initState,
    required this.fetchNextPage,
    this.customWidgets,
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

  // 광고 캐시를 State 클래스로 이동
  final Map<int, NativeAdWidget> _nativeAdCache = {};

  @override
  void initState() {
    super.initState();
    widget.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAlbumGrid();
  }

  NativeAdWidget _buildAd(int index) {
    if (!_nativeAdCache.containsKey(index)) {
      _nativeAdCache[index] = NativeAdWidget(
        adUnitId: Platform.isIOS
            ? 'ca-app-pub-4656262305566191/2883468229'
            : 'ca-app-pub-4656262305566191/7647682074',
        height: 50,
      );
    }

    return _nativeAdCache[index]!;
  }

  Widget _buildAlbumGrid() {
    return BlocBuilder<S3ObjectPageBloc, PagingState<int, S3Object>>(
      bloc: s3ObjectPageBloc,
      builder: (context, state) {
        return PagedGridView<int, S3Object>(
          state: state,
          fetchNextPage: widget.fetchNextPage,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 인스타그램처럼 3열
            childAspectRatio: 1.0, // 정사각형 비율
            crossAxisSpacing: 2, // 인스타그램처럼 얇은 간격
            mainAxisSpacing: 2,
          ),
          builderDelegate: PagedChildBuilderDelegate<S3Object>(
            itemBuilder: (context, item, index) {
              // 1. customWidgets 맵에 해당 인덱스가 있는지 확인
              if (index == 3) {
                return _buildAd(index);
              }

              // 3. 기본 아이템 카드 표시
              return _buildAlbumCard(item);
            },
            firstPageProgressIndicatorBuilder: (_) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 50,
                  ),
                ),
              ),
            ),
            newPageProgressIndicatorBuilder: (_) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 50,
                  ),
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
}
