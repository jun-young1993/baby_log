import 'package:flutter/material.dart';
import 'package:flutter_common/widgets/ad/ad_master.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Native ad widget that loads asynchronously
/// Shows loading state until ad is ready
class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final double? height;

  const NativeAdWidget({super.key, required this.adUnitId, this.height});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _isDisposed = false;
  final AdMaster _adMaster = AdMaster();

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isDisposed) return;

    try {
      debugPrint('광고 로딩 시작: ${widget.adUnitId}');

      final ad = await _adMaster.createNativeAd(
        adUnitId: widget.adUnitId,
        factoryId: 'listTile',
      );

      if (_isDisposed) {
        ad?.dispose();
        return;
      }

      if (ad != null) {
        debugPrint('광고 로딩 성공: ${widget.adUnitId}');
        if (mounted) {
          setState(() {
            _nativeAd = ad;
            _isAdLoaded = true;
            _isAdFailed = false;
          });
        }
      } else {
        debugPrint('광고 로딩 실패: ad is null');
        if (mounted) {
          setState(() {
            _isAdFailed = true;
            _isAdLoaded = false;
          });
        }
      }
    } catch (e) {
      debugPrint('광고 로드 실패: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isAdFailed = true;
          _isAdLoaded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('NativeAdWidget dispose');
    _isDisposed = true;
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고 로딩 실패 시 빈 공간 표시 (에러 숨김)
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    // 광고 로딩 중
    if (!_isAdLoaded || _nativeAd == null) {
      return _buildLoading(context);
    }

    // 광고 표시 (안전성 체크 추가)
    if (_nativeAd != null && !_isDisposed) {
      return Container(
        height: widget.height ?? 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      return _buildLoading(context);
    }
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      height: widget.height ?? 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.onSurface,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
