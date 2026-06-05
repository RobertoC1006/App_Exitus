import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';
import 'new_bitacora_flow.dart';

class BitacoraDashboardScreen extends StatefulWidget {
  const BitacoraDashboardScreen({super.key});

  @override
  State<BitacoraDashboardScreen> createState() =>
      _BitacoraDashboardScreenState();
}

class _BitacoraDashboardScreenState extends State<BitacoraDashboardScreen> {
  String _selectedStatusFilter =
      'all'; // 'all', 'pending', 'official', 'grave', 'leve'

  // Simulación de base de datos local de reportes generados
  final List<BitacoraReport> _reports = [
    BitacoraReport(
      id: 'rep_01',
      type: 'Conductual',
      involvedStudents: [
        InvolvedStudent(
          id: 's_luis',
          fullName: 'Luis Valdiviezo Whitehead',
          avatarUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
          classroom: 'Aula 4° B',
          role: 'Responsable',
          notifyParent: true,
        ),
        InvolvedStudent(
          id: 's_bryana',
          fullName: 'Bryana Alama Eca',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
          classroom: 'Aula 4° B',
          role: 'Afectado',
          notifyParent: true,
        ),
      ],
      date: '05/06/2026',
      time: '10:23 a. m.',
      location: 'Aula 4° B',
      description:
          'Durante la clase, los alumnos se lanzaron papeles entre ellos y no prestaron atención a la explicación. A pesar de las advertencias, continuaron interrumpiendo.',
      selectedMeasures: const [
        'Conversación con estudiantes',
        'Llamado de atención',
      ],
      measureContexts: const {
        'General': 'Se conversó con los estudiantes sobre el respeto y las normas de comportamiento. Además, se les realizó un llamado de atención verbal y se registró en el aula.',
      },
      measureFollowUps: const {
        'General': 'Seguimiento la próxima semana para evaluar mejoría.',
      },
      isOfficial: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    BitacoraReport(
      id: 'rep_02',
      type: 'Relacional',
      involvedStudents: [
        InvolvedStudent(
          id: 's_bryana',
          fullName: 'Bryana Alama Eca',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
          classroom: 'Aula 4° B',
          role: 'Responsable',
          notifyParent: false,
        ),
      ],
      date: '05/06/2026',
      time: '09:45 a. m.',
      location: 'Patio de Recreo',
      description:
          'Hubo una discusión verbal entre estudiantes debido a un malentendido durante los juegos de fútbol.',
      selectedMeasures: const [
        'Conversación con estudiantes',
      ],
      measureContexts: const {
        'General': 'Mediación de conflicto en el patio de recreo.',
      },
      measureFollowUps: const {},
      isOfficial: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    BitacoraReport(
      id: 'rep_03',
      type: 'Física',
      involvedStudents: [
        InvolvedStudent(
          id: 's_mateo',
          fullName: 'Mateo Guerrero C.',
          avatarUrl:
              'https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150',
          classroom: 'Aula 5° A',
          role: 'Responsable',
          notifyParent: true,
        ),
      ],
      date: '04/06/2026',
      time: '03:15 p. m.',
      location: 'Pasadizo de Primaria',
      description:
          'Juegos bruscos que terminaron en empujones entre estudiantes en el pasadizo.',
      selectedMeasures: const [
        'Derivación a Convivencia',
      ],
      measureContexts: const {
        'General': 'Se reportó formalmente el incidente al equipo de convivencia escolar.',
      },
      measureFollowUps: const {
        'General': 'Citación conjunta con el psicólogo del colegio.',
      },
      isOfficial: false, // Pendiente
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  int get _pendingCount => _reports.where((r) => !r.isOfficial).length;
  int get _officialCount => _reports.where((r) => r.isOfficial).length;
  int get _graveCount =>
      _reports.where((r) => r.type == 'Física' || r.type == 'Digital').length;
  int get _leveCount => _reports
      .where((r) => r.type == 'Conductual' || r.type == 'Relacional')
      .length;

  void _startNewBitacoraFlow() async {
    final newReport = await Navigator.push<BitacoraReport>(
      context,
      MaterialPageRoute(builder: (context) => const NewBitacoraFlow()),
    );

    if (newReport != null) {
      setState(() {
        _reports.insert(0, newReport);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.checkCircle, color: Colors.white),
              SizedBox(width: 8),
              Text("Bitácora registrada con éxito."),
            ],
          ),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showReportDetailsDialog(BitacoraReport report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                LucideIcons.bookOpen,
                color: Color(0xFF1D2848),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Detalles de Bitácora",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1D2848),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailField("Tipo:", report.type),
                _buildDetailField(
                  "Fecha y Hora:",
                  "${report.date} a las ${report.time}",
                ),
                _buildDetailField("Lugar:", report.location),
                _buildDetailField(
                  "Involucrados:",
                  report.involvedStudents
                      .map((s) => "${s.fullName} (${s.role})")
                      .join("\n"),
                ),
                _buildDetailField("Descripción:", report.description),
                if (report.selectedMeasures.isNotEmpty)
                  _buildDetailField(
                    "Medidas Adoptadas:",
                    report.selectedMeasures.map((m) => "• $m").join("\n"),
                  ),
                if ((report.measureContexts['General'] ?? "").isNotEmpty)
                  _buildDetailField(
                    "Detalle de Medidas:",
                    report.measureContexts['General']!,
                  ),
                if ((report.measureFollowUps['General'] ?? "").isNotEmpty)
                  _buildDetailField(
                    "Seguimiento posterior:",
                    report.measureFollowUps['General']!,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CERRAR",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: const Color(0xFF1D2848),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar reportes generados
    final filteredReports = _reports.where((r) {
      if (_selectedStatusFilter == 'all') return true;
      if (_selectedStatusFilter == 'pending') return !r.isOfficial;
      if (_selectedStatusFilter == 'official') return r.isOfficial;
      if (_selectedStatusFilter == 'grave') {
        return r.type == 'Física' || r.type == 'Digital';
      }
      if (_selectedStatusFilter == 'leve') {
        return r.type == 'Conductual' || r.type == 'Relacional';
      }
      return true;
    }).toList();

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 240 + statusBarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Cabecera Premium estilo Digitación
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9F3FF), Color(0xFFF5F9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                LucideIcons.graduationCap,
                                size: 16,
                                color: Color(0xFF1D2848),
                              ),
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
                  right: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bitácoras",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1D2848),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Registro de incidencias y convivencia escolar.",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar 3D (con fallback premium a mascot_bitacoras.png para evitar 404)
                Positioned(
                  right: 12,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/bitacora_avatar.png',
                    height: 210,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/mascot_bitacoras.png',
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 110,
                        height: 130,
                        alignment: Alignment.bottomCenter,
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Acceso a Nueva Bitácora (Botón Amarillo estilo Digitación)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: _startNewBitacoraFlow,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      child: const Icon(
                        LucideIcons.plus,
                        color: Color(0xFF1D2848),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Nueva Bitácora",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                        fontSize: 14.5,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      LucideIcons.chevronRight,
                      color: Color(0xFF1D2848),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Resumen de gestión (KPIs en fila de 4 columnas estilo Digitación)
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
                        value: _pendingCount,
                        status: "pending",
                        icon: LucideIcons.clock,
                        color: const Color(0xFFD97706),
                        iconBg: const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "Oficiales",
                        value: _officialCount,
                        status: "official",
                        icon: LucideIcons.checkCircle,
                        color: const Color(0xFF16A34A),
                        iconBg: const Color(0xFFF0FDF4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "Graves",
                        value: _graveCount,
                        status: "grave",
                        icon: LucideIcons.alertTriangle,
                        color: const Color(0xFFDC2626),
                        iconBg: const Color(0xFFFEF2F2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        label: "Leves",
                        value: _leveCount,
                        status: "leve",
                        icon: LucideIcons.info,
                        color: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFF0F9FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Lista "Reportes Generados" con filtro rápido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reportes Generados",
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
                    "Ver todos >",
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
            child: filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.fileText,
                          size: 44,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No hay reportes registrados.",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredReports.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportItem(report);
                    },
                  ),
          ),
        ],
      ),
      // 5. Barra de Navegación Inferior (Diseño premium simulado como Digitación)
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
              _buildBottomNavItem(
                LucideIcons.home,
                "Inicio",
                isSelected: false,
                onTap: () => Navigator.pop(context),
              ),
              _buildBottomNavItem(
                LucideIcons.bell,
                "Avisos",
                isSelected: false,
              ),
              const SizedBox(width: 48), // hueco para el FAB
              _buildBottomNavItem(
                LucideIcons.messageSquare,
                "Mensajes",
                isSelected: false,
              ),
              _buildBottomNavItem(
                LucideIcons.user,
                "Mi perfil",
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewBitacoraFlow,
        backgroundColor: const Color(0xFFEDC620),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final color = isSelected
        ? const Color(0xFF1D2848)
        : const Color(0xFF94A3B8);
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
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
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
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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

  Widget _buildReportItem(BitacoraReport report) {
    final mainStudent = report.involvedStudents.firstWhere(
      (s) => s.role == 'Responsable',
      orElse: () => report.involvedStudents.first,
    );

    final String timeAgo = report.id == 'rep_01'
        ? "Hace 10 min"
        : report.id == 'rep_02'
        ? "Hace 25 min"
        : "Ayer";

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
          onTap: () => _showReportDetailsDialog(report),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Student Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(mainStudent.avatarUrl),
                  child: const Icon(
                    LucideIcons.user,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 12),
                // Detalles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainStudent.fullName,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${report.type}  •  ${mainStudent.classroom}",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.location,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          color: const Color(0xFF94A3B8),
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
                    _buildStatusBadge(report.isOfficial),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 10,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
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
                const SizedBox(width: 4),
                // Menú de tres puntos (simulado para detalle)
                IconButton(
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => _showReportDetailsDialog(report),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOfficial) {
    final colors = _getStatusColors(isOfficial);
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

  Map<String, dynamic> _getStatusColors(bool isOfficial) {
    if (isOfficial) {
      return {
        'bg': const Color(0xFFF0FDF4),
        'fg': const Color(0xFF16A34A),
        'label': 'Oficial',
      };
    } else {
      return {
        'bg': const Color(0xFFFFFBEB),
        'fg': const Color(0xFFD97706),
        'label': 'Pendiente',
      };
    }
  }
}
