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
  final bool enableCaptionVisibility;
  const AwsS3ObjectPhotoCard({
    super.key,
    this.s3Object,
    required this.onTap,
    this.enableDateTextVisibility = true,
    this.enableEmotionVisibility = true,
    this.enableCaptionVisibility = true,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 크기에 따라 감정 아이콘 크기를 동적으로 결정하는 로직
    final double width = MediaQuery.of(context).size.width;

    // 감정 아이콘 컨테이너 및 아이콘 크기 결정
    // 작은 카드에서는 작게, 큰 카드에서는 적당히 크게 설정하여
    // 카드 이미지를 방해하지 않으면서도 가독성을 유지
    double emotionIconSize;
    double emotionContainerSize;

    if (width <= 300) {
      // 작은 카드: 최소 크기로 설정
      emotionIconSize = 8;
      emotionContainerSize = 10;
    } else if (width <= 500) {
      // 중간 카드: 기본 크기
      emotionIconSize = 12;
      emotionContainerSize = 14;
    } else {
      // 큰 카드: 약간 크게
      emotionIconSize = 14;
      emotionContainerSize = 16;
    }
    bool isHidden = s3Object?.isHidden ?? false;
    if (isHidden) {
      final caption = s3Object?.caption(context) ?? '';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Text(caption),
          ],
        ),
      );
    }
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
                          size: emotionIconSize,
                          color: (s3Object?.isVideo ?? false)
                              ? Colors.white
                              : Colors.black87,
                        ),
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
                      if (enableCaptionVisibility)
                        Text(
                          s3Object?.caption(context) ?? '',
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
                                width: emotionContainerSize,
                                height: emotionContainerSize,
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
                                  size: emotionIconSize,
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
