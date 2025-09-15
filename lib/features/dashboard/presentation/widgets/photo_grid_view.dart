import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

class PhotoGridView extends StatelessWidget {
  final String searchQuery;

  const PhotoGridView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual photo data from provider
    final photos = _getMockPhotos();
    final filteredPhotos = _filterPhotos(photos, searchQuery);

    if (filteredPhotos.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 사진',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: filteredPhotos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final photo = filteredPhotos[index];
            return _PhotoCard(
              photo: photo,
              onTap: () {
                context.push('/photo-detail/${photo.id}');
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? '아직 사진이 없어요' : '검색 결과가 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty ? '첫 번째 사진을 촬영해보세요!' : '다른 키워드로 검색해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/photo-capture');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('사진 촬영하기'),
            ),
          ],
        ],
      ),
    );
  }

  List<PhotoData> _getMockPhotos() {
    // TODO: Replace with actual data from provider
    return [
      PhotoData(
        id: '1',
        imageUrl: 'https://picsum.photos/300/400?random=1',
        title: '첫 미소',
        date: DateTime.now().subtract(const Duration(days: 1)),
        emotion: 'happy',
        isFirstMoment: true,
      ),
      PhotoData(
        id: '2',
        imageUrl: 'https://picsum.photos/300/500?random=2',
        title: '놀이 시간',
        date: DateTime.now().subtract(const Duration(days: 2)),
        emotion: 'excited',
        isFirstMoment: false,
      ),
      PhotoData(
        id: '3',
        imageUrl: 'https://picsum.photos/300/350?random=3',
        title: '잠자는 모습',
        date: DateTime.now().subtract(const Duration(days: 3)),
        emotion: 'calm',
        isFirstMoment: false,
      ),
      PhotoData(
        id: '4',
        imageUrl: 'https://picsum.photos/300/450?random=4',
        title: '첫 이유식',
        date: DateTime.now().subtract(const Duration(days: 4)),
        emotion: 'curious',
        isFirstMoment: true,
      ),
      PhotoData(
        id: '5',
        imageUrl: 'https://picsum.photos/300/380?random=5',
        title: '산책 중',
        date: DateTime.now().subtract(const Duration(days: 5)),
        emotion: 'happy',
        isFirstMoment: false,
      ),
      PhotoData(
        id: '6',
        imageUrl: 'https://picsum.photos/300/420?random=6',
        title: '가족과 함께',
        date: DateTime.now().subtract(const Duration(days: 6)),
        emotion: 'loving',
        isFirstMoment: false,
      ),
    ];
  }

  List<PhotoData> _filterPhotos(List<PhotoData> photos, String query) {
    if (query.isEmpty) return photos;

    return photos.where((photo) {
      return photo.title.toLowerCase().contains(query.toLowerCase()) ||
          photo.emotion.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

class _PhotoCard extends StatelessWidget {
  final PhotoData photo;
  final VoidCallback onTap;

  const _PhotoCard({required this.photo, required this.onTap});

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
              // Image
              AspectRatio(
                aspectRatio: 0.75,
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),

              // Gradient overlay
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
                      if (photo.isFirstMoment)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '첫 순간',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        photo.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Date
                      Text(
                        _formatDate(photo.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Emotion indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getEmotionIcon(photo.emotion),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'excited':
        return Icons.celebration;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'curious':
        return Icons.psychology;
      case 'loving':
        return Icons.favorite;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

// Mock data model
class PhotoData {
  final String id;
  final String imageUrl;
  final String title;
  final DateTime date;
  final String emotion;
  final bool isFirstMoment;

  PhotoData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.emotion,
    required this.isFirstMoment,
  });
}
