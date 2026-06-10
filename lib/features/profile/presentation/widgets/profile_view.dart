import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'datos_personales_view.dart';
import 'seguridad_view.dart';
import 'informacion_institucional_view.dart';
import 'ajustes_view.dart';
import 'cambiar_rol_view.dart';

class ExitusProfileView extends ConsumerWidget {
  final User currentUser;
  final VoidCallback onLogout;

  const ExitusProfileView({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'student':
        return 'Estudiante';
      case 'teacher':
        return 'Profesor';
      case 'admin':
        return 'Administración';
      case 'biblioteca':
        return 'Biblioteca';
      case 'topico':
        return 'Enfermería / Tópico';
      case 'tesoreria':
        return 'Tesorería';
      case 'eventos':
        return 'Eventos';
      case 'convivencia':
        return 'Convivencia';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return LucideIcons.graduationCap;
      case 'teacher':
        return LucideIcons.userCheck;
      case 'biblioteca':
        return LucideIcons.bookOpen;
      case 'topico':
        return LucideIcons.activity;
      case 'tesoreria':
        return LucideIcons.landmark;
      case 'admin':
        return LucideIcons.building;
      case 'eventos':
        return LucideIcons.calendar;
      case 'convivencia':
        return LucideIcons.shieldAlert;
      default:
        return LucideIcons.user;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(activeRoleProvider);
    final String activeRoleName = _getRoleDisplayName(activeRole);
    final IconData activeRoleIcon = _getRoleIcon(activeRole);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          "Mi Perfil",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Color(0xFF1D2848), size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No hay notificaciones nuevas")),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de Foto de Perfil y Nombre
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D2848).withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(currentUser.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Subir nueva foto de perfil")),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D2848),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplayName(currentUser.role).toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF2196F3),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Rol Activo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFFE5A93B)),
                      const SizedBox(width: 6),
                      Text(
                        "Rol Activo",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE5A93B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Actualmente estás usando la vista de:",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Caja del Rol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(activeRoleIcon, size: 18, color: const Color(0xFF1D2848)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activeRoleName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón Cambiar de Rol
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CambiarRolView(
                              currentUser: currentUser,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE5A93B),
                        side: const BorderSide(color: Color(0xFFE5A93B), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.repeat, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Cambiar de Rol",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menú de Opciones
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.user,
                    title: "Datos Personales",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DatosPersonalesView(
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.lock,
                    title: "Seguridad",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeguridadView(
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.building,
                    title: "Información Institucional",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformacionInstitucionalView(
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.settings,
                    title: "Ajustes",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AjustesView(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.logOut,
                    title: "Cerrar Sesión",
                    titleColor: const Color(0xFFD32F2F),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    final bool isLogout = icon == LucideIcons.logOut;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? const Color(0xFFFDECEA) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isLogout ? const Color(0xFFD32F2F) : const Color(0xFF1D2848),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: titleColor ?? const Color(0xFF1D2848),
        ),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
