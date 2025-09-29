import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AlbumListPage extends StatefulWidget {
  final User user;
  const AlbumListPage({super.key, required this.user});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  String _selectedFilter = '전체';

  final List<String> _filterOptions = ['전체', '사진', '동영상', '기타'];

  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();

  @override
  void initState() {
    super.initState();

    s3ObjectPageBloc.add(ClearS3Object());
    s3ObjectPageBloc.add(FetchNextS3Object());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('앨범'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 사진 추가 기능
            },
          ),
        ],
      ),
      body: Column(children: [Expanded(child: _buildAlbumGrid())]),
    );
  }

  Widget _buildAlbumGrid() {
    return BlocBuilder<S3ObjectPageBloc, PagingState<int, S3Object>>(
      bloc: s3ObjectPageBloc,
      builder: (context, state) {
        return PagedGridView<int, S3Object>(
          state: state,
          fetchNextPage: () {
            s3ObjectPageBloc.add(FetchNextS3Object());
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 인스타그램처럼 3열
            childAspectRatio: 1.0, // 정사각형 비율
            crossAxisSpacing: 2, // 인스타그램처럼 얇은 간격
            mainAxisSpacing: 2,
          ),
          builderDelegate: PagedChildBuilderDelegate<S3Object>(
            itemBuilder: (context, item, index) => _buildAlbumCard(item),
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
                Tr.message.lastNotice.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => Center(
              child: Text(
                Tr.message.notFoundNotice.tr(),
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
    return InkWell(
      onTap: () {
        // 앨범 상세 페이지로 이동
      },
      borderRadius: BorderRadius.circular(0), // 인스타그램처럼 둥근 모서리 없음
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // 메인 이미지 - 정사각형으로 꽉 채움
            Container(
              width: double.infinity,
              height: double.infinity,
              child: object.url != null
                  ? CachedNetworkImage(
                      imageUrl: object.url!,
                      fit: BoxFit.cover, // 인스타그램처럼 꽉 채움
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3),
                        child: Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholderThumbnail(object),
                    )
                  : _buildPlaceholderThumbnail(object),
            ),
            // 비디오 재생 버튼 (비디오인 경우)
            if (object.isVideo)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 32, // 인스타그램처럼 작게
                      ),
                    ),
                  ),
                ),
              ),
            // 하단 그라데이션 오버레이 (선택사항)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: 0.6,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail(S3Object object) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: Icon(
          object.isImage ? Icons.image_outlined : Icons.videocam_outlined,
          size: 32, // 인스타그램처럼 작게
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}
