import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class AjustesView extends StatelessWidget {
  const AjustesView({super.key});

  @override
  Widget build(BuildContext context) {
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
          "Ajustes",
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    context,
                    icon: LucideIcons.bell,
                    title: "Notificaciones",
                    subtitle: "Personaliza tus alertas",
                    onTap: () => _showDevelopmentSnackBar(context, "Notificaciones"),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
                  _buildSettingItem(
                    context,
                    icon: LucideIcons.palette,
                    title: "Apariencia",
                    subtitle: "Tema de la aplicación",
                    onTap: () => _showDevelopmentSnackBar(context, "Apariencia"),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
                  _buildSettingItem(
                    context,
                    icon: LucideIcons.accessibility,
                    title: "Accesibilidad",
                    subtitle: "Tamaño de texto y más",
                    onTap: () => _showDevelopmentSnackBar(context, "Accesibilidad"),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
                  _buildSettingItem(
                    context,
                    icon: LucideIcons.globe,
                    title: "Idioma",
                    subtitle: "Español (Latinoamérica)",
                    onTap: () => _showDevelopmentSnackBar(context, "Idioma"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1D2848)),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1D2848),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 10.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }

  void _showDevelopmentSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ajustes de $title: Funcionalidad en desarrollo"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
