import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class AuditoriaScreen extends StatelessWidget {
  const AuditoriaScreen({super.key});

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
          "Auditoría Legal",
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
            // Security status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5CAE9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC5CAE9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: Color(0xFF3F51B5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Registros Protegidos",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Trazabilidad y seguridad garantizada mediante blockchain y firma digital legal.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF303F9F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logs list header
            Text(
              "Últimos Registros Clínicos Firmados",
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            // List of audit items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.nurseAuditLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = db.nurseAuditLogs[index];
                final id = log['id'] as String;
                final student = log['student'] as String;
                final date = log['date'] as String;
                final time = log['time'] as String;
                final status = log['status'] as String;

                final isSigned = status == 'Firmado';

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSigned ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSigned ? LucideIcons.lock : LucideIcons.unlock,
                        color: isSigned ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        size: 16,
                      ),
                    ),
                    title: Text(
                      "Atención #$id",
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          student,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$date - $time",
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSigned ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isSigned ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    onTap: () => _showAuditDetailModal(context, id, student, date, time, status),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Accediendo al panel general de auditoría (Simulación)")),
                  );
                },
                child: const Text(
                  "Ver auditoría completa",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuditDetailModal(BuildContext context, String id, String student, String date, String time, String status) {
    showDialog(
      context: context,
      builder: (context) {
        final dummyHash = "SHA256: 8f2371b28c8378d${id}f5a9e38d721b045e890c2394efbd${id}5e12f00a5d";

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comprobante Digital",
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16),
                const SizedBox(height: 10),
                
                _buildReceiptRow("ID Registro", "#$id"),
                _buildReceiptRow("Paciente", student),
                _buildReceiptRow("Fecha", date),
                _buildReceiptRow("Hora de Cierre", time),
                _buildReceiptRow("Estado Firma", status),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                Text(
                  "HASH CRIPTOGRÁFICO DE SEGURIDAD",
                  style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dummyHash,
                    style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(LucideIcons.shieldCheck, color: Color(0xFF2E7D32), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Este registro ha sido firmado con el certificado digital de enfermería del colegio Exitus.",
                          style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
          ),
        ],
      ),
    );
  }
}
