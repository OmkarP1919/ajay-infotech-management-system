import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/courses/presentation/courses_list_screen.dart';
import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/batches/presentation/batches_screen.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/fees/presentation/fees_screen.dart';
import '../../features/announcements/presentation/announcements_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash Route
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Login Route
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Shell Route with Persistent Bottom Navigation Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: CustomBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        );
      },
      branches: [
        // Branch 0: Dashboard (Home)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Branch 1: Courses
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/courses',
              builder: (context, state) => const CoursesListScreen(),
            ),
          ],
        ),

        // Branch 2: Batches
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/batches',
              builder: (context, state) => const BatchesScreen(),
            ),
          ],
        ),

        // Branch 3: Attendance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/attendance',
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),

        // Branch 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Direct Detail Routes
    GoRoute(
      path: '/course-detail/:courseId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final courseId = state.pathParameters['courseId'] ?? 'crs_01';
        return CourseDetailScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/fees',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FeesScreen(),
    ),
    GoRoute(
      path: '/announcements',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AnnouncementsScreen(),
    ),
  ],
);
