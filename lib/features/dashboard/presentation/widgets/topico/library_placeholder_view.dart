import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryPlaceholderView extends StatelessWidget {
  const LibraryPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.bookOpen, color: Color(0xFF8B5CF6), size: 18),
        ),
        title: Text(
          "BIBLIOTECA ESCOLAR",
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B5CF6),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info, color: Color(0xFF8B5CF6)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Módulo de Biblioteca Escolar Exitus")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hola, Lic. Rosa 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Turno Mañana",
                          style: TextStyle(
                            color: Color(0xFFEDC620),
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Biblioteca Digital",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.bookOpen,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics overview (Mocked)
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              children: [
                _buildMockKpiCard("Prestados hoy", "0", LucideIcons.bookUp, const Color(0xFF8B5CF6)),
                _buildMockKpiCard("Catálogo", "1,250", LucideIcons.library, const Color(0xFF3B82F6)),
                _buildMockKpiCard("Demorados", "0", LucideIcons.clock, const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 20),

            // Under Development Warning Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.construction, color: Color(0xFF8B5CF6), size: 48),
                  const SizedBox(height: 14),
                  Text(
                    "Módulo en Preparación",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "El equipo de tecnología escolar está integrando el catálogo digital y la base de datos de libros. ¡Estará listo muy pronto!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 16),
                  
                  // Progress Roadmap
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "HOJA DE RUTA DEL MÓDULO",
                        style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      _buildRoadmapItem("Planificación y Arquitectura", true),
                      _buildRoadmapItem("Mock-ups de Diseño Premium", true),
                      _buildRoadmapItem("Integración de Catálogo Digital (En progreso)", true, isInProgress: true),
                      _buildRoadmapItem("Control de Préstamos y Devolución QR", false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
              Icon(icon, size: 12, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(String title, bool done, {bool isInProgress = false}) {
    Widget checkIcon = const Icon(LucideIcons.circle, size: 12, color: Color(0xFF94A3B8));

    if (done) {
      if (isInProgress) {
        checkIcon = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF8B5CF6),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(LucideIcons.play, size: 8, color: Colors.white),
          ),
        );
      } else {
        checkIcon = const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF2E7D32));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          checkIcon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                color: done ? const Color(0xFF1D2848) : const Color(0xFF94A3B8),
                decoration: done && !isInProgress ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
