import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2848),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Alertas Críticas",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF8B4B4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8B4B4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.bellRing,
                      color: Color(0xFFD32F2F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${db.nurseAlerts.length} alertas activas",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD32F2F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Los casos listados requieren monitoreo prioritario por parte del personal de enfermería.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFC0392B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // List of alerts
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.nurseAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = db.nurseAlerts[index];
                final title = alert['title'] as String;
                final student = alert['student'] as String;
                final detail = alert['detail'] as String;
                final time = alert['time'] as String;

                final isAllergy = title.contains('Alergia');

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFF8B4B4), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAllergy ? LucideIcons.shieldAlert : LucideIcons.thermometer,
                            color: const Color(0xFFD32F2F),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                                  children: [
                                    const TextSpan(text: "Alumno: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: student),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                                  children: [
                                    TextSpan(
                                      text: isAllergy ? "Sustancia: " : "Valor: ",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: detail,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isAllergy ? const Color(0xFFC0392B) : const Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 10, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No hay más alertas críticas en el sistema.")),
                  );
                },
                child: const Text(
                  "Ver todas las alertas",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
