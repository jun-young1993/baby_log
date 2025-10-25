import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/utils/date_formatter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'navigation_thumbnails.dart';

class MediaInfoOverlay extends StatefulWidget {
  final DateTime? createdAt;
  final int? size;
  final String fileSize;
  final bool isSurroundLoading;
  final dynamic surround;
  final Function(String objectId) onNavigate;

  const MediaInfoOverlay({
    super.key,
    required this.createdAt,
    required this.size,
    required this.fileSize,
    required this.isSurroundLoading,
    required this.surround,
    required this.onNavigate,
  });

  @override
  State<MediaInfoOverlay> createState() => _MediaInfoOverlayState();
}

/// MediaInfoOverlay - Displays media information and navigation
/// Shows date, size, and navigation thumbnails
class _MediaInfoOverlayState extends State<MediaInfoOverlay> {
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
    debugPrint('🔍 MediaInfoOverlay build called');
    debugPrint('🔍 CreatedAt: ${widget.createdAt}');
    debugPrint('🔍 FileSize: ${widget.fileSize}');
    debugPrint('🔍 IsSurroundLoading: ${widget.isSurroundLoading}');
    debugPrint('🔍 Surround: ${widget.surround}');

    return Positioned(
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
            // Date and size information
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
                  _formatDate(widget.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: SizeConstants.getColumnSpacing(context)),
                if (widget.size != null) ...[
                  Icon(
                    Icons.storage,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.fileSize,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // 간단한 테스트용 컨테이너

            // Navigation thumbnails
            if (widget.isSurroundLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.surround != null)
              NavigationThumbnails(
                previous: widget.surround.previous,
                next: widget.surround.next,
                onThumbnailTap: widget.onNavigate,
                thumbnailSize: SizeConstants.getCountdownDisplaySize(context),
              ),
          ],
        ),
      ),
    );
  }

  /// Formats date to relative time
  String _formatDate(DateTime? date) {
    if (date == null) return Tr.app.noDate.tr();
    return DateFormatter.getRelativeTime(date);
  }
}
