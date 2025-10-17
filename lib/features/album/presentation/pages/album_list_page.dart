import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_album_infinity_grid.dart';
import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_photo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:go_router/go_router.dart';
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
  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();

  @override
  void initState() {
    super.initState();
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
    return AwsS3ObjectAlbumInfinityGrid(
      user: widget.user,
      initState: () {
        s3ObjectPageBloc.add(ClearS3Object());
        s3ObjectPageBloc.add(FetchNextS3Object());
      },
      fetchNextPage: () {
        s3ObjectPageBloc.add(FetchNextS3Object());
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
