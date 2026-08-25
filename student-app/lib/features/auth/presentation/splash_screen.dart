import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching Stitch design (#0F3F47 -> #071E23)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F3F47),
                  Color(0xFF0A2B31),
                  Color(0xFF071E23),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Ambient Glow effects
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldenOrange.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTeal.withOpacity(0.4),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                const Spacer(),

                                // Institute Emblem & Branding Card
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.goldenOrange,
                                        Color(0xFFFFC043),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.goldenOrange
                                            .withOpacity(0.35),
                                        blurRadius: 32,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'AI',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryDarkest,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Brand Title
                                Text(
                                  AppStrings.appName.toUpperCase(),
                                  style: AppTypography.displayLarge.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 30,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  AppStrings.appTagline,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),

                                // ISO Certification Glass Badge
                                GlassContainer(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  borderRadius: 30,
                                  blur: 8,
                                  surfaceColor: Colors.white.withOpacity(0.12),
                                  borderColor: Colors.white.withOpacity(0.25),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: AppColors.goldenOrange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppStrings.isoCertification,
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // Get Started Action Button
                                GlassButton(
                                  text: AppStrings.getStarted,
                                  variant: GlassButtonVariant.accent,
                                  trailingIcon: Icons.arrow_forward_rounded,
                                  height: 56,
                                  borderRadius: 18,
                                  width: double.infinity,
                                  onPressed: () {
                                    context.go('/login');
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Already Enrolled Link
                                TextButton(
                                  onPressed: () {
                                    context.go('/login');
                                  },
                                  child: Text(
                                    AppStrings.alreadyEnrolled,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
