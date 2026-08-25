import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? surfaceColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.surfaceColor,
    this.borderColor,
    this.onTap,
    this.width,
    this.height,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurface = surfaceColor ??
        (isDark ? AppColors.glassSurfaceDark : AppColors.glassSurface);
    final effectiveBorder = borderColor ??
        (isDark ? AppColors.glassBorderDark : AppColors.glassBorder);

    return GlassContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      borderRadius: borderRadius,
      blur: 10.0,
      surfaceColor: effectiveSurface,
      borderColor: effectiveBorder,
      borderWidth: 1.0,
      onTap: onTap,
      child: child,
    );
  }
}
