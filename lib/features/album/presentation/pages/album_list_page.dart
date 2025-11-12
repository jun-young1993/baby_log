import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_album_infinity_grid.dart';
import 'package:flutter/material.dart';
import 'package:baby_log/features/album/presentation/widgets/s3_object_search.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object_tag.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:flutter_common/widgets/buttons/loading_icon_button.dart';

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

  @override
  void initState() {
    super.initState();
    s3ObjectBloc.add(S3ObjectEvent.initializeEmotionTags());
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
      body: Column(children: [Expanded(child: _buildAlbumGrid())]),
    );
  }

  Widget _buildAlbumGrid() {
    return AwsS3ObjectAlbumInfinityGrid(
      user: widget.user,
      enableDateTextVisibility: true,
      enableEmotionVisibility: true,
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
