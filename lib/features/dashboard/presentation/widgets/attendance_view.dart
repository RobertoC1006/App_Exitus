import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/core/theme/app_theme.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final _db = MockDatabase();
  String _selectedCourse = 'Matemática - 5to A';
  List<Student> _students = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    // Clonamos la lista de alumnos para modificarla localmente antes de guardar
    final originalList = _db.getStudentsForCourse(_selectedCourse);
    setState(() {
      _students = originalList.map((s) => Student(
        id: s.id,
        fullName: s.fullName,
        avatarUrl: s.avatarUrl,
        attendanceStatus: s.attendanceStatus,
      )).toList();
    });
  }

  void _updateStatus(String studentId, String status) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index].attendanceStatus = status;
      }
    });
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simula retraso de red
    await Future.delayed(const Duration(milliseconds: 1000));

    // Guarda los cambios en la base de datos simulada en memoria
    _db.saveAttendance(_selectedCourse, _students);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle, color: Colors.white),
              const SizedBox(width: 8),
              Text('¡Asistencia de $_selectedCourse guardada con éxito!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Selector de Curso
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Seleccionar Curso",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF002244),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCourse,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF002244)),
                    items: const [
                      DropdownMenuItem(
                        value: 'Matemática - 5to A',
                        child: Text('Matemática - 5to de Secundaria A'),
                      ),
                      DropdownMenuItem(
                        value: 'Matemática - 5to B',
                        child: Text('Matemática - 5to de Secundaria B'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCourse = val;
                          _loadStudents();
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // 2. Lista de Alumnos
        Expanded(
          child: _students.isEmpty
              ? const Center(child: Text("No hay alumnos en esta sección"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(student.avatarUrl),
                            radius: 20,
                            backgroundColor: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              student.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF002244),
                              ),
                            ),
                          ),
                          // Botones de Asistencia
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusButton('Asiste', 'A', const Color(0xFF2E7D32), student),
                              const SizedBox(width: 6),
                              _buildStatusButton('Tardanza', 'T', const Color(0xFFEF6C00), student),
                              const SizedBox(width: 6),
                              _buildStatusButton('Falta', 'F', const Color(0xFFC62828), student),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // 3. Botón de Guardado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002244),
              disabledBackgroundColor: const Color(0xFF002244).withValues(alpha: 0.6),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.check, size: 18),
                      SizedBox(width: 8),
                      Text("GUARDAR ASISTENCIA"),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String status, String letter, Color color, Student student) {
    final isSelected = student.attendanceStatus == status;
    return GestureDetector(
      onTap: () => _updateStatus(student.id, status),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade400, width: 1.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
