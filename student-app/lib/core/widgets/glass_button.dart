import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_container.dart';

enum GlassButtonVariant { primary, accent, glass, outline }

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final GlassButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 52.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    Gradient? gradient;

    switch (variant) {
      case GlassButtonVariant.primary:
        backgroundColor = AppColors.primaryTeal;
        textColor = Colors.white;
        borderColor = AppColors.primaryTeal;
        gradient = AppColors.primaryGradient;
        break;
      case GlassButtonVariant.accent:
        backgroundColor = AppColors.goldenOrange;
        textColor = AppColors.primaryDarkest;
        borderColor = AppColors.goldenOrange;
        gradient = AppColors.accentGradient;
        break;
      case GlassButtonVariant.glass:
        backgroundColor = Colors.white.withOpacity(0.2);
        textColor = Colors.white;
        borderColor = Colors.white.withOpacity(0.4);
        break;
      case GlassButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primaryTeal;
        borderColor = AppColors.outlineVariant;
        break;
    }

    Widget content = SizedBox(
      height: height,
      width: width,
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, color: textColor, size: 20),
                  ],
                ],
              ),
      ),
    );

    if (variant == GlassButtonVariant.glass) {
      return GlassContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        surfaceColor: backgroundColor,
        borderColor: borderColor,
        padding: EdgeInsets.zero,
        onTap: isLoading ? null : onPressed,
        child: content,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: variant == GlassButtonVariant.primary ||
                variant == GlassButtonVariant.accent
            ? [
                BoxShadow(
                  color: (variant == GlassButtonVariant.accent
                          ? AppColors.goldenOrange
                          : AppColors.primaryTeal)
                      .withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      ),
    );
  }
}
