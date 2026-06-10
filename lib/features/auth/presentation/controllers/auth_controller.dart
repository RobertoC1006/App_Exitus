import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Estados de Autenticación
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// Controller de Autenticación usando Notifier moderno
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Inicializar la verificación de sesión en segundo plano
    Future.microtask(() => checkSession());
    return const AuthInitial();
  }

  Future<void> checkSession() async {
    state = const AuthLoading();
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AuthLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(username, password);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '');
      state = AuthError(errMsg);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AuthUnauthenticated();
  }
}

// Providers de Riverpod (Manuales, sin generadores)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class ActiveRoleNotifier extends Notifier<String> {
  @override
  String build() {
    final authState = ref.watch(authControllerProvider);
    if (authState is AuthAuthenticated) {
      return authState.user.role;
    }
    return 'student';
  }

  void setRole(String newRole) {
    state = newRole;
  }
}

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, String>(() {
  return ActiveRoleNotifier();
});

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void changeIndex(int index) {
    state = index;
  }
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(() {
  return NavigationIndexNotifier();
});
