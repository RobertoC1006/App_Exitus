import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';

class StepPreview extends StatefulWidget {
  final String incidentType;
  final List<InvolvedStudent> involvedStudents;
  final ValueChanged<List<InvolvedStudent>> onStudentsChanged;
  final String date;
  final String time;
  final String location;
  final String description;
  final List<String> selectedMeasures;
  final Map<String, String> measureContexts;
  final Map<String, String> measureFollowUps;
  final VoidCallback onEdit;
  final VoidCallback onSubmit;

  const StepPreview({
    super.key,
    required this.incidentType,
    required this.involvedStudents,
    required this.onStudentsChanged,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.selectedMeasures,
    required this.measureContexts,
    required this.measureFollowUps,
    required this.onEdit,
    required this.onSubmit,
  });

  @override
  State<StepPreview> createState() => _StepPreviewState();
}

class _StepPreviewState extends State<StepPreview> {
  bool _isSubmitting = false;

  void _toggleNotification(String id, bool value) {
    final list = widget.involvedStudents.map((student) {
      if (student.id == id) {
        return student.copyWith(notifyParent: value);
      }
      return student;
    }).toList();
    widget.onStudentsChanged(list);
  }

  void _handleFinalSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    // 1. Crear el objeto de reporte consolidado
    final report = BitacoraReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      type: widget.incidentType,
      involvedStudents: widget.involvedStudents,
      date: widget.date,
      time: widget.time,
      location: widget.location,
      description: widget.description,
      selectedMeasures: widget.selectedMeasures,
      measureContexts: widget.measureContexts,
      measureFollowUps: widget.measureFollowUps,
      isOfficial: true,
      createdAt: DateTime.now(),
    );

    // =========================================================================
    // WHATSAPP API & SUBMIT INTEGRATION (PUNTO DE CONEXIÓN CON EL BACKEND)
    // =========================================================================
    
    // 2. Ejecutar notificaciones de WhatsApp para cada alumno marcado
    for (var student in widget.involvedStudents) {
      if (student.notifyParent) {
        debugPrint("[SUBMIT EVENT] Alumno marcado para WhatsApp: ${student.fullName}");
        
        // LLAMADA AL ENDPOINT STUB DE WHATSAPP
        await BitacoraApi.sendWhatsAppNotification(
          studentId: student.id,
          studentName: student.fullName,
          incidentType: widget.incidentType,
          date: widget.date,
        );
      }
    }

    // 3. Registrar el reporte en base de datos oficial
    debugPrint("[SUBMIT EVENT] Registrando reporte oficial...");
    final success = await BitacoraApi.saveOfficialIncidentReport(report);

    // =========================================================================

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        // Regresa el reporte creado a la pantalla principal
        Navigator.pop(context, report);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Mascot warning card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mascot_bitacoras.png',
                  height: 38,
                  width: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.bot, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Revisa la información antes de generar el registro.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Main Preview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tipo de Incidencia
                _buildPreviewSectionHeader("TIPO DE INCIDENCIA"),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE3E3)),
                  ),
                  child: Text(
                    widget.incidentType,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB03B),
                    ),
                  ),
                ),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),

                // 2. Fecha, Hora, Lugar
                _buildPreviewSectionHeader("FECHA Y LUGAR"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetaText(LucideIcons.calendar, widget.date),
                    const SizedBox(width: 16),
                    _buildMetaText(LucideIcons.clock, widget.time),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMetaText(LucideIcons.mapPin, widget.location),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),

                // 3. Estudiantes Involucrados
                _buildPreviewSectionHeader("ESTUDIANTES INVOLUCRADOS"),
                const SizedBox(height: 8),
                if (widget.involvedStudents.isEmpty)
                  const Text(
                    "No se seleccionaron estudiantes.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                  )
                else
                  ...widget.involvedStudents.map((student) {
                    final roleColor = student.role == 'Responsable' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
                    final roleBg = student.role == 'Responsable' ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(student.avatarUrl),
                            onBackgroundImageError: (exception, stackTrace) {},
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1D2848),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        student.role,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: roleColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      student.classroom,
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),

                // 4. Descripción de lo ocurrido
                _buildPreviewSectionHeader("DESCRIPCIÓN DE LO OCURRIDO"),
                const SizedBox(height: 8),
                Text(
                  widget.description.isEmpty
                      ? "Sin descripción provista."
                      : widget.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),

                // 5. Medidas Adoptadas
                _buildPreviewSectionHeader("MEDIDAS ADOPTADAS"),
                const SizedBox(height: 8),
                if (widget.selectedMeasures.isEmpty)
                  const Text(
                    "No se seleccionaron medidas.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                  )
                else ...[
                  ...widget.selectedMeasures.map((measure) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.check, color: Color(0xFF22C55E), size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              measure,
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if ((widget.measureContexts['General'] ?? "").isNotEmpty || (widget.measureFollowUps['General'] ?? "").isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((widget.measureContexts['General'] ?? "").isNotEmpty) ...[
                            Text(
                              "Detalle / Contexto:",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.measureContexts['General']!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                            ),
                          ],
                          if ((widget.measureContexts['General'] ?? "").isNotEmpty && (widget.measureFollowUps['General'] ?? "").isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                            ),
                          if ((widget.measureFollowUps['General'] ?? "").isNotEmpty) ...[
                            Text(
                              "Seguimiento posterior:",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.measureFollowUps['General']!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECCIÓN: NOTIFICACIÓN WHATSAPP ---
          if (widget.involvedStudents.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(LucideIcons.messageCircle, color: Color(0xFF22C55E), size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Notificación por WhatsApp",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Envía automáticamente una notificación y link de seguimiento al padre o apoderado al registrar la bitácora.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  ...widget.involvedStudents.map((student) {
                    return SwitchListTile(
                      value: student.notifyParent,
                      onChanged: (val) => _toggleNotification(student.id, val),
                      title: Text(
                        student.fullName.split(',').last.trim(),
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      subtitle: Text(
                        "Notificar a apoderado de ${student.fullName.split(',').first.trim()}",
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      activeThumbColor: const Color(0xFF22C55E),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // --- SECCIÓN: BOTONES INFERIORES ---
          Row(
            children: [
              // 1. General Edit Button (Takes back to steps)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : widget.onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.edit2, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        "Editar",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 2. Submit Button (Generar Registro Oficial)
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleFinalSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDC620),
                    foregroundColor: const Color(0xFF1D2848),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848)),
                              ),
                            )
                          : const Icon(LucideIcons.check, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _isSubmitting ? "Registrando..." : "Registrar Bitácora",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPreviewSectionHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: const Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildMetaText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
