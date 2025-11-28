import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// 배너 광고 위젯
class BannerAdWidget extends StatefulWidget {
  final AdService adService;
  final bool isPremium;

  const BannerAdWidget({
    super.key,
    required this.adService,
    required this.isPremium,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    if (!widget.isPremium) {
      widget.adService.loadBannerAd();
    }
  }

  @override
  void dispose() {
    widget.adService.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 프리미엄 유저는 광고 숨김
    if (widget.isPremium) {
      return const SizedBox.shrink();
    }

    final bannerAd = widget.adService.bannerAd;
    if (bannerAd == null || !widget.adService.isBannerAdLoaded) {
      // 광고 로딩 중 플레이스홀더
      return Container(
        height: 50,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'Ad',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
