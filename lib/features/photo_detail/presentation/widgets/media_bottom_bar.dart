import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/models/aws/s3/s3_object_like.dart';

/// MediaBottomBar - Action bar for media (like, comment)
/// Displays like and comment buttons with appropriate states
class MediaBottomBar extends StatelessWidget {
  final S3Object s3Object;
  final S3ObjectLike? like;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;

  const MediaBottomBar({
    super.key,
    required this.s3Object,
    required this.like,
    required this.onLikeTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
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
            _buildBottomBarButton(
              color: like == null ? Colors.white : Colors.red,
              icon: like == null ? Icons.favorite_border : Icons.favorite,
              label: Tr.app.like.tr(),
              onTap: onLikeTap,
            ),
            _buildBottomBarButton(
              icon: Icons.comment_outlined,
              label: Tr.common.reply.tr(),
              onTap: onCommentTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single action button
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
}
