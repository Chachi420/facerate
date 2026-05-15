import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdMobService {
  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static bool _rewardedAdLoading = false;
  static bool _interstitialAdLoading = false;

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  static Future<void> loadRewardedAd() async {
    if (_rewardedAdLoading || _rewardedAd != null) return;
    _rewardedAdLoading = true;

    await RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAdLoading = false;
        },
      ),
    );
  }

  static Future<void> showRewardedAd({required void Function() onRewarded}) async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      await Future.delayed(const Duration(seconds: 2));
    }

    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) {
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) => onRewarded(),
    );
    _rewardedAd = null;
  }

  static Future<void> loadInterstitialAd() async {
    if (_interstitialAdLoading || _interstitialAd != null) return;
    _interstitialAdLoading = true;

    await InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAdLoading = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAdLoading = false;
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) {
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );

    await ad.show();
    _interstitialAd = null;
  }
}
