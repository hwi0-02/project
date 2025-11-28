import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

/// 광고 서비스
/// 
/// AdMob 배너 및 리워드 광고 관리
class AdService {
  static const int _rewardedAdThreshold = 3; // 3회차부터 리워드 광고

  // TODO: 실제 광고 ID로 교체
  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // 테스트 ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // 테스트 ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// 광고 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// 배너 광고 로드
  Future<void> loadBannerAd() async {
    if (!_isInitialized) await initialize();

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// 리워드 광고 로드
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) await initialize();

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// 리워드 광고 표시
  /// 
  /// Returns: 광고 시청 완료 여부
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        completer.complete(true);
      },
    );

    return completer.future;
  }

  /// 재뽑기 시 광고 필요 여부 확인
  bool shouldShowRewardedAd(int reDrawCount, bool isPremium) {
    if (isPremium) return false;
    return reDrawCount >= _rewardedAdThreshold;
  }

  /// 배너 광고 dispose
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// 전체 리소스 정리
  void dispose() {
    disposeBannerAd();
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
