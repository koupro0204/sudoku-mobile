import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  void loadRewardedAd(String adUnitId) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // ここに報酬を獲得したときの処理を書く
          print('Reward earned: ${reward.amount}');
        },
      );

      // リワード広告を再度表示するためには、もう一度ロードする必要がある
      _isRewardedAdReady = false;
      _rewardedAd = null;
    }
  }
}
