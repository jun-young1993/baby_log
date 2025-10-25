import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/widgets/ad/ad_master.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 네이티브 광고를 모달 바텀시트로 표시하는 재사용 가능한 위젯
class NativeAdModalWidget {
  /// 네이티브 광고를 모달 바텀시트로 표시
  ///
  /// [context] - BuildContext
  /// [adUnitId] - 광고 단위 ID (선택사항, 없으면 기본값 사용)
  /// [factoryId] - 광고 팩토리 ID (기본값: 'listTile')
  static Future<void> showNativeAdModal({
    required BuildContext context,
    String? adUnitId,
    String factoryId = 'listTile',
  }) async {
    // 광고 단위 ID가 없으면 기본값 사용
    final finalAdUnitId =
        adUnitId ??
        AdMaster().getAdUnitIdForType(
          AdType.native,
          adMobUnitId: Platform.isIOS
              ? 'ca-app-pub-4656262305566191/2883468229'
              : 'ca-app-pub-4656262305566191/7647682074',
        );

    // 네이티브 광고 로드
    final nativeAd = NativeAd(
      adUnitId: finalAdUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          // 광고 로드 성공 시 모달 표시
          _showModal(context, ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native ad failed to load: $error');
        },
        onAdClicked: (ad) => debugPrint('Native ad clicked.'),
        onAdImpression: (ad) => debugPrint('Native ad impression.'),
        onAdClosed: (ad) {
          ad.dispose();
          debugPrint('Native ad closed.');
        },
        onAdOpened: (ad) => debugPrint('Native ad opened.'),
      ),
    );

    // 광고 로드 시작
    nativeAd.load();
  }

  /// 모달 바텀시트 표시
  static void _showModal(BuildContext context, NativeAd ad) {
    // 안전한 모달 표시를 위해 try-catch 추가
    try {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 광고 컨테이너 - 더 안전한 크기 설정
            Container(
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AdWidget(ad: ad),
              ),
            ),
            const SizedBox(height: 20),
            // 닫기 버튼 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(Tr.common.close.tr()),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Native ad modal error: $e');
      // 에러 발생 시 광고 정리
      ad.dispose();
    }
  }
}

/// 네이티브 광고 모달을 쉽게 호출할 수 있는 헬퍼 클래스
class NativeAdModalHelper {
  /// 현재 컨텍스트에서 네이티브 광고 모달 표시
  static Future<void> showAd({
    required BuildContext context,
    String? adUnitId,
    String factoryId = 'listTile',
  }) {
    return NativeAdModalWidget.showNativeAdModal(
      context: context,
      adUnitId: adUnitId,
      factoryId: factoryId,
    );
  }
}
