import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'digitacion_form_screen.dart';

class DigitacionDashboardScreen extends StatefulWidget {
  const DigitacionDashboardScreen({super.key});

  @override
  State<DigitacionDashboardScreen> createState() => _DigitacionDashboardScreenState();
}

class _DigitacionDashboardScreenState extends State<DigitacionDashboardScreen> {
  final MockDatabase _db = MockDatabase();
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'processing', 'ready', 'completed'

  void _refresh() {
    setState(() {});
  }

  void _navigateToForm({PrintRequest? request}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DigitacionFormScreen(
          request: request,
          onSaved: _refresh,
        ),
      ),
    );
  }

  void _deleteJob(PrintRequest job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Eliminar Solicitud",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1D2848)),
          ),
          content: Text(
            "¿Está seguro que desea eliminar la solicitud de impresión \"#${job.ticketNumber} - ${job.title}\"?",
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                _db.deletePrintRequest(job.id);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Solicitud eliminada correctamente"),
                    backgroundColor: Color(0xFFD32F2F),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("ELIMINAR", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _db.getPrintRequests();

    // Calcular contadores para KPIs
    final pendingCount = jobs.where((j) => j.status == 'pending').length;
    final processingCount = jobs.where((j) => j.status == 'processing').length;
    final readyCount = jobs.where((j) => j.status == 'ready').length;
    final completedCount = jobs.where((j) => j.status == 'completed').length;

    // Filtrar solicitudes
    final filteredJobs = jobs.where((j) {
      if (_selectedStatusFilter == 'all') return true;
      return j.status == _selectedStatusFilter;
    }).toList();

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 240 + statusBarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Cabecera Premium
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9F3FF), Color(0xFFF5F9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Círculos de adorno
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                // Botón Atrás
                Positioned(
                  left: 20,
                  top: 16 + statusBarHeight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.chevronLeft,
                        color: Color(0xFF1D2848),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Logo Exitus
                Positioned(
                  left: 68,
                  top: 15 + statusBarHeight,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: Image.asset(
                          'assets/images/school_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.graduationCap, size: 16, color: Color(0xFF1D2848)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "EXITUS",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF1D2848),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            "COLEGIO",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFEDC620),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Texto de Cabecera
                Positioned(
                  left: 20,
                  bottom: 40,
                  right: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Digitación",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1D2848),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Solicita impresiones y materiales de forma rápida.",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar 3D
                Positioned(
                  right: 12,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/digitacion_avatar.png',
                    height: 230,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 130,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(Icons.person, size: 70, color: Colors.blueGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Acceso a Nueva Solicitud (Botón Amarillo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _navigateToForm(),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDC620),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEDC620).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.plus, color: Color(0xFF1D2848), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Nueva solicitud",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                        fontSize: 14.5,
                      ),
                    ),
                    const Spacer(),
                    const Icon(LucideIcons.chevronRight, color: Color(0xFF1D2848), size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Resumen de gestión (KPIs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resumen de gestión",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: "Pendientes",
                        value: pendingCount,
                        status: "pending",
                        icon: LucideIcons.clock,
                        color: const Color(0xFFD97706),
                        iconBg: const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "En proceso",
                        value: processingCount,
                        status: "processing",
                        icon: LucideIcons.settings,
                        color: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFF0F9FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "Por recoger",
                        value: readyCount,
                        status: "ready",
                        icon: LucideIcons.package,
                        color: const Color(0xFF7C3AED),
                        iconBg: const Color(0xFFFAF5FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "Completadas",
                        value: completedCount,
                        status: "completed",
                        icon: LucideIcons.checkCircle,
                        color: const Color(0xFF16A34A),
                        iconBg: const Color(0xFFF0FDF4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Lista "Mis solicitudes" con filtro rápido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mis solicitudes",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatusFilter = 'all';
                    });
                  },
                  child: Text(
                    "Ver todas >",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.fileText, size: 44, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "No hay solicitudes registradas.",
                          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredJobs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      
                      // Formatear destino escolar
                      final classroomText = job.classrooms.isNotEmpty
                          ? job.classrooms.first.name
                          : "Sin destino";

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _navigateToForm(request: job),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  // Icono documento con color dinámico
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getStatusColors(job.status)['iconBg'],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.fileText,
                                      color: _getStatusColors(job.status)['fg'],
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Detalles de solicitud
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "#${job.ticketNumber}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E88E5),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          job.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1D2848),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          classroomText,
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Estado y fecha
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildStatusBadge(job.status),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.calendar, size: 10, color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            job.date,
                                            style: GoogleFonts.outfit(
                                              fontSize: 10,
                                              color: const Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Menú contextual tres puntos
                                  PopupMenuButton<String>(
                                    icon: const Icon(LucideIcons.moreVertical, size: 18, color: Color(0xFF94A3B8)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _navigateToForm(request: job);
                                      } else if (value == 'delete') {
                                        _deleteJob(job);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: const [
                                            Icon(LucideIcons.edit2, size: 14, color: Color(0xFF1D2848)),
                                            SizedBox(width: 8),
                                            Text('Editar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: const [
                                            Icon(LucideIcons.trash2, size: 14, color: Color(0xFFD32F2F)),
                                            SizedBox(width: 8),
                                            Text('Eliminar', style: TextStyle(fontSize: 12.5, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // 5. Barra de Navegación Inferior (Diseño premium simulado)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 16,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(LucideIcons.home, "Inicio", isSelected: false, onTap: () => Navigator.pop(context)),
              _buildBottomNavItem(LucideIcons.bell, "Avisos", isSelected: false),
              const SizedBox(width: 48), // hueco para el FAB
              _buildBottomNavItem(LucideIcons.messageSquare, "Mensajes", isSelected: false),
              _buildBottomNavItem(LucideIcons.user, "Mi perfil", isSelected: false),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFFEDC620),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          LucideIcons.plus,
          color: Colors.white,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, {required bool isSelected, VoidCallback? onTap}) {
    final color = isSelected ? const Color(0xFF1D2848) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required int value,
    required String status,
    required IconData icon,
    required Color color,
    required Color iconBg,
  }) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = isSelected ? 'all' : status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            // Valor
            Text(
              "$value",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 2),
            // Etiqueta
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final colors = _getStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        colors['label']!,
        style: GoogleFonts.outfit(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: colors['fg'],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusColors(String status) {
    switch (status) {
      case 'pending':
        return {
          'bg': const Color(0xFFFFFBEB),
          'fg': const Color(0xFFD97706),
          'iconBg': const Color(0xFFFEF3C7),
          'label': 'Pendiente',
        };
      case 'processing':
        return {
          'bg': const Color(0xFFF0F9FF),
          'fg': const Color(0xFF0284C7),
          'iconBg': const Color(0xFFE0F2FE),
          'label': 'En proceso',
        };
      case 'ready':
        return {
          'bg': const Color(0xFFFAF5FF),
          'fg': const Color(0xFF7C3AED),
          'iconBg': const Color(0xFFF3E8FF),
          'label': 'Por recoger',
        };
      case 'completed':
        return {
          'bg': const Color(0xFFF0FDF4),
          'fg': const Color(0xFF16A34A),
          'iconBg': const Color(0xFFDCFCE7),
          'label': 'Completado',
        };
      default:
        return {
          'bg': Colors.grey.shade100,
          'fg': Colors.grey.shade600,
          'iconBg': Colors.grey.shade200,
          'label': status.toUpperCase(),
        };
    }
  }
}
