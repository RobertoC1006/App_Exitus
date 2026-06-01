import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<User> login(String username, String password) async {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.login,
      body: {"username": username, "password": "••••••••"},
    );

    // Simula retraso de red
    await Future.delayed(const Duration(milliseconds: 1500));

    final trimmedUser = username.trim();
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Por favor, completa todos los campos.');
    }

    final db = MockDatabase();
    // Buscar en la lista de usuarios de MockDatabase
    final userIndex = db.users.indexWhere(
      (u) => u.username.toLowerCase() == trimmedUser.toLowerCase(),
    );

    if (userIndex != -1) {
      final user = db.users[userIndex];
      final correctPassword = db.userPasswords[user.username];
      if (correctPassword == password) {
        // Guardar sesión en almacenamiento seguro
        await _storage.write(key: 'auth_token', value: 'mock_jwt_token_${user.id}');
        await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
        return user;
      }
    }

    throw Exception('Usuario o contraseña incorrectos.');
  }

  @override
  Future<User?> getCurrentUser() async {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.authMe,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<void> logout() async {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.logout,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }
}
