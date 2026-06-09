import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'admit_patient_screen.dart';
import 'clinical_attention_screen.dart';
import 'expedientes_screen.dart';
import 'stock_screen.dart';
import 'alerts_screen.dart';
import 'auditoria_screen.dart';

class NurseHomeView extends StatefulWidget {
  const NurseHomeView({super.key});

  @override
  State<NurseHomeView> createState() => _NurseHomeViewState();
}

class _NurseHomeViewState extends State<NurseHomeView> {
  final MockDatabase _db = MockDatabase();

  void _refresh() {
    setState(() {});
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((value) {
      if (value == true || value == null) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final waitingCount = _db.nurseWaitingPatients.length;
    final stockOkCount = _db.nurseStockItems.where((item) => item['status'] == 'Stock OK').length;
    final totalStock = _db.nurseStockItems.length;
    final alertsCount = _db.nurseAlerts.length;
    final attendedTodayCount = _db.nurseAuditLogs.length;

    final hasAlerts = alertsCount > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        color: const Color(0xFF1D2848),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cabecera estilo Profesor/Alumno
              _buildHeader(context, alertsCount, hasAlerts),

              // 2. Contenido del panel con espaciado adecuado
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner de estado general ("Todo bajo control")
                    _buildAlertBanner(hasAlerts, alertsCount),
                    const SizedBox(height: 20),

                    // Tarjetas de métricas responsivas
                    _buildKpiGrid(
                      context,
                      attendedTodayCount,
                      waitingCount,
                      stockOkCount,
                      totalStock,
                      alertsCount,
                    ),
                    const SizedBox(height: 24),

                    // Pacientes en espera
                    _buildPatientsSection(context),
                    const SizedBox(height: 24),

                    // Acciones rápidas con ícono y contenido en un solo contenedor
                    _buildQuickActionsSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int alertsCount, bool hasAlerts) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 220 + statusBarHeight;

    return Container(
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            left: 24,
            top: 24 + statusBarHeight,
            child: Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: OverflowBox(
                maxWidth: 140,
                maxHeight: 36,
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/school_logo.png',
                  height: 36,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Positioned(
            left: 68,
            top: 22 + statusBarHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EXITUS",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1D2848),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    height: 1.1,
                  ),
                ),
                Text(
                  "COLEGIO",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEDC620),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            top: 22 + statusBarHeight,
            child: GestureDetector(
              onTap: () => _navigateTo(const AlertsScreen()),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.bell,
                      size: 16,
                      color: Color(0xFF1D2848),
                    ),
                  ),
                  if (hasAlerts)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          "$alertsCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 12,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Hola, Lic. Rosa 👋",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1D2848),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 1,
                          color: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "ROL: ",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Tópico Escolar",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1D2848),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Turno Mañana",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/mascot_topico.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 140,
                    alignment: Alignment.bottomCenter,
                    child: const Icon(LucideIcons.heartPulse, size: 80, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(bool hasAlerts, int alertsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAlerts ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasAlerts ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: hasAlerts ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAlerts ? LucideIcons.alertTriangle : LucideIcons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAlerts ? "Atención requerida" : "Todo bajo control",
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasAlerts
                      ? "Hay $alertsCount alertas críticas activas."
                      : "0 alertas críticas",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    int attendedTodayCount,
    int waitingCount,
    int stockOkCount,
    int totalStock,
    int alertsCount,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildKpiCard(
              "Atendidos hoy",
              "$attendedTodayCount",
              LucideIcons.users,
              const Color(0xFF8B5CF6),
              onTap: () => _navigateTo(const AuditoriaScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              "En espera",
              "$waitingCount",
              LucideIcons.clock,
              const Color(0xFFF59E0B),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              "Stock OK",
              "$stockOkCount",
              LucideIcons.briefcase,
              const Color(0xFF10B981),
              onTap: () => _navigateTo(const StockScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              "Alertas críticas",
              "$alertsCount",
              LucideIcons.bell,
              const Color(0xFFEF4444),
              onTap: () => _navigateTo(const AlertsScreen()),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  "Atendidos hoy",
                  "$attendedTodayCount",
                  LucideIcons.users,
                  const Color(0xFF8B5CF6),
                  onTap: () => _navigateTo(const AuditoriaScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  "En espera",
                  "$waitingCount",
                  LucideIcons.clock,
                  const Color(0xFFF59E0B),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  "Stock OK",
                  "$stockOkCount",
                  LucideIcons.briefcase,
                  const Color(0xFF10B981),
                  onTap: () => _navigateTo(const StockScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  "Alertas críticas",
                  "$alertsCount",
                  LucideIcons.bell,
                  const Color(0xFFEF4444),
                  onTap: () => _navigateTo(const AlertsScreen()),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D2848).withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pacientes en espera",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mostrando todos los pacientes en cola (Simulación)"),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Ver todos",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_db.nurseWaitingPatients.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: const [
                Icon(LucideIcons.users, color: Color(0xFFCBD5E1), size: 36),
                SizedBox(height: 8),
                Text(
                  "No hay pacientes en espera de atención.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _db.nurseWaitingPatients.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final patient = _db.nurseWaitingPatients[index];

              String waitLabel = "";
              if (patient['name'] == 'Ana Torres Medina') {
                waitLabel = "2 min esperando";
              } else if (patient['name'] == 'Diego Ramos León') {
                waitLabel = "Llegó hace 1 min";
              } else {
                waitLabel = "Esperando: ${patient['time']}";
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(patient['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'],
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patient['reason'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              waitLabel,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateTo(ClinicalAttentionScreen(patient: patient)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          backgroundColor: const Color(0xFFFEF3C7),
                          foregroundColor: const Color(0xFFD97706),
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Atender",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Acciones rápidas",
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionItem(
              "Admitir\nPaciente",
              LucideIcons.userPlus,
              const Color(0xFF3B82F6),
              const AdmitPatientScreen(),
            ),
            const SizedBox(width: 8),
            _buildQuickActionItem(
              "Expedientes\nClínicos",
              LucideIcons.folderOpen,
              const Color(0xFF8B5CF6),
              const ExpedientesScreen(),
            ),
            const SizedBox(width: 8),
            _buildQuickActionItem(
              "Inventario\nStock",
              LucideIcons.briefcase,
              const Color(0xFF10B981),
              const StockScreen(),
            ),
            const SizedBox(width: 8),
            _buildQuickActionItem(
              "Alertas\nCríticas",
              LucideIcons.bellRing,
              const Color(0xFFEF4444),
              const AlertsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    String label,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(destination),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D2848).withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
