import 'package:flutter_common/widgets/ad/ad_master.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AdError;

class InterstitialAdCallback extends AdCallback {
  @override
  void onAdClicked() {
    // TODO: implement onAdClicked
  }

  @override
  void onAdClosed() {
    // TODO: implement onAdClosed
  }

  @override
  void onAdFailedToLoad(AdError error) {
    // TODO: implement onAdFailedToLoad
  }

  @override
  void onAdLoaded() {
    // TODO: implement onAdLoaded
  }

  @override
  void onAdShown() {
    // TODO: implement onAdShown
  }

  @override
  void onInterstitialAdLoaded(InterstitialAd ad) {
    // TODO: implement onInterstitialAdLoaded
    ad.show();
  }

  @override
  void onRewardedAdLoaded(RewardedAd ad) {
    // TODO: implement onRewardedAdLoaded
  }

  @override
  void onRewardedAdUserEarnedReward(RewardItem reward) {
    // TODO: implement onRewardedAdUserEarnedReward
  }
}
