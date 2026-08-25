import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/admin_login_screen.dart';
import '../../features/shell/admin_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/students/presentation/students_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/batches/presentation/batches_screen.dart';
import '../../features/batches/presentation/batch_detail_screen.dart';
import '../../features/courses/presentation/courses_screen.dart';
import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/leave/presentation/leave_requests_screen.dart';
import '../../features/fees/presentation/fees_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/announcements/presentation/announcements_screen.dart';
import '../../features/assignments/presentation/assignments_screen.dart';
import '../../features/faculty/presentation/faculty_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/admin_mgmt/presentation/admin_management_screen.dart';
import '../auth/auth_provider.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/dashboard',
              builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/students',
              builder: (_, __) => const StudentsScreen()),
          GoRoute(
            path: '/students/:id',
            builder: (_, state) =>
                StudentDetailScreen(studentId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/batches',
              builder: (_, __) => const BatchesScreen()),
          GoRoute(
            path: '/batches/:id',
            builder: (_, state) =>
                BatchDetailScreen(batchId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/courses',
              builder: (_, __) => const CoursesScreen()),
          GoRoute(
            path: '/courses/:id',
            builder: (_, state) =>
                CourseDetailScreen(courseId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/attendance',
              builder: (_, __) => const AttendanceScreen()),
          GoRoute(path: '/leave-requests',
              builder: (_, __) => const LeaveRequestsScreen()),
          GoRoute(path: '/fees',
              builder: (_, __) => const FeesScreen()),
          GoRoute(path: '/payments',
              builder: (_, __) => const PaymentsScreen()),
          GoRoute(path: '/announcements',
              builder: (_, __) => const AnnouncementsScreen()),
          GoRoute(path: '/assignments',
              builder: (_, __) => const AssignmentsScreen()),
          GoRoute(path: '/faculty',
              builder: (_, __) => const FacultyScreen()),
          GoRoute(path: '/reports',
              builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/notifications',
              builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/settings',
              builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/admin-management',
              builder: (_, __) => const AdminManagementScreen()),
        ],
      ),
    ],
  );
});
