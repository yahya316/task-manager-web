import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/manager/manager_dashboard.dart';
import 'screens/manager/create_task_screen.dart';
import 'screens/manager/edit_task_screen.dart';
import 'screens/manager/task_detail_screen.dart';
import 'screens/manager/team_management_screen.dart';
import 'screens/manager/create_member_screen.dart';
import 'screens/manager/activity_screen.dart';
import 'screens/sales/sales_home_screen.dart';
import 'screens/sales/task_detail_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isInitializing = authProvider.isInitializing;
      final isLoggedIn = authProvider.isAuthenticated;
      final isSplashRoute = state.matchedLocation == '/splash';
      final isLoginRoute = state.matchedLocation == '/login';

      if (isInitializing && !isSplashRoute) {
        return '/splash';
      }

      if (isInitializing && isSplashRoute) {
        return null;
      }

      if (isSplashRoute) {
        if (!isLoggedIn) {
          return '/login';
        }

        if (authProvider.isManager) {
          return '/manager';
        }

        return '/sales';
      }

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        if (authProvider.isManager) {
          return '/manager';
        } else {
          return '/sales';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Manager routes
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerDashboard(),
      ),
      GoRoute(
        path: '/manager/create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: '/manager/edit-task/:id',
        builder: (context, state) =>
            EditTaskScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/manager/task/:id',
        builder: (context, state) =>
            ManagerTaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/manager/team',
        builder: (context, state) => const TeamManagementScreen(),
      ),
      GoRoute(
        path: '/manager/create-member',
        builder: (context, state) => const CreateMemberScreen(),
      ),
      GoRoute(
        path: '/manager/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      // Sales routes
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesHomeScreen(),
      ),
      GoRoute(
        path: '/sales/task/:id',
        builder: (context, state) =>
            SalesTaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
    ],
  );
}
