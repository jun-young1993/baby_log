import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AdError;
import '../../../../core/services/photo_service.dart';
import '../../../../core/models/photo_model.dart';

class PhotoCaptureInterstitialAdCallback extends AdCallback {
  final onAdLoadedCallback;
  PhotoCaptureInterstitialAdCallback({required this.onAdLoadedCallback});
  @override
  void onAdClicked() {
    debugPrint('PhotoCaptureInterstitialAdCallback onAdClicked');
    // TODO: implement onAdClicked
  }

  @override
  void onAdClosed() {
    debugPrint('PhotoCaptureInterstitialAdCallback onAdClosed');
    // TODO: implement onAdClosed
  }

  @override
  void onAdFailedToLoad(AdError error) {
    // TODO: implement onAdFailedToLoad
  }

  @override
  void onAdLoaded() {
    debugPrint('PhotoCaptureInterstitialAdCallback onAdLoaded');
    onAdLoadedCallback();
  }

  @override
  void onAdShown() {
    debugPrint('PhotoCaptureInterstitialAdCallback onAdShown');
    // TODO: implement onAdShown
  }

  @override
  void onInterstitialAdLoaded(InterstitialAd ad) {
    // TODO: implement onInterstitialAdLoaded
    ad.show();
  }

  @override
  void onRewardedAdLoaded(RewardedAd ad) {
    debugPrint('PhotoCaptureInterstitialAdCallback onRewardedAdLoaded');
    // TODO: implement onRewardedAdLoaded
  }

  @override
  void onRewardedAdUserEarnedReward(RewardItem reward) {
    debugPrint(
      'PhotoCaptureInterstitialAdCallback onRewardedAdUserEarnedReward',
    );
    // TODO: implement onRewardedAdUserEarnedReward
  }
}

class PhotoCapturePage extends StatefulWidget {
  const PhotoCapturePage({super.key});

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  final PhotoService _photoService = PhotoService();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  UserBloc get userBloc => context.read<UserBloc>();
  bool _isLoading = false;
  final List<PhotoModel> _capturedPhotos = []; // 여러 장의 사진/비디오
  final bool _isVideoMode = false; // 동영상 모드 여부
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  final AdMaster _adMaster = AdMaster();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final String adUnitId = AdMaster().getAdUnitIdForType(
      AdType.banner,
      adMobUnitId: Platform.isIOS
          ? 'ca-app-pub-4656262305566191/4143764337'
          : 'ca-app-pub-4656262305566191/3488910792',
    );
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded');
          if (!mounted) return;
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
        onAdOpened: (ad) {
          debugPrint('BannerAd opened');
        },
        onAdClosed: (ad) {
          debugPrint('BannerAd closed');
        },
        onAdClicked: (ad) {
          debugPrint('BannerAd clicked');
        },
        onAdImpression: (ad) {
          debugPrint('BannerAd impression');
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.photo.takePhoto.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: SizeConstants.getColumnSpacing(context)),
            Text(Tr.photo.processing.tr()),
          ],
        ),
      );
    }

    if (_capturedPhotos.isNotEmpty) {
      return buildPhotosPreview();
    }

    return buildCaptureOptions();
  }

  Widget buildCaptureOptions() {
    return Column(
      children: [
        // 사진/동영상 토글 (상단 고정)
        // Padding(
        //   padding: const EdgeInsets.all(24.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Theme.of(context).colorScheme.outline),
        //       borderRadius: BorderRadius.circular(50),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         buildModeToggleButton(
        //           icon: Icons.camera_alt,
        //           label: Tr.photo.title.tr(),
        //           isSelected: !_isVideoMode,
        //           onTap: () => setState(() => _isVideoMode = false),
        //         ),
        //         buildModeToggleButton(
        //           icon: Icons.videocam,
        //           label: Tr.video.title.tr(),
        //           isSelected: _isVideoMode,
        //           onTap: () => setState(() => _isVideoMode = true),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // 스크롤 가능한 컨텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 카메라 아이콘
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    _isVideoMode ? Icons.videocam : Icons.camera_alt,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 제목
                Text(
                  Tr.baby.onBoardingTitle.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 설명
                Text(
                  Tr.baby.cameraHintText.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                // 웹 플랫폼 안내
                if (kIsWeb) ...[
                  SizedBox(height: SizeConstants.getColumnSpacing(context)),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(
                          width: SizeConstants.getColumnSpacing(context),
                        ),
                        Expanded(
                          child: Text(
                            '웹에서는 파일 선택만 가능합니다',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: SizeConstants.getColumnSpacing(context)),

                // 촬영 버튼 (웹에서는 비활성화)
                if (!kIsWeb) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVideoMode ? captureVideo : capturePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVideoMode ? Icons.videocam : Icons.camera_alt,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              Tr.baby.cameraTitle.tr(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConstants.getColumnSpacing(context)),
                ],

                // 갤러리 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      final user = userBloc.state.user;
                      if (user == null) {
                        return;
                      }
                      pickFromGallery();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library),
                        SizedBox(
                          width: SizeConstants.getColumnSpacing(context),
                        ),
                        Flexible(
                          child: Text(
                            Tr.baby.galleryTitle.tr(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 하단 여백
                SizedBox(height: SizeConstants.getColumnSpacing(context)),
              ],
            ),
          ),
        ),
        if (_isBannerAdLoaded) ...[
          Center(
            child: SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
          SizedBox(height: SizeConstants.getColumnSpacing(context)),
          SizedBox(height: SizeConstants.getColumnSpacing(context)),
        ],
      ],
    );
  }

  Widget buildModeToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPhotosPreview() {
    return Column(
      children: [
        // 헤더: 선택된 개수 표시
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '${_capturedPhotos.length}개 선택됨',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _capturedPhotos.clear();
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('전체 삭제'),
              ),
            ],
          ),
        ),

        // 그리드로 미디어 목록 표시
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _capturedPhotos.length,
            itemBuilder: (context, index) {
              final photo = _capturedPhotos[index];
              return buildMediaThumbnail(photo, index);
            },
          ),
        ),

        // 하단 액션 버튼들
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _isVideoMode ? pickVideoFromGallery() : pickFromGallery();
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('더 추가'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => saveAllPhotos(userBloc.state.user!),
                  icon: const Icon(Icons.cloud_upload),
                  label: Text('${_capturedPhotos.length}개 업로드'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMediaThumbnail(PhotoModel photo, int index) {
    final isVideo = photo.isVideo;

    return Stack(
      children: [
        Container(
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
            child: isVideo
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.filePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.file(File(photo.filePath), fit: BoxFit.cover),
          ),
        ),
        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _capturedPhotos.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        // 파일 크기 표시
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formatFileSize(photo.fileSize),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> capturePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await _photoService.capturePhoto();
      if (photo != null) {
        setState(() {
          _capturedPhotos.add(photo);
        });
      } else {
        showSnackBar(Tr.photo.photoTakenCancel.tr());
      }
    } catch (e) {
      showSnackBar(
        Tr.photo.photoTakenError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 여러 장 선택 가능
      final photos = await _photoService.pickMultipleMediasFromGallery();
      if (photos != null && photos.isNotEmpty) {
        setState(() {
          _capturedPhotos.addAll(photos);
        });
        showSnackBar('${photos.length}장의 사진이 선택되었습니다');
      } else {
        showSnackBar(Tr.photo.photoSelectCancel.tr());
      }
    } catch (e) {
      showSnackBar(
        Tr.photo.photoSelectError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> captureVideo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final video = await _photoService.captureVideo();
      if (video != null) {
        setState(() {
          _capturedPhotos.add(video);
        });
      } else {
        showSnackBar(Tr.video.videoTakenCancel.tr());
      }
    } catch (e) {
      showSnackBar(
        Tr.video.videoTakenError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickVideoFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final video = await _photoService.pickVideoFromGallery();
      if (video != null) {
        setState(() {
          _capturedPhotos.add(video);
        });
      } else {
        showSnackBar(Tr.video.videoSelectCancel.tr());
      }
    } catch (e) {
      showSnackBar(
        Tr.video.videoSelectError.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveAllPhotos(User user) async {
    if (_capturedPhotos.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_capturedPhotos.length > 5) {
        throw Exception('최대 5개의 파일만 업로드할 수 있습니다.');
      }

      debugPrint(
        'uploaded files: ${_capturedPhotos.map((photo) => photo.filePath).toList().join(',')}',
      );

      showSnackBar('${_capturedPhotos.length}개 파일 업로드 시작');

      // 백그라운드에서 업로드가 진행되는 동안 페이지를 닫음
      _adMaster.createInterstitialAd(
        adUnitId: Platform.isIOS
            ? 'ca-app-pub-4656262305566191/5748242622'
            : 'ca-app-pub-4656262305566191/5146333745',
        callback: PhotoCaptureInterstitialAdCallback(
          onAdLoadedCallback: () {
            s3ObjectBloc.add(
              S3ObjectEvent.uploadFiles(
                _capturedPhotos.map((photo) => File(photo.filePath)).toList(),
                user,
              ),
            );
            if (mounted) {
              _capturedPhotos.clear();
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
    } catch (e) {
      showSnackBar('업로드 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
