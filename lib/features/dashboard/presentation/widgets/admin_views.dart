import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

// ==========================================
// VISTA: AULAS (AdminAulasView)
// ==========================================
class AdminAulasView extends StatelessWidget {
  const AdminAulasView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos algunas secciones de ejemplo
    final List<Map<String, dynamic>> classrooms = [
      {
        "name": "5to de Secundaria A",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 6,
        "subjects": ["Matemática", "Taller de Cálculo"],
        "classroomCode": "Aula 301",
      },
      {
        "name": "5to de Secundaria B",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 4,
        "subjects": ["Matemática"],
        "classroomCode": "Aula 302",
      },
      {
        "name": "4to de Secundaria A",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 8,
        "subjects": ["Física"],
        "classroomCode": "Lab. Física",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classrooms.length,
      itemBuilder: (context, index) {
        final classroom = classrooms[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classroom["name"],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        classroom["classroomCode"],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "Tutor: ${classroom["tutor"]}",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.users, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "Alumnos matriculados: ${classroom["studentsCount"]}",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: (classroom["subjects"] as List<String>).map((subject) {
                    return Chip(
                      label: Text(subject, style: const TextStyle(fontSize: 11, color: Color(0xFF002244), fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFFE2E8F0).withOpacity(0.5),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// VISTA: ASISTENCIA GENERAL (AdminAttendanceView)
// ==========================================
class AdminAttendanceView extends StatelessWidget {
  const AdminAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();

    // Sumar estadísticas rápidas
    final all5toA = db.students5toA;
    final all5toB = db.students5toB;

    int present5toA = all5toA.where((s) => s.attendanceStatus == 'Presente').length;
    int absent5toA = all5toA.where((s) => s.attendanceStatus == 'Falta').length;
    int tardy5toA = all5toA.where((s) => s.attendanceStatus == 'Tardanza').length;

    int present5toB = all5toB.where((s) => s.attendanceStatus == 'Presente').length;
    int absent5toB = all5toB.where((s) => s.attendanceStatus == 'Falta').length;
    int tardy5toB = all5toB.where((s) => s.attendanceStatus == 'Tardanza').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          const Text(
            "Reporte Diario de Asistencia",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const Text(
            "Resumen consolidado de hoy para todas las secciones",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Secciones de Asistencia
          _buildAttendanceProgressCard(
            title: "5to de Secundaria - Sección A",
            present: present5toA,
            absent: absent5toA,
            tardy: tardy5toA,
            total: all5toA.length,
          ),
          const SizedBox(height: 12),
          _buildAttendanceProgressCard(
            title: "5to de Secundaria - Sección B",
            present: present5toB,
            absent: absent5toB,
            tardy: tardy5toB,
            total: all5toB.length,
          ),
          const SizedBox(height: 20),

          // Alumnos con faltas registradas hoy
          const Text(
            "Inasistencias del Día",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC0392B)),
          ),
          const SizedBox(height: 10),
          _buildAbsentList(db),
        ],
      ),
    );
  }

  Widget _buildAttendanceProgressCard({
    required String title,
    required int present,
    required int absent,
    required int tardy,
    required int total,
  }) {
    final double percent = total > 0 ? (present + tardy) / total : 0;
    final percentStr = (percent * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002244))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: percent > 0.85 ? const Color(0xFF10B981) : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$percentStr%",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIndicatorBadge("Presentes", present, const Color(0xFF10B981)),
                _buildIndicatorBadge("Tardanzas", tardy, Colors.amber),
                _buildIndicatorBadge("Faltas", absent, const Color(0xFFC0392B)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorBadge(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Text(
          "$value",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
      ],
    );
  }

  Widget _buildAbsentList(MockDatabase db) {
    final List<Student> absentStudents = [];
    absentStudents.addAll(db.students5toA.where((s) => s.attendanceStatus == 'Falta'));
    absentStudents.addAll(db.students5toB.where((s) => s.attendanceStatus == 'Falta'));

    if (absentStudents.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "¡Hoy no se registran faltas!",
              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: absentStudents.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final student = absentStudents[index];
          final String aula = db.students5toA.contains(student) ? "5to A" : "5to B";
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student.avatarUrl),
            ),
            title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002244))),
            subtitle: Text("Sección: $aula", style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "FALTA",
                style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          );
        },
      ),
    );
  }
}
