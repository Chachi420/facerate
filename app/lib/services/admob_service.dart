import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdMobService {
  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static bool _rewardedAdLoading = false;
  static bool _interstitialAdLoading = false;
  static bool _interstitialShowing = false;

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

  /// Shows a full-screen interstitial if one is loaded, then invokes
  /// [onDismissed]. If no ad is ready (or one is already showing), [onDismissed]
  /// fires immediately so callers can navigate without waiting.
  static Future<void> showInterstitialAd({void Function()? onDismissed}) async {
    final ad = _interstitialAd;
    if (ad == null || _interstitialShowing) {
      onDismissed?.call();
      return;
    }
    _interstitialShowing = true;

    void cleanup(InterstitialAd shownAd) {
      shownAd.dispose();
      _interstitialAd = null;
      _interstitialShowing = false;
      loadInterstitialAd(); // preload the next one
      onDismissed?.call();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: cleanup,
      onAdFailedToShowFullScreenContent: (shownAd, _) => cleanup(shownAd),
    );

    await ad.show();
  }
}
