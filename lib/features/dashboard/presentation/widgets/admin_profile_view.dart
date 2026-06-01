import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class AdminProfileView extends ConsumerWidget {
  final VoidCallback onRefreshRequested;
  const AdminProfileView({super.key, required this.onRefreshRequested});

  void _resetDatabase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.orange),
            SizedBox(width: 8),
            Text("Restablecer Sistema", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Esto reiniciará los datos de asistencia, calificaciones y usuarios creados durante esta sesión. ¿Deseas continuar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Restablecer base de datos volviendo a inicializar los datos base
              final db = MockDatabase();
              db.users.clear();
              db.users.addAll([
                const User(
                  id: 'teacher_01',
                  username: 'profesor123',
                  fullName: 'Prof. Roberto Carlos',
                  email: 'roberto.carlos@exitus.edu.pe',
                  role: 'teacher',
                  avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
                  subjects: ['Matemática - 5to A', 'Matemática - 5to B', 'Física - 4to A'],
                ),
                const User(
                  id: 'admin_01',
                  username: 'admin123',
                  fullName: 'Ing. Carlos Mendoza',
                  email: 'carlos.mendoza@exitus.edu.pe',
                  role: 'admin',
                  avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
                  subjects: [],
                ),
              ]);
              db.userPasswords.clear();
              db.userPasswords['profesor123'] = '12345678';
              db.userPasswords['admin123'] = '12345678';

              // Reiniciar estados de asistencia a Presente
              for (var s in db.students5toA) {
                s.attendanceStatus = 'Presente';
              }
              for (var s in db.students5toB) {
                s.attendanceStatus = 'Presente';
              }

              // Reiniciar calificaciones
              db.submissions.clear();
              db.submissions.addAll([
                HomeworkSubmission(
                  id: 'sub_01',
                  studentName: 'Alvarez Quispe, Jose',
                  studentAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Profesor, aquí le adjunto el desarrollo...',
                  date: '26 May, 09:15 PM',
                ),
                HomeworkSubmission(
                  id: 'sub_02',
                  studentName: 'Bustamante Diaz, María',
                  studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Adjunto foto del cuaderno con la resolución completa del tema de límites.',
                  date: '26 May, 11:30 PM',
                ),
                HomeworkSubmission(
                  id: 'sub_03',
                  studentName: 'Chavez Rojas, Carlos',
                  studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Desarrollo del cuestionario sobre derivadas e interpretación geométrica.',
                  date: '27 May, 07:10 AM',
                ),
              ]);

              onRefreshRequested();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Base de datos de demostración restablecida correctamente."),
                  backgroundColor: const Color(0xFF002244),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            child: const Text("Restablecer"),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.logOut, color: Color(0xFFC0392B)),
            SizedBox(width: 8),
            Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("¿Estás seguro de que deseas salir del portal de administrador?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = MockDatabase();
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Perfil del Administrador
          if (user != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002244))),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "ADMINISTRADOR",
                              style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Lista de Usuarios del Sistema
          const Text(
            "Cuentas del Sistema",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = db.users[index];
                final isAdmin = u.role == 'admin';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(u.avatarUrl),
                  ),
                  title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002244))),
                  subtitle: Text("@${u.username} • ${u.email}", style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAdmin ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAdmin ? "ADMIN" : "DOCENTE",
                      style: TextStyle(
                        color: isAdmin ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Opciones de Configuración
          const Text(
            "Opciones del Desarrollador",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.refreshCw, color: Colors.orange),
                  title: const Text("Restablecer Base de Datos de Prueba", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text("Elimina usuarios e historial creado en esta sesión.", style: TextStyle(fontSize: 11)),
                  onTap: () => _resetDatabase(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.logOut, color: Color(0xFFC0392B)),
                  title: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFC0392B))),
                  subtitle: const Text("Salir de la sesión del administrador de manera segura.", style: TextStyle(fontSize: 11)),
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
