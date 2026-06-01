import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/main_navigation_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState is AuthAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      // Redirigir a login si no está autenticado
      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      // Redirigir al dashboard si ya está autenticado e intenta ir a login
      if (loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationShell(),
      ),
    ],
  );
});
