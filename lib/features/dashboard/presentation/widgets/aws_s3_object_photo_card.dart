import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';
import 'package:flutter_common/utils/date_formatter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AwsS3ObjectPhotoCard extends StatelessWidget {
  final S3Object? s3Object;
  final VoidCallback onTap;
  final bool enableDateTextVisibility;
  final bool enableEmotionVisibility;

  const AwsS3ObjectPhotoCard({
    super.key,
    this.s3Object,
    required this.onTap,
    this.enableDateTextVisibility = true,
    this.enableEmotionVisibility = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Placeholder image
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: s3Object?.thumbnailUrl == null
                      ? Icon(
                          Icons.photo,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : Image.network(
                          s3Object!.thumbnailUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: (s3Object?.isVideo ?? false)
                        ? Colors.black.withOpacity(0.75)
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (s3Object?.isVideo ?? false)
                              ? Icons.play_circle_fill
                              : Icons.photo_outlined,
                          size: 18,
                          color: (s3Object?.isVideo ?? false)
                              ? Colors.white
                              : Colors.black87,
                        ),
                        // const SizedBox(width: 6),
                        // Text(
                        //   (s3Object?.isVideo ?? false) ? 'VIDEO' : 'PHOTO',
                        //   style: Theme.of(context).textTheme.labelSmall
                        //       ?.copyWith(
                        //         color: (s3Object?.isVideo ?? false)
                        //             ? Colors.white
                        //             : Colors.black87,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ), // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First moment badge
                      const SizedBox(height: 8),
                      if (enableDateTextVisibility)
                        // Date
                        Text(
                          s3Object != null
                              ? DateFormatter.getRelativeTime(
                                  s3Object?.createdAt ?? DateTime.now(),
                                )
                              : Tr.photo.noPhoto.tr(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                    ],
                  ),
                ),
              ),

              // Emotion indicator (max 3 icons + count)
              if (s3Object?.emotions != null &&
                  s3Object!.emotions.isNotEmpty &&
                  enableEmotionVisibility)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 120, // Prevent overflow
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Up to 3 chips with strong contrast (colored dot + white icon)
                        ...s3Object!.emotions.take(3).map((tag) {
                          final Color chipColor =
                              (tag?.emotionColorValue ?? Colors.grey)
                                  .withOpacity(0.95);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Tooltip(
                              message: tag?.name ?? '',
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  tag?.icon ?? Icons.help_outline,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                        // Show +N if more than 3
                        if (s3Object!.emotions.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              '+${s3Object!.emotions.length - 3}',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: SizeConstants.getSmallIconSize(
                                  context,
                                ),
                                fontWeight: FontWeight.w700,
                              ),
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

  /// Parses hex color string to Color
  /// Supports formats: #ffffff, #fff, ffffff, fff
  // ignore: unused_element
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.white; // Default color
    }

    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');

      // Handle short format (#fff -> #ffffff)
      if (hexColor.length == 3) {
        hexColor = hexColor.split('').map((c) => c + c).join();
      }

      // Add alpha if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      debugPrint('Error parsing color: $colorString, error: $e');
      return Colors.white; // Fallback color
    }
  }
}
