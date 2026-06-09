import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<void> updateActiveRole(String newRole) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final updatedUser = User(
        id: currentState.user.id,
        username: currentState.user.username,
        fullName: currentState.user.fullName,
        email: currentState.user.email,
        role: newRole,
        avatarUrl: currentState.user.avatarUrl,
        subjects: currentState.user.subjects,
      );
      
      const storage = FlutterSecureStorage();
      await storage.write(key: 'user_data', value: jsonEncode(updatedUser.toJson()));
      
      state = AuthAuthenticated(updatedUser);
    }
  }
}

// Providers de Riverpod (Manuales, sin generadores)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
