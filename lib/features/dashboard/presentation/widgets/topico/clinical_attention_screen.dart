import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class ClinicalAttentionScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ClinicalAttentionScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ClinicalAttentionScreen> createState() => _ClinicalAttentionScreenState();
}

class _ClinicalAttentionScreenState extends State<ClinicalAttentionScreen> {
  final MockDatabase _db = MockDatabase();

  // Vital Signs controllers
  final TextEditingController _tempController = TextEditingController(text: "36.8");
  final TextEditingController _pressureController = TextEditingController(text: "120/80");
  final TextEditingController _pulseController = TextEditingController(text: "80");
  
  // Observations controller
  final TextEditingController _obsController = TextEditingController();

  // Checklist of actions
  bool _reposoVal = true;
  bool _hidraVal = true;
  bool _medVal = false;
  bool _llamarVal = false;
  bool _derivarVal = false;

  @override
  void initState() {
    super.initState();
    // Default observations if description is available
    if (widget.patient['description'] != null) {
      _obsController.text = widget.patient['description'] as String;
    } else {
      _obsController.text = "Paciente refiere dolor leve en la zona. Sin otros síntomas asociados.";
    }
  }

  @override
  void dispose() {
    _tempController.dispose();
    _pressureController.dispose();
    _pulseController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _dischargePatient() {
    // 1. Crear registro para Auditoría Legal
    final String attentionId = '#${484 + _db.nurseAuditLogs.length}';
    final auditRecord = {
      'id': attentionId.replaceAll('#', ''),
      'student': widget.patient['name'],
      'date': _formatCurrentDate(),
      'time': _formatCurrentTime(),
      'status': 'Firmado'
    };
    _db.nurseAuditLogs.insert(0, auditRecord);

    // 2. Remover de Pacientes en espera
    _db.nurseWaitingPatients.removeWhere((p) => p['id'] == widget.patient['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Atención del alumno ${widget.patient['name']} guardada y firmada digitalmente ($attentionId). Alumno dado de alta.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true); // Retorna true para refrescar la lista
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day/$month/${now.year}';
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'p. m.' : 'a. m.';
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.patient['name'] ?? 'Alumno';
    final grade = widget.patient['grade'] ?? 'Sección';
    final avatar = widget.patient['avatar'] ?? 'https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150';
    final entryTime = widget.patient['entryTime'] ?? '09:00 a. m.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2848),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Atención Clínica",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de Paciente Activo
                  Card(
                    color: Colors.white,
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
                            radius: 26,
                            backgroundImage: NetworkImage(avatar),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  grade,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Ingreso: Hoy - $entryTime",
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFD54F)),
                            ),
                            child: const Text(
                              "En atención",
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFF57F17)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sección Signos Vitales
                  Text(
                    "Signos Vitales",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVitalSignInput(
                          label: "Temp. (°C)",
                          controller: _tempController,
                          icon: LucideIcons.thermometer,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVitalSignInput(
                          label: "Presión",
                          controller: _pressureController,
                          icon: LucideIcons.activity,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVitalSignInput(
                          label: "Pulso (lpm)",
                          controller: _pulseController,
                          icon: LucideIcons.heartPulse,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sección Observaciones
                  Text(
                    "Observaciones / Síntomas",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _obsController,
                    maxLines: 3,
                    maxLength: 150,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1D2848), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sección Acciones Realizadas
                  Text(
                    "Acciones Realizadas",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Column(
                        children: [
                          _buildCheckboxTile("Reposo en tópico", _reposoVal, (v) => setState(() => _reposoVal = v ?? false)),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildCheckboxTile("Hidratación suministrada", _hidraVal, (v) => setState(() => _hidraVal = v ?? false)),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildCheckboxTile("Medicación oral autorizada", _medVal, (v) => setState(() => _medVal = v ?? false)),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildCheckboxTile("Notificar a los padres", _llamarVal, (v) => setState(() => _llamarVal = v ?? false)),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildCheckboxTile("Derivar a centro médico / médico", _derivarVal, (v) => setState(() => _derivarVal = v ?? false)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botones Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opciones de derivación y auditoría extendida (Simulación)")),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Más acciones...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _dischargePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.check, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "DAR DE ALTA",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
      ),
      activeColor: const Color(0xFF2E7D32),
      checkColor: Colors.white,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
