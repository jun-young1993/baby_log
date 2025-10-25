import 'package:flutter/material.dart';
import 'package:flutter_common/widgets/ad/ad_master.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Native ad widget that loads asynchronously
/// Shows loading state until ad is ready
class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final double? height;

  const NativeAdWidget({super.key, required this.adUnitId, this.height});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget>
    with AutomaticKeepAliveClientMixin<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  final AdMaster _adMaster = AdMaster();

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      final finalAdUnitId = AdMaster().getAdUnitIdForType(
        AdType.native,
        adMobUnitId: widget.adUnitId,
      );
      _nativeAd = NativeAd(
        adUnitId: finalAdUnitId,
        factoryId: 'listTile',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('광고 로드 실패: $error');
            setState(() {
              _isAdFailed = true;
              _isAdLoaded = false;
            });
          },
        ),
        request: const AdRequest(),
      );
      await _nativeAd?.load();
    } catch (e) {
      debugPrint('광고 로드 실패: $e');
      if (mounted) {
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
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 광고 로딩 실패 시 빈 공간 표시 (에러 숨김)
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    // 광고 로딩 중
    if (!_isAdLoaded || _nativeAd == null) {
      return _buildLoading(context);
    }

    // 광고 표시 (안전성 체크 추가)
    if (_nativeAd != null && _isAdLoaded) {
      debugPrint('광고 표시: ${widget.height}');
      return Container(
        constraints: BoxConstraints(
          minHeight: widget.height ?? 140,
          maxHeight: widget.height ?? 140,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    } else {
      return _buildLoading(context);
    }
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      height: widget.height ?? 140, // 텍스트가 잘리지 않도록 높이 증가
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
