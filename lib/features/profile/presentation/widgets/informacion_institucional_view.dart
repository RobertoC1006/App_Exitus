import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class InformacionInstitucionalView extends StatelessWidget {
  final User currentUser;

  const InformacionInstitucionalView({
    super.key,
    required this.currentUser,
  });

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'student':
        return 'Estudiante';
      case 'teacher':
        return 'Docente';
      case 'admin':
        return 'Administrador';
      case 'parent':
        return 'Padre de Familia';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMateo = currentUser.username.contains('mateo');
    final String code = isMateo ? 'EX-20260943' : (currentUser.role == 'teacher' ? 'EX-09432' : 'EX-20261125');
    final String memberSince = isMateo ? '10 Mar, 2023' : (currentUser.role == 'teacher' ? '12 May, 2021' : '15 Apr, 2026');
    final String gradeSection = isMateo ? '4° A - Secundaria' : (currentUser.role == 'teacher' ? 'Tutoría / Secundaria' : 'N/A');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Información Institucional",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Escudo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/school_logo.png',
                    width: 55,
                    height: 55,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D2848).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.shield, size: 28, color: Color(0xFF1D2848)),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I.E.P. EXITUS",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Formando líderes desde 2001",
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contenedor de detalles institucionales
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: LucideIcons.fileText,
                    label: "Código Institucional",
                    value: code,
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildDetailItem(
                    icon: LucideIcons.user,
                    label: "Usuario",
                    value: currentUser.username,
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildDetailItem(
                    icon: LucideIcons.calendar,
                    label: "Miembro desde",
                    value: memberSince,
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildDetailItem(
                    icon: LucideIcons.graduationCap,
                    label: "Rol principal",
                    value: _getRoleDisplayName(currentUser.role),
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildDetailItem(
                    icon: LucideIcons.activity,
                    label: "Estado",
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Activo",
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildDetailItem(
                    icon: LucideIcons.mapPin,
                    label: "Sede",
                    value: "Sede Principal",
                  ),
                  if (currentUser.role == 'student' || currentUser.role == 'teacher') ...[
                    const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                    _buildDetailItem(
                      icon: LucideIcons.bookOpen,
                      label: currentUser.role == 'student' ? "Grado / Sección" : "Cargo / Nivel",
                      value: gradeSection,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mascot banner at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFF9C4)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mascot_horario.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.heart, size: 24, color: Colors.amber),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Gracias por ser parte de nuestra comunidad Exitus. ❤️",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB78A00),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF1D2848)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? "",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
        ],
      ),
    );
  }
}
