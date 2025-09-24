import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
    s3ObjectPageBloc.add(FetchNextS3Object(widget.user));
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
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              // 사진 추가 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildAlbumGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색바
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: '앨범 검색...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 필터 칩들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.5),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumGrid() {
    return BlocBuilder<S3ObjectPageBloc, PagingState<int, S3Object>>(
      bloc: s3ObjectPageBloc,
      builder: (context, state) {
        print(state);
        // return Text('hi');
        // _buildAlbumCard(item)
        return PagedListView<int, S3Object>(
          state: state,
          fetchNextPage: () {
            s3ObjectPageBloc.add(FetchNextS3Object(widget.user));
          },
          builderDelegate: PagedChildBuilderDelegate<S3Object>(
            itemBuilder: (context, item, index) => _buildAlbumCard(item),
            firstPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            noMoreItemsIndicatorBuilder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Tr.message.lastNotice.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) =>
                Center(child: Text(Tr.message.notFoundNotice.tr())),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(S3Object object) {
    return GestureDetector(
      onTap: () {
        // 앨범 상세 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 - 고정 높이 사용
                SizedBox(
                  height: 130, // 고정 높이
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.3),
                              Theme.of(
                                context,
                              ).colorScheme.secondaryContainer.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: object.url != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant
                                        .withOpacity(0.3),
                                  ),
                                  child: Image.network(
                                    object.url!,
                                    fit: BoxFit.contain, // 비율 유지하면서 잘리지 않게
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderThumbnail(object);
                                    },
                                  ),
                                ),
                              )
                            : _buildPlaceholderThumbnail(object),
                      ),
                      // 타입 아이콘
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            object.isImage ? Icons.image : Icons.videocam,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      // 재생 버튼 (비디오인 경우)
                      if (object.isVideo)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 정보 - 고정 높이 사용
                SizedBox(
                  height: 90, // 고정 높이
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          object.originalName ?? '이름 없음',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          object.formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                object.fileSize,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail(S3Object object) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          object.isImage ? Icons.image_outlined : Icons.videocam_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
