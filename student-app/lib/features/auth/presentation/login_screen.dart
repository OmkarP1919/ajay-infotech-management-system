import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(text: 'AI-2026-8842');
  final _passwordController = TextEditingController(text: 'student@123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  int _selectedTab = 0; // 0: Student ID, 1: Email, 2: OTP

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      studentIdOrEmail: _idController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient shapes
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTeal.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldenOrange.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Brand
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        AppStrings.welcomeBack,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 28,
                          color: AppColors.primaryDarkest,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.signInSubtitle,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Glass Card Form Container
                      GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tab Selector
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  _buildTabItem(0, 'Student ID'),
                                  _buildTabItem(1, 'Email'),
                                  _buildTabItem(2, 'Phone OTP'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Error banner if any
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authState.errorMessage!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Identifier Field
                            Text(
                              _selectedTab == 1
                                  ? AppStrings.emailLabel
                                  : (_selectedTab == 2
                                      ? 'Mobile Phone Number'
                                      : AppStrings.studentIdLabel),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _idController,
                              decoration: InputDecoration(
                                hintText: _selectedTab == 1
                                    ? 'student@ajayinfotech.in'
                                    : (_selectedTab == 2
                                        ? '+91 98765 43210'
                                        : 'e.g. AI-2026-8842'),
                                prefixIcon: Icon(
                                  _selectedTab == 1
                                      ? Icons.email_outlined
                                      : (_selectedTab == 2
                                          ? Icons.phone_outlined
                                          : Icons.badge_outlined),
                                  size: 20,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Password / OTP Field
                            Text(
                              _selectedTab == 2
                                  ? '4-Digit OTP'
                                  : AppStrings.passwordLabel,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText:
                                  _selectedTab != 2 && _obscurePassword,
                              keyboardType: _selectedTab == 2
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                hintText: _selectedTab == 2
                                    ? 'Enter received OTP'
                                    : '••••••••••••',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20,
                                  color: AppColors.primaryTeal,
                                ),
                                suffixIcon: _selectedTab == 2
                                    ? TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Get OTP',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Remember Me & Forgot Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: AppColors.primaryTeal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.rememberMe,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password reset link sent to registered email.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.forgotPassword,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryTeal,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Sign In Button
                            GlassButton(
                              text: AppStrings.signInButton,
                              variant: GlassButtonVariant.primary,
                              isLoading: isLoading,
                              height: 52,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Help & Support Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.needHelp,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Support helpline: +91 98765 43210 (9AM-7PM)',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              AppStrings.contactSupport,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            if (index == 0) {
              _idController.text = 'AI-2026-8842';
            } else if (index == 1) {
              _idController.text = 'rohit.sharma@ajayinfotech.in';
            } else {
              _idController.text = '+91 98765 43210';
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryTeal.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color:
                  isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
