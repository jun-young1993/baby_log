import 'package:flutter/material.dart';
import 'package:flutter_common/models/aws/s3/s3_object.dart';

/// NavigationThumbnails - Shows previous/next media thumbnails
/// Allows navigation between media items
class NavigationThumbnails extends StatelessWidget {
  final List<S3Object>? previous;
  final List<S3Object>? next;
  final Function(String objectId) onThumbnailTap;
  final double thumbnailSize;

  const NavigationThumbnails({
    super.key,
    required this.previous,
    required this.next,
    required this.onThumbnailTap,
    this.thumbnailSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous items
        Row(
          children:
              previous?.map((object) {
                return _buildThumbnailImage(
                  imageUrl: object.thumbnailUrl,
                  onTap: () => onThumbnailTap(object.id),
                );
              }).toList() ??
              [
                _buildPlaceholderImage(
                  placeholder: "No more",
                  size: thumbnailSize,
                ),
              ],
        ),
        // Next items
        Row(
          children:
              next?.map((object) {
                return _buildThumbnailImage(
                  imageUrl: object.thumbnailUrl,
                  onTap: () => onThumbnailTap(object.id),
                );
              }).toList() ??
              [
                _buildPlaceholderImage(
                  placeholder: "No more",
                  size: thumbnailSize,
                ),
              ],
        ),
      ],
    );
  }

  /// Builds a single thumbnail image
  Widget _buildThumbnailImage({
    String? imageUrl,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: thumbnailSize,
        height: thumbnailSize,
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
                          width: thumbnailSize * 0.4,
                          height: thumbnailSize * 0.4,
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
                        size: thumbnailSize * 0.4,
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.image,
                    color: Colors.white.withOpacity(0.5),
                    size: thumbnailSize * 0.4,
                  ),
                ),
        ),
      ),
    );
  }

  /// Builds placeholder when no more items
  Widget _buildPlaceholderImage({
    required String placeholder,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Center(
        child: Text(
          placeholder,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
