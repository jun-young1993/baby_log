import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/models/aws/s3/s3_object_like.dart';
import 'package:flutter_common/models/aws/s3/s3_object_reply.dart';
import 'package:flutter_common/utils/date_formatter.dart';
import 'package:flutter_common/widgets/buttons/report_button.dart';
import 'package:flutter_common/widgets/textes/awesome_description_text.dart';
import 'package:flutter_common/widgets/toast/toast.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';

class PhotoDetailPage extends StatefulWidget {
  final User user;
  const PhotoDetailPage({super.key, required this.user});

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Share.share(
                  s3ObjectBloc.state.s3Object!.url!,
                  subject: '${widget.user.username}(${Tr.app.share.tr()})',
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ReportButton(
              onReport: () => _showReportDialog(context),
              color: Colors.white,
              style: IconButton.styleFrom(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showMoreOptions(context),
            ),
          ),
        ],
      ),
      body: S3ObjectFindOneSelector((s3Object) {
        return S3ObjectIsLoadingSelector((isLoading) {
          if (isLoading) {
            return _buildLoadingState(context);
          }
          return S3ObjectIsDeletingSelector((isDeleting) {
            if (isDeleting) {
              return _buildLoadingState(context);
            }
            return s3Object == null
                ? _buildLoadingState(context)
                : _buildPhotoDetail(context, s3Object);
          });
        });
      }),
      bottomNavigationBar: S3ObjectFindOneSelector(
        (s3Object) => s3Object == null
            ? const SizedBox.shrink()
            : _buildBottomBar(context, s3Object),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Theme.of(context).colorScheme.onSurface,
        size: 24,
      ),
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(height: 16),
          Text(Tr.common.loading.tr(), style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    ReportDialog.show(
      context: context,
      onReport: (type, content) {
        s3ObjectBloc.add(
          S3ObjectEvent.reportS3Object(
            s3ObjectBloc.state.s3Object!,
            type,
            content,
          ),
        );
      },
    );
  }

  void _showReplyReportDialog(BuildContext context, S3ObjectReply reply) {
    ReportDialog.show(
      context: context,
      onReport: (type, content) {
        s3ObjectBloc.add(
          S3ObjectEvent.reportS3ObjectReply(reply, type, content),
        );
      },
    );
  }

  Widget _buildPhotoDetail(BuildContext context, dynamic s3Object) {
    return Stack(
      children: [
        // Full screen image
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: s3Object.url != null
                ? Image.network(
                    s3Object.url!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorState(context);
                    },
                  )
                : _buildErrorState(context),
          ),
        ),

        // Photo info overlay (bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(s3Object.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: SizeConstants.getColumnSpacing(context)),
                    if (s3Object.size != null) ...[
                      Icon(
                        Icons.storage,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s3Object.fileSize,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                S3ObjectIsS3ObjectSurroundLoadingSelector((surroundLoading) {
                  if (surroundLoading) {
                    return _buildLoadingState(context);
                  }
                  return S3ObjectS3ObjectSurroundSelector((surround) {
                    if (surround == null) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children:
                              surround.previous
                                  ?.map(
                                    (object) => _buildThumbnailImage(
                                      imageUrl: object.url!,
                                      onTap: () => s3ObjectBloc.add(
                                        S3ObjectEvent.findOneOrFail(
                                          object.id,
                                          widget.user,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList() ??
                              [
                                _buildPlaceholderImage(
                                  placeholder: "No moreNo",
                                  size: SizeConstants.getCountdownDisplaySize(
                                    context,
                                  ),
                                ),
                              ],
                        ),
                        Row(
                          children:
                              surround.next
                                  ?.map(
                                    (object) => _buildThumbnailImage(
                                      imageUrl: object.url!,
                                      onTap: () => s3ObjectBloc.add(
                                        S3ObjectEvent.findOneOrFail(
                                          object.id,
                                          widget.user,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList() ??
                              [
                                _buildPlaceholderImage(
                                  placeholder: "No moreNo",
                                  size: SizeConstants.getCountdownDisplaySize(
                                    context,
                                  ),
                                ),
                              ],
                        ),
                      ],
                    );
                  });
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 120,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '사진을 불러올 수 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '네트워크 연결을 확인해주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, dynamic s3Object) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            S3ObjectLikeSelector(
              (like) => _buildBottomBarButton(
                color: like == null ? Colors.white : Colors.red,
                icon: like == null ? Icons.favorite_border : Icons.favorite,
                label: Tr.app.like.tr(),
                onTap: () => _toggleLike(context, s3Object, like),
              ),
            ),
            _buildBottomBarButton(
              icon: Icons.comment_outlined,
              label: Tr.common.reply.tr(),
              onTap: () => _showComments(context, s3Object),
            ),
            // _buildBottomBarButton(
            //   icon: Icons.download,
            //   label: '다운로드',
            //   onTap: () => _downloadPhoto(context, s3Object),
            // ),
            // _buildBottomBarButton(
            //   icon: Icons.edit,
            //   label: '편집',
            //   onTap: () => _editPhoto(context, s3Object),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return Tr.app.noDate.tr();
    return DateFormatter.getRelativeTime(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // _buildMoreOption(context, Icons.folder_outlined, '앨범으로 이동'),
            _buildMoreOption(
              context,
              Icons.info_outline,
              Tr.common.info.tr(),
              () => _showFileInfo(context),
            ),

            Divider(color: Colors.white24),

            _buildMoreOption(
              context,
              Icons.delete_outline,
              Tr.common.delete.tr(),
              () {
                _showDeleteObjectDialog(context, () {
                  s3ObjectBloc.add(
                    S3ObjectEvent.deleteFile(
                      s3ObjectBloc.state.s3Object!,
                      widget.user,
                    ),
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              },
              Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(
    BuildContext context,
    IconData icon,
    String label,
    void Function()? onTap, [
    Color? color,
  ]) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }

  void _showFileInfo(BuildContext context) {
    final s3Object = s3ObjectBloc.state.s3Object;
    if (s3Object == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (context, scrollController) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Tr.file.fileInfo.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 파일 기본 정보
                      _buildInfoRow(
                        icon: Icons.title,
                        label: Tr.file.fileName.tr(),
                        value: s3Object.originalName ?? 'unknown',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.file_present,
                        label: Tr.file.fileType.tr(),
                        value: s3Object.mimetype ?? 'unknown',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: Tr.file.fileCreatedAt.tr(),
                        value: s3Object.createdAt.toString(),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        icon: Icons.storage,
                        label: Tr.file.fileSize.tr(),
                        value: '${s3Object.size} Bytes',
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        icon: Icons.link,
                        label: Tr.file.fileUrl.tr(),
                        value: s3Object.url!,
                        isUrl: true,
                      ),
                      const SizedBox(height: 20),

                      // 기술적 정보
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Tr.file.technicalInfo.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTechInfoRow('ID', s3Object.id),
                            _buildTechInfoRow(
                              Tr.file.userId.tr(),
                              s3Object.user?.username ?? 'unknown',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isUrl = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: isUrl
                    ? () {
                        Clipboard.setData(ClipboardData(text: value));
                        Toast.showSuccess(
                          context,
                          message: Tr.app.copyLink.tr(),
                        );
                      }
                    : null,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: isUrl ? TextDecoration.underline : null,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage({
    required String placeholder,
    required double size,
  }) {
    return Text(
      'hi',
      style: TextStyle(color: Colors.white, fontSize: size * 0.2),
    );
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          placeholder,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: size * 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage({
    String? imageUrl,
    required VoidCallback onTap,
    double size = 50,
    bool isSelected = false,
    String? placeholder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: SizedBox(
                          width: size * 0.4,
                          height: size * 0.4,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.image,
                        color: Colors.white.withOpacity(0.5),
                        size: size * 0.4,
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[800],
                  child: placeholder != null
                      ? _buildPlaceholderImage(
                          placeholder: placeholder,
                          size: size,
                        )
                      : Icon(
                          Icons.image,
                          color: Colors.white.withOpacity(0.5),
                          size: size * 0.4,
                        ),
                ),
        ),
      ),
    );
  }

  void _toggleLike(
    BuildContext context,
    S3Object s3Object,
    S3ObjectLike? like,
  ) {
    if (like == null) {
      s3ObjectBloc.add(S3ObjectEvent.likeS3Object(s3Object, widget.user));
    } else {
      s3ObjectBloc.add(S3ObjectEvent.removeLikeS3Object(like, widget.user));
    }
  }

  Widget _buildEmptyComments(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withOpacity(0.3),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Tr.notice.noReply.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Tr.notice.firstReply.tr(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            AwesomeDescriptionText(
              fontSize: 11,
              text: Tr.notice.contentDescription.tr(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteReplyDialog(BuildContext context, void Function() onConfirm) {
    AppDialog.showWarning(
      context: context,
      title: Tr.message.deleteDataTitle.tr(
        namedArgs: {'name': Tr.common.reply.tr()},
      ),
      confirmText: Tr.app.confirm.tr(),
      cancelText: Tr.app.cancel.tr(),
      message:
          '${Tr.message.deleteDataWarning.tr()}\r\n${Tr.message.deleteDataDescription.tr()}',
      onConfirm: onConfirm,
    );
  }

  void _showDeleteObjectDialog(
    BuildContext context,
    void Function() onConfirm,
  ) {
    AppDialog.showWarning(
      context: context,
      title: Tr.message.deleteDataTitle.tr(namedArgs: {'name': ''}),
      message: Tr.message.deleteDataWarning.tr(),
      confirmText: Tr.app.confirm.tr(),
      cancelText: Tr.app.cancel.tr(),
      onConfirm: onConfirm,
    );
  }

  void _showComments(BuildContext context, dynamic s3Object) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => S3ObjectFindOneSelector(
          (s3Object) => Container(
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Tr.notice.replyCount.tr(
                          namedArgs: {
                            'count':
                                s3Object?.replies?.length.toString() ?? '0',
                          },
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                // Comments list
                Expanded(
                  flex: 2,
                  child: s3Object?.replies?.isEmpty ?? true
                      ? _buildEmptyComments(context)
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: s3Object?.replies?.length ?? 0,
                          itemBuilder: (context, index) => _buildCommentItem(
                            context,
                            s3Object?.replies?[index],
                          ),
                        ),
                ),
                // Comment input
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 경고 문구 (작고 은은하게)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.4),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  Tr.notice.contentDescription.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 10,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 입력 필드와 버튼
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: Tr.notice.enterReply.tr(),
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  final commentText = _commentController.text
                                      .trim();
                                  if (commentText.isNotEmpty &&
                                      s3Object != null) {
                                    s3ObjectBloc.add(
                                      S3ObjectEvent.replyS3Object(
                                        s3Object,
                                        widget.user,
                                        commentText,
                                      ),
                                    );
                                    _commentController.clear();
                                  }
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: SizeConstants.getLargeIconSize(
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildCommentItem(BuildContext context, S3ObjectReply? reply) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply?.user.username ?? 'unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.getRelativeTime(
                        reply?.createdAt ?? DateTime.now(),
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply?.content ?? 'unknown',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (reply?.user.id == widget.user.id || widget.user.isAdmin)
                      InkWell(
                        onTap: () {
                          _showDeleteReplyDialog(context, () {
                            s3ObjectBloc.add(
                              S3ObjectEvent.removeReplyS3Object(
                                reply!,
                                widget.user,
                              ),
                            );
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            Tr.common.delete.tr(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () => _showReplyReportDialog(context, reply!),
                      child: Text(
                        Tr.common.report.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // widget.user.isAdmin || reply?.user.id == widget.user.id
          //     ? IconButton(
          //         icon: Icon(
          //           Icons.delete,
          //           color: Colors.white.withOpacity(0.6),
          //           size: 18,
          //         ),
          //         onPressed: () {},
          //       )
          //     : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
