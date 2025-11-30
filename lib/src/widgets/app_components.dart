import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';

/// 앱 공용 UI 컴포넌트 라이브러리
/// 
/// 일관된 디자인 시스템을 위한 재사용 가능한 위젯들

// ============================================
// 버튼 사이즈 열거형
// ============================================

enum ButtonSize {
  small(horizontalPadding: 12, verticalPadding: 8, fontSize: 13, iconSize: 16),
  medium(horizontalPadding: 20, verticalPadding: 14, fontSize: 15, iconSize: 20),
  large(horizontalPadding: 24, verticalPadding: 18, fontSize: 16, iconSize: 22);

  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;

  const ButtonSize({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });
}

// ============================================
// 버튼 컴포넌트 (Buttons)
// ============================================

/// 프라이머리 버튼 (주요 액션용)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final EdgeInsets? padding;
  final ButtonSize size;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primary;
    final fgColor = foregroundColor ?? Colors.white;
    
    final buttonPadding = padding ?? EdgeInsets.symmetric(
      horizontal: size.horizontalPadding,
      vertical: size.verticalPadding,
    );

    final List<Widget> rowChildren = [];
    
    if (isLoading) {
      rowChildren.add(SizedBox(
        width: size.iconSize,
        height: size.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(fgColor),
        ),
      ));
      rowChildren.add(SizedBox(width: AppTheme.spacing8));
    } else if (icon != null) {
      rowChildren.add(Icon(icon, size: size.iconSize, color: fgColor));
      rowChildren.add(SizedBox(width: AppTheme.spacing8));
    }
    
    rowChildren.add(Text(
      label,
      style: TextStyle(
        fontSize: size.fontSize,
        fontWeight: FontWeight.w600,
        color: fgColor,
      ),
    ));

    Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowChildren,
    );

    return SizedBox(
      width: isExpanded ? double.infinity : width,
      child: Material(
        color: onPressed == null ? bgColor.withValues(alpha: 0.5) : bgColor,
        borderRadius: AppTheme.borderRadiusM,
        child: InkWell(
          onTap: isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          borderRadius: AppTheme.borderRadiusM,
          child: Container(
            padding: buttonPadding,
            decoration: BoxDecoration(
              borderRadius: AppTheme.borderRadiusM,
              boxShadow: onPressed != null ? AppTheme.primaryShadow(bgColor) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 세컨더리 버튼 (보조 액션용)
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;
  final Color? borderColor;
  final Color? foregroundColor;
  final ButtonSize size;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isExpanded = false,
    this.borderColor,
    this.foregroundColor,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final bdColor = borderColor ?? AppTheme.border;
    final fgColor = foregroundColor ?? AppTheme.textPrimary;

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed != null ? () {
          HapticFeedback.selectionClick();
          onPressed?.call();
        } : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(color: bdColor),
          padding: EdgeInsets.symmetric(
            horizontal: size.horizontalPadding,
            vertical: size.verticalPadding,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusM),
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: size.iconSize),
              SizedBox(width: AppTheme.spacing8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: size.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 텍스트 버튼
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = color ?? AppTheme.primary;
    
    return TextButton(
      onPressed: onPressed != null ? () {
        HapticFeedback.selectionClick();
        onPressed?.call();
      } : null,
      style: TextButton.styleFrom(foregroundColor: fgColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            SizedBox(width: AppTheme.spacing6),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 아이콘 버튼 (둥근)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.surfaceVariant;
    final icColor = iconColor ?? AppTheme.textPrimary;
    
    Widget button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed != null ? () {
          HapticFeedback.selectionClick();
          onPressed?.call();
        } : null,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: icColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

// ============================================
// 카드 컴포넌트 (Cards)
// ============================================

/// 기본 카드
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasBorder;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.hasBorder = true,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surface,
        borderRadius: AppTheme.borderRadiusL,
        border: hasBorder ? Border.all(color: AppTheme.borderLight) : null,
        boxShadow: hasShadow ? AppTheme.shadowMd : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppTheme.borderRadiusL,
        child: InkWell(
          onTap: onTap != null ? () {
            HapticFeedback.selectionClick();
            onTap?.call();
          } : null,
          borderRadius: AppTheme.borderRadiusL,
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppTheme.spacing16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 글래스모피즘 카드 (강조용)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? tintColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = tintColor ?? AppTheme.primary;
    
    return Container(
      padding: padding ?? EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppTheme.borderRadiusXL,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ============================================
// 뱃지 & 칩 (Badges & Chips)
// ============================================

/// 상태 뱃지
class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool isSmall;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.primary;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppTheme.spacing8 : AppTheme.spacing12,
        vertical: isSmall ? AppTheme.spacing4 : AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: AppTheme.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 16,
              color: badgeColor,
            ),
            SizedBox(width: AppTheme.spacing4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11.0 : 13.0,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 숫자 뱃지 (알림용)
class NumberBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const NumberBadge({
    super.key,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    
    final badgeColor = color ?? AppTheme.error;
    final displayText = count > 99 ? '99+' : count.toString();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? AppTheme.spacing6 : AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppTheme.borderRadiusFull,
      ),
      child: Center(
        child: Text(
          displayText,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ============================================
// 입력 필드 (Inputs)
// ============================================

/// 텍스트 입력 필드
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.labelMedium),
          SizedBox(height: AppTheme.spacing8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, size: 20, color: AppTheme.textTertiary)
              : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

// ============================================
// 프로그레스 & 로딩 (Progress)
// ============================================

/// 프로그레스 바
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 ~ 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showLabel;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppTheme.primary;
    final bgColor = backgroundColor ?? AppTheme.surfaceVariant;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showLabel) ...[
          Text(
            '${(value * 100).toInt()}%',
            style: AppTheme.labelSmall.copyWith(color: progressColor),
          ),
          SizedBox(height: AppTheme.spacing4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: AppTheme.durationNormal,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(color ?? AppTheme.primary),
      ),
    );
  }
}

// ============================================
// 구분선 (Dividers)
// ============================================

/// 텍스트가 있는 구분선
class AppDivider extends StatelessWidget {
  final String? text;
  final double? thickness;
  final EdgeInsets? margin;

  const AppDivider({
    super.key,
    this.text,
    this.thickness,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Padding(
        padding: margin ?? EdgeInsets.symmetric(vertical: AppTheme.spacing16),
        child: Divider(thickness: thickness ?? 1),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.symmetric(vertical: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: thickness ?? 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
            child: Text(text!, style: AppTheme.labelSmall),
          ),
          Expanded(child: Divider(thickness: thickness ?? 1)),
        ],
      ),
    );
  }
}

// ============================================
// 빈 상태 (Empty States)
// ============================================

/// 빈 상태 위젯
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(title, style: AppTheme.titleMedium, textAlign: TextAlign.center),
            if (description != null) ...[
              SizedBox(height: AppTheme.spacing8),
              Text(
                description!,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: AppTheme.spacing24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// 리스트 아이템 (List Items)
// ============================================

/// 설정 리스트 아이템
class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null ? () {
          HapticFeedback.selectionClick();
          onTap?.call();
        } : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadiusM,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppTheme.primary,
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyLarge),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTheme.bodySmall),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// 바텀 시트 핸들 (Bottom Sheet Handle)
// ============================================

/// 바텀시트 핸들
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: EdgeInsets.only(top: AppTheme.spacing12, bottom: AppTheme.spacing8),
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: AppTheme.borderRadiusFull,
      ),
    );
  }
}

// ============================================
// 섹션 헤더 (Section Header)
// ============================================

/// 섹션 헤더
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.titleMedium),
          if (actionText != null)
            AppTextButton(
              label: actionText!,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}
