import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'busqueda_expedientes_screen.dart';
import 'nueva_atencion_screen.dart';
import 'inventario_topico_screen.dart';

class TopicoDashboardScreen extends StatefulWidget {
  final User currentUser;

  const TopicoDashboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<TopicoDashboardScreen> createState() => _TopicoDashboardScreenState();
}

class _TopicoDashboardScreenState extends State<TopicoDashboardScreen> {
  // Datos locales simulados para persistencia durante la navegación
  final List<Map<String, dynamic>> _recentAttentions = [
    {
      'name': 'TANIA CHUYE TAVARA',
      'dni': 'DNI: 76277884',
      'time': '09/06/2026 09:27',
      'type': 'Ambulatoria',
      'status': 'Alta',
      'motive': 'Dolor abdominal / Cólico'
    },
    {
      'name': 'Xiomara Lucero CHAPA CARRASCO',
      'dni': 'DNI: A20220095',
      'time': '09/06/2026 08:29',
      'type': 'Ambulatoria',
      'status': 'Alta',
      'motive': 'Malestar general / Resfriado'
    },
  ];

  void _addNewAttention(Map<String, dynamic> attention) {
    setState(() {
      _recentAttentions.insert(0, attention);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "Tópico y Enfermería",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera e Introducción
            Text(
              "Centro Operativo Clínico",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Triaje automatizado, control de stock y expedientes médicos.",
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción principal superior
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusquedaExpedientesScreen(
                            currentUser: widget.currentUser,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.search, size: 16, color: Colors.white),
                    label: const Text(
                      "Buscar Pacientes",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2848),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuevaAtencionScreen(
                            currentUser: widget.currentUser,
                            onSave: _addNewAttention,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                    label: const Text(
                      "Registro Rápido",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9), // Teal-blue médico
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila de Métricas
            Row(
              children: [
                _buildStatCard("Atenciones hoy", "2", LucideIcons.heart, const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                _buildStatCard("Derivados a casa", "0", LucideIcons.home, const Color(0xFFF57C00)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard("Tasa de alta", "100%", LucideIcons.checkCircle2, const Color(0xFF10B981)),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventarioTopicoScreen(
                            currentUser: widget.currentUser,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(LucideIcons.package, size: 16, color: Color(0xFF059669)),
                              Icon(LucideIcons.arrowUpRight, size: 14, color: Color(0xFF059669)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Stock",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          const Text(
                            "Control Inventario",
                            style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pacientes esperando / Estado actual
            Text(
              "Pacientes en Consulta",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.smile, size: 36, color: Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  Text(
                    "Todos los pacientes atendidos",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "No hay pacientes esperando triaje en el consultorio.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuevaAtencionScreen(
                            currentUser: widget.currentUser,
                            onSave: _addNewAttention,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.userPlus, size: 14),
                    label: const Text(
                      "Admitir Paciente Rápido",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0EA5E9),
                      side: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bitácora de Atenciones Recientes
            Text(
              "Bitácora de Atenciones Recientes",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentAttentions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final attention = _recentAttentions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: const Icon(LucideIcons.user, size: 16, color: Color(0xFF64748B)),
                    ),
                    title: Text(
                      attention['name'],
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          "${attention['dni']} • ${attention['time']}",
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Motivo: ${attention['motive']}",
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF1D2848), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          attention['type'],
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            attention['status'],
                            style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Alertas Críticas (Escalamiento)
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
                      const Icon(LucideIcons.activity, color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Centro de Alertas Críticas",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Escalamiento automático de signos vitales críticos, alarmas y dosis de medicamentos.",
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle, color: Color(0xFF2E7D32), size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "No hay alertas activas. Telemetría y signos vitales estables.",
                            style: TextStyle(
                              color: const Color(0xFF2E7D32),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Consolas y Telemetría
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildConsoleLink(
                    icon: LucideIcons.activity,
                    title: "Telemetría de Guardias",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Abriendo monitoreo en tiempo real...")),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildConsoleLink(
                    icon: LucideIcons.alertOctagon,
                    title: "Consola de Alertas Clínicas",
                    badgeText: "Estable",
                    badgeColor: const Color(0xFF10B981),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Abriendo consola de alarmas...")),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 48, color: Color(0xFFE2E8F0)),
                  _buildConsoleLink(
                    icon: LucideIcons.fileSpreadsheet,
                    title: "Auditoría Criptográfica Legal",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Accediendo a auditoría y firmas blockchain...")),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsoleLink({
    required IconData icon,
    required String title,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1D2848)),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1D2848),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor ?? const Color(0xFF10B981),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
      onTap: onTap,
    );
  }
}
