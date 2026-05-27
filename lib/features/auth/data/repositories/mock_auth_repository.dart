import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Datos mock del profesor de prueba
  final User _mockTeacher = const User(
    id: 'teacher_01',
    username: 'profesor123',
    fullName: 'Prof. Roberto Carlos',
    email: 'roberto.carlos@exitus.edu.pe',
    role: 'teacher',
    avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
    subjects: ['Matemática - 5to A', 'Matemática - 5to B', 'Física - 4to A'],
  );

  @override
  Future<User> login(String username, String password) async {
    // Simula retraso de red
    await Future.delayed(const Duration(milliseconds: 1500));

    if (username.trim() == 'profesor123' && password == '12345678') {
      // Guardar sesión en almacenamiento seguro
      await _storage.write(key: 'auth_token', value: 'mock_jwt_token_xyz');
      await _storage.write(key: 'user_data', value: jsonEncode(_mockTeacher.toJson()));
      return _mockTeacher;
    } else if (username.isEmpty || password.isEmpty) {
      throw Exception('Por favor, completa todos los campos.');
    } else {
      throw Exception('Usuario o contraseña incorrectos.');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }
}
