import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/repositories/app_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.studentProfile,
        showBackButton: false,
      ),
      body: studentAsync.when(
        data: (student) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Student Profile Card
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(22),
                  surfaceColor: AppColors.primaryTeal,
                  isDark: true,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldenOrange,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            student.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDarkest,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        student.name,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.program,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          'ID: ${student.registrationNo} • Batch: ${student.batchCode}',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GlassButton(
                        text: AppStrings.downloadIdCard,
                        variant: GlassButtonVariant.glass,
                        height: 44,
                        leadingIcon: Icons.badge_outlined,
                        onPressed: () {
                          _showIdCardPreview(context, student);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal & Academic Details Section
                const SectionHeader(title: 'Academic Profile'),
                const SizedBox(height: 8),
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildProfileInfoRow(
                          Icons.email_outlined, 'Email Address', student.email),
                      const Divider(height: 20),
                      _buildProfileInfoRow(
                          Icons.phone_outlined, 'Phone Number', student.phone),
                      const Divider(height: 20),
                      _buildProfileInfoRow(Icons.calendar_today_outlined,
                          'Admission Date', student.enrolledDate),
                      const Divider(height: 20),
                      _buildProfileInfoRow(
                          Icons.verified_outlined,
                          'Overall Attendance',
                          '${student.overallAttendance}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // App Settings & Preferences
                const SectionHeader(title: 'Preferences'),
                const SizedBox(height: 8),
                GlassCard(
                  borderRadius: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Push Notifications',
                          style:
                              AppTypography.titleMedium.copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Alerts for live classes and exams',
                          style: AppTypography.labelSmall,
                        ),
                        activeThumbColor: AppColors.primaryTeal,
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Biometric Quick Login',
                          style:
                              AppTypography.titleMedium.copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Use Fingerprint / Face ID to unlock',
                          style: AppTypography.labelSmall,
                        ),
                        activeThumbColor: AppColors.primaryTeal,
                        value: _biometricsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _biometricsEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Support & FAQs
                const SectionHeader(title: 'Support & Institute Contact'),
                const SizedBox(height: 8),
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline_rounded,
                            color: AppColors.primaryTeal),
                        title: Text('Frequently Asked Questions (FAQ)',
                            style: AppTypography.titleMedium
                                .copyWith(fontSize: 13.5)),
                        trailing:
                            const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent_rounded,
                            color: AppColors.primaryTeal),
                        title: Text('Contact Student Support Helpline',
                            style: AppTypography.titleMedium
                                .copyWith(fontSize: 13.5)),
                        trailing:
                            const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Helpline: info@ajayinfotech.in | +91 98765 43210'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Logout Button
                GlassButton(
                  text: AppStrings.logOut,
                  variant: GlassButtonVariant.outline,
                  leadingIcon: Icons.logout_rounded,
                  height: 50,
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryTeal),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelSmall),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showIdCardPreview(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AJAY INFOTECH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'STUDENT PASS',
                      style: TextStyle(
                        color: AppColors.goldenOrange,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldenOrange,
                  ),
                  child: Center(
                    child: Text(
                      student.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  student.program,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('STUDENT ID',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9)),
                          Text(student.registrationNo,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('BATCH',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9)),
                          Text(student.batchCode,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  text: 'Download ID Card (PDF)',
                  variant: GlassButtonVariant.accent,
                  height: 44,
                  leadingIcon: Icons.cloud_download_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID Card saved to device.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Logout'),
          content: const Text(
              'Are you sure you want to log out of your learning portal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child:
                  const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
