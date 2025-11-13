import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_album_infinity_grid.dart';
import 'package:flutter/material.dart';
import 'package:baby_log/features/album/presentation/widgets/s3_object_search.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object_tag.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:flutter_common/widgets/buttons/loading_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumListPage extends StatefulWidget {
  final User user;
  const AlbumListPage({super.key, required this.user});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();

  List<S3ObjectTag> _selectedEmotionTags = <S3ObjectTag>[];

  final List<int> _gridOptions = [1, 2, 3, 4];
  int _gridIndex = 0;
  final String _gridIndexKey = 'baby_log.album_list_page.grid_index';

  void _cycleGridColumns() {
    setState(() {
      _gridIndex = (_gridIndex + 1) % _gridOptions.length;
    });
    SharedPreferences.getInstance().then((value) {
      value.setInt(_gridIndexKey, _gridIndex);
    });
  }

  IconData _gridIconFor(int cols) {
    switch (cols) {
      case 1:
        return Icons.view_list;
      case 2:
        return Icons.view_module;
      case 3:
        return Icons.view_comfy_alt;
      case 4:
        return Icons.grid_view;
      default:
        return Icons.grid_on;
    }
  }

  @override
  void initState() {
    super.initState();
    s3ObjectBloc.add(S3ObjectEvent.initializeEmotionTags());
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _gridIndex = value.getInt(_gridIndexKey) ?? 0;
      });
    });
  }

  void onRefresh() async {
    s3ObjectBloc.add(S3ObjectEvent.initializeEmotionTags());
    setState(() {
      _selectedEmotionTags = [];
    });
    s3ObjectPageBloc.add(ClearS3Object());
    s3ObjectPageBloc.add(FetchNextS3Object(tags: []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(Tr.common.album.tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 그리드 열 개수 선택 버튼 (순환 + 아이콘 변경)
          IconButton(
            tooltip: '${_gridOptions[_gridIndex]}',
            icon: Icon(_gridIconFor(_gridOptions[_gridIndex])),
            onPressed: _cycleGridColumns,
          ),
          S3ObjectUploadErrorSelector((emotionTagError) {
            return S3ObjectEmotionTagsSelector((emotionTags) {
              return S3ObjectIsEmotionTagsLoadingSelector((emotionTagLoding) {
                return LoadingIconButton(
                  icon: Icons.search,
                  isLoading: emotionTagLoding,
                  tooltip: Tr.common.search.tr(),
                  onPressed: () async {
                    await showS3ObjectSearchBottomSheet(
                      context: context,
                      emotionTags: emotionTags,
                      isLoading: emotionTagLoding,
                      error: emotionTagError,
                      initialSelected: _selectedEmotionTags,
                      onRefresh: () async => onRefresh(),
                      onRetry: () {
                        s3ObjectBloc.add(S3ObjectEvent.initializeEmotionTags());
                      },
                      onConfirm: (tags) {
                        setState(() {
                          _selectedEmotionTags = tags;
                        });
                        s3ObjectPageBloc.add(ClearS3Object());
                        s3ObjectPageBloc.add(FetchNextS3Object(tags: tags));
                      },
                    );
                  },
                );
              });
            });
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: Column(children: [Expanded(child: _buildAlbumGrid())]),
      ),
    );
  }

  Widget _buildAlbumGrid() {
    return AwsS3ObjectAlbumInfinityGrid(
      user: widget.user,
      enableDateTextVisibility: true,
      enableEmotionVisibility: true,
      crossAxisCount: _gridOptions[_gridIndex],
      initState: () {
        s3ObjectPageBloc.add(ClearS3Object());
        s3ObjectPageBloc.add(FetchNextS3Object(tags: _selectedEmotionTags));
      },
      fetchNextPage: () {
        s3ObjectPageBloc.add(FetchNextS3Object(tags: _selectedEmotionTags));
      },
      // 매 9개마다 광고 표시 (3x3 그리드 후)
    );
  }
}
