import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class S3Object {
  final String id;
  final String? key;
  final String? url;
  final String? originalName;
  final int? size;
  final String? mimetype;
  final bool active;
  final DateTime? createdAt;
  final String? userId;

  const S3Object({
    required this.id,
    this.key,
    this.url,
    this.originalName,
    this.size,
    this.mimetype,
    this.active = false,
    this.createdAt,
    this.userId,
  });

  String get fileSize {
    if (size == null) return '알 수 없음';
    if (size! < 1024) return '${size}B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)}KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    if (createdAt == null) return '알 수 없음';
    return DateFormat('yyyy.MM.dd').format(createdAt!);
  }

  bool get isImage {
    return mimetype?.startsWith('image/') ?? false;
  }

  bool get isVideo {
    return mimetype?.startsWith('video/') ?? false;
  }
}

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  List<S3Object> _albums = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = '전체';

  final List<String> _filterOptions = ['전체', '사진', '동영상', '기타'];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    // 임시 데이터 - 실제로는 API에서 가져와야 합니다
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _albums = [
        S3Object(
          id: '1',
          originalName: '우리 아이 첫 걸음',
          url: 'https://picsum.photos/300/200?random=1',
          mimetype: 'image/jpeg',
          size: 2048000,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          active: true,
        ),
        S3Object(
          id: '2',
          originalName: '생일 파티 영상',
          url: 'https://picsum.photos/300/200?random=2',
          mimetype: 'video/mp4',
          size: 15728640,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          active: true,
        ),
        S3Object(
          id: '3',
          originalName: '가족 여행 사진',
          url: 'https://picsum.photos/300/200?random=3',
          mimetype: 'image/jpeg',
          size: 3072000,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          active: true,
        ),
        S3Object(
          id: '4',
          originalName: '첫 말하기',
          url: 'https://picsum.photos/300/200?random=4',
          mimetype: 'video/mp4',
          size: 8388608,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          active: true,
        ),
        S3Object(
          id: '5',
          originalName: '놀이터에서',
          url: 'https://picsum.photos/300/200?random=5',
          mimetype: 'image/jpeg',
          size: 1536000,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          active: true,
        ),
      ];
      _isLoading = false;
    });
  }

  List<S3Object> get _filteredAlbums {
    var filtered = _albums.where((album) {
      // 검색어 필터링
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final albumName = album.originalName?.toLowerCase() ?? '';
        if (!albumName.contains(query)) {
          return false;
        }
      }

      // 타입 필터링
      switch (_selectedFilter) {
        case '사진':
          return album.isImage;
        case '동영상':
          return album.isVideo;
        case '기타':
          return !album.isImage && !album.isVideo;
        default:
          return true;
      }
    }).toList();

    // 날짜순 정렬 (최신순)
    filtered.sort(
      (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
        a.createdAt ?? DateTime(1970),
      ),
    );

    return filtered;
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
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              // 사진 추가 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredAlbums.isEmpty
                ? _buildEmptyState()
                : _buildAlbumGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색바
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '앨범 검색...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 필터 칩들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.5),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('앨범을 불러오는 중...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_album_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '앨범이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 사진을 추가해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 사진 추가 기능
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('사진 추가하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // 높이를 조금 더 늘려서 텍스트 공간 확보
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredAlbums.length,
      itemBuilder: (context, index) {
        final album = _filteredAlbums[index];
        return _buildAlbumCard(album);
      },
    );
  }

  Widget _buildAlbumCard(S3Object album) {
    return GestureDetector(
      onTap: () {
        // 앨범 상세 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.3),
                                Theme.of(context).colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: album.url != null
                              ? Image.network(
                                  album.url!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderThumbnail(album);
                                  },
                                )
                              : _buildPlaceholderThumbnail(album),
                        ),
                        // 타입 아이콘
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              album.isImage ? Icons.image : Icons.videocam,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        // 재생 버튼 (비디오인 경우)
                        if (album.isVideo)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 정보
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                      children: [
                        Flexible(
                          // Flexible로 감싸서 오버플로우 방지
                          child: Text(
                            album.originalName ?? '이름 없음',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              // Flexible로 감싸서 오버플로우 방지
                              child: Text(
                                album.fileSize,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail(S3Object album) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          album.isImage ? Icons.image_outlined : Icons.videocam_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
