import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class AdminHomeView extends StatelessWidget {
  final Function(int) onTabChanged;
  final VoidCallback onRegisterUserPressed;

  const AdminHomeView({
    super.key,
    required this.onTabChanged,
    required this.onRegisterUserPressed,
  });

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final totalTeachers = db.users.where((u) => u.role == 'teacher').length;
    final totalAdmins = db.users.where((u) => u.role == 'admin').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de Bienvenida
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002244), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002244).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel de Control Exitus",
                  style: TextStyle(color: Color(0xFFE5A93B), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Bienvenido, Administrador",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Sistema Intranet de Gestión Académica",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título de Métricas
          const Text(
            "Resumen Institucional",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 12),

          // Grid de Métricas
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                "Profesores",
                "$totalTeachers Activos",
                LucideIcons.users,
                Colors.blue,
              ),
              _buildStatCard(
                "Administradores",
                "$totalAdmins",
                LucideIcons.shieldAlert,
                Colors.purple,
              ),
              _buildStatCard(
                "Asistencia Hoy",
                "96.4%",
                LucideIcons.calendarCheck,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                "Aulas Activas",
                "3 secciones",
                LucideIcons.bookOpen,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Accesos Rápidos
          const Text(
            "Acciones Rápidas",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 12),

          // Lista de botones de accesos rápidos
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: LucideIcons.userPlus,
                  title: "Crear Nuevo Usuario",
                  subtitle: "Docentes o Administradores del sistema",
                  color: const Color(0xFF002244),
                  onTap: onRegisterUserPressed,
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildActionTile(
                  icon: LucideIcons.bookOpen,
                  title: "Gestionar Aulas",
                  subtitle: "Visualizar secciones y tutores",
                  color: const Color(0xFF3B82F6),
                  onTap: () => onTabChanged(1),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildActionTile(
                  icon: LucideIcons.fileSpreadsheet,
                  title: "Reporte de Asistencia",
                  subtitle: "Ver inasistencias y asistencia diaria",
                  color: const Color(0xFF10B981),
                  onTap: () => onTabChanged(2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002244))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
