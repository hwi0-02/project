import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// 앱 다이얼로그 유틸리티 - 프리미엄 디자인
class AppDialogs {
  AppDialogs._();

  /// 기본 확인 다이얼로그
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ModernDialog(
        title: title,
        content: Text(
          message,
          style: AppTheme.textStyles.body.copyWith(
            color: AppTheme.neutral600,
            height: 1.5,
          ),
        ),
        actions: [
          _DialogButton(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
            isOutlined: true,
          ),
          _DialogButton(
            text: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
            color: confirmColor ?? (isDangerous ? AppTheme.error : AppTheme.primary),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 가챠 확인 다이얼로그
  static Future<bool> showGachaConfirmDialog({
    required BuildContext context,
    required int cost,
    required int currentCoins,
  }) async {
    final canAfford = currentCoins >= cost;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => _ModernDialog(
        icon: Icons.auto_awesome_rounded,
        iconColor: AppTheme.primary,
        title: '가챠 뽑기',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '가챠를 뽑으시겠어요?',
              style: AppTheme.textStyles.body.copyWith(
                color: AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            // 비용 카드
            _InfoCard(
              icon: Icons.monetization_on_rounded,
              iconColor: AppColors.coinGold,
              label: '비용',
              value: '$cost 코인',
              valueColor: AppColors.coinGold,
            ),
            const SizedBox(height: AppTheme.spacing12),
            // 보유/잔액 정보
            _InfoRow(
              label: '보유 코인',
              value: '$currentCoins',
              valueColor: canAfford ? AppTheme.success : AppTheme.error,
            ),
            const SizedBox(height: AppTheme.spacing4),
            _InfoRow(
              label: '뽑기 후 잔액',
              value: '${currentCoins - cost}',
              valueColor: canAfford ? AppTheme.neutral700 : AppTheme.error,
            ),
          ],
        ),
        actions: [
          _DialogButton(
            text: '취소',
            onPressed: () => Navigator.of(context).pop(false),
            isOutlined: true,
          ),
          _DialogButton(
            text: '뽑기',
            onPressed: canAfford ? () => Navigator.of(context).pop(true) : null,
            color: AppTheme.primary,
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  /// 성공 다이얼로그
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ResultDialog(
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
        title: title,
        message: message,
        buttonText: '확인',
        buttonColor: AppTheme.success,
        onPressed: () {
          Navigator.of(context).pop();
          onClose?.call();
        },
      ),
    );
  }

  /// 에러 다이얼로그
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ResultDialog(
        icon: Icons.error_outline_rounded,
        iconColor: AppTheme.error,
        title: title,
        message: message,
        buttonText: '확인',
        buttonColor: AppTheme.error,
        onPressed: () {
          Navigator.of(context).pop();
          onClose?.call();
        },
      ),
    );
  }

  /// 정보 다이얼로그
  static void showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    Color iconColor = const Color(0xFF5B67CA),
  }) {
    showDialog(
      context: context,
      builder: (context) => _ResultDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        buttonText: '확인',
        buttonColor: iconColor,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// 로딩 다이얼로그
  static void showLoadingDialog({
    required BuildContext context,
    String message = '처리 중...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                Text(
                  message,
                  style: AppTheme.textStyles.body.copyWith(
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 선택 다이얼로그
  static Future<T?> showChoiceDialog<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<ChoiceOption<T>> options,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (context) => _ModernDialog(
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message != null) ...[
              Text(
                message,
                style: AppTheme.textStyles.body.copyWith(
                  color: AppTheme.neutral600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],
            ...options.map((option) => _ChoiceItem<T>(
              option: option,
              onTap: () => Navigator.of(context).pop(option.value),
            )),
          ],
        ),
        actions: [],
      ),
    );
  }
}

/// 모던 다이얼로그 베이스
class _ModernDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final Widget content;
  final List<Widget> actions;
  
  const _ModernDialog({
    this.icon,
    this.iconColor,
    required this.title,
    required this.content,
    required this.actions,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.textStyles.title.copyWith(
                      color: AppTheme.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // 컨텐츠
            content,
            
            // 액션 버튼
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: actions.expand((action) => [
                  Expanded(child: action),
                  if (action != actions.last) const SizedBox(width: AppTheme.spacing12),
                ]).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 결과 다이얼로그 (성공/에러/정보)
class _ResultDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;
  
  const _ResultDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // 타이틀
            Text(
              title,
              style: AppTheme.textStyles.title.copyWith(
                color: AppTheme.neutral900,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing12),
            
            // 메시지
            Text(
              message,
              style: AppTheme.textStyles.body.copyWith(
                color: AppTheme.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),
            
            // 버튼
            SizedBox(
              width: double.infinity,
              child: _DialogButton(
                text: buttonText,
                onPressed: onPressed,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다이얼로그 버튼
class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isOutlined;
  
  const _DialogButton({
    required this.text,
    this.onPressed,
    this.color,
    this.isOutlined = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primary;
    final isDisabled = onPressed == null;
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.neutral700,
          side: BorderSide(color: AppTheme.neutral300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: Text(
          text,
          style: AppTheme.textStyles.label.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppTheme.neutral300 : buttonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing20,
          vertical: AppTheme.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      child: Text(
        text,
        style: AppTheme.textStyles.label.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 정보 카드
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: AppTheme.textStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral700,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTheme.textStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.neutral800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 행
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.textStyles.caption.copyWith(
            color: AppTheme.neutral500,
          ),
        ),
        Text(
          value,
          style: AppTheme.textStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.neutral700,
          ),
        ),
      ],
    );
  }
}

/// 선택지 아이템
class _ChoiceItem<T> extends StatelessWidget {
  final ChoiceOption<T> option;
  final VoidCallback onTap;
  
  const _ChoiceItem({
    required this.option,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = option.color ?? AppTheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      option.icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: AppTheme.textStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      if (option.description != null) ...[
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          option.description!,
                          style: AppTheme.textStyles.caption.copyWith(
                            color: AppTheme.neutral500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 선택지 옵션 클래스
class ChoiceOption<T> {
  final T value;
  final String title;
  final String? description;
  final IconData? icon;
  final Color? color;

  const ChoiceOption({
    required this.value,
    required this.title,
    this.description,
    this.icon,
    this.color,
  });
}
