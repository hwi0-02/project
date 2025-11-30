import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../constants/constants.dart';

/// 배너 광고 위젯
/// 
/// 프리미엄 사용자는 광고가 표시되지 않음
/// 광고 로딩 중에는 깔끔한 플레이스홀더 표시
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
      // 광고 로딩 중 플레이스홀더 - 새 디자인 시스템 적용
      return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.neutral100,
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(color: AppTheme.neutral200),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neutral400),
                ),
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                '광고 로딩 중...',
                style: TextStyle(
                  color: AppTheme.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        boxShadow: AppTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }
}
