import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';

class StepInvolvedStudents extends StatefulWidget {
  final List<InvolvedStudent> selectedStudents;
  final ValueChanged<List<InvolvedStudent>> onStudentsChanged;
  final String date;
  final ValueChanged<String> onDateChanged;
  final String time;
  final ValueChanged<String> onTimeChanged;
  final String location;
  final ValueChanged<String> onLocationChanged;

  const StepInvolvedStudents({
    super.key,
    required this.selectedStudents,
    required this.onStudentsChanged,
    required this.date,
    required this.onDateChanged,
    required this.time,
    required this.onTimeChanged,
    required this.location,
    required this.onLocationChanged,
  });

  @override
  State<StepInvolvedStudents> createState() => _StepInvolvedStudentsState();
}

class _StepInvolvedStudentsState extends State<StepInvolvedStudents> {
  String _searchQuery = "";
  final TextEditingController _locationController = TextEditingController();

  // Lista mock de todos los alumnos de 4° B
  final List<Map<String, String>> _allMockStudents = [
    {
      'id': 's_luis',
      'name': 'Luis Valdiviezo Whitehead',
      'avatar': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
      'classroom': 'Aula 4° B',
    },
    {
      'id': 's_bryana',
      'name': 'Bryana Alama Eca',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      'classroom': 'Aula 4° B',
    },
    {
      'id': 's_maria',
      'name': 'María Torres Salazar',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      'classroom': 'Aula 4° B',
    },
    {
      'id': 's_jose',
      'name': 'José Pérez Quispe',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      'classroom': 'Aula 4° B',
    },
    {
      'id': 's_santiago',
      'name': 'Santiago Rojas Díaz',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      'classroom': 'Aula 4° B',
    },
  ];

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location;
  }

  @override
  void didUpdateWidget(covariant StepInvolvedStudents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location && widget.location != _locationController.text) {
      _locationController.text = widget.location;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D2848),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D2848),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      widget.onDateChanged(formattedDate);
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D2848),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D2848),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final period = picked.period == DayPeriod.am ? "a. m." : "p. m.";
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final formattedTime = "$hour:$minute $period";
      widget.onTimeChanged(formattedTime);
    }
  }

  void _toggleStudent(Map<String, String> studentData) {
    final List<InvolvedStudent> list = List.from(widget.selectedStudents);
    final index = list.indexWhere((s) => s.id == studentData['id']);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(
        InvolvedStudent(
          id: studentData['id']!,
          fullName: studentData['name']!,
          avatarUrl: studentData['avatar']!,
          classroom: studentData['classroom']!,
          role: 'Responsable', // Rol por defecto
        ),
      );
    }

    widget.onStudentsChanged(list);
  }

  void _updateStudentRole(String id, String role) {
    final List<InvolvedStudent> list = widget.selectedStudents.map((s) {
      if (s.id == id) {
        return s.copyWith(role: role);
      }
      return s;
    }).toList();
    widget.onStudentsChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _allMockStudents.where((s) {
      return s['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            "¿Quiénes estuvieron involucrados?",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Selecciona los estudiantes participantes e ingresa los detalles del lugar.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // --- SECCIÓN: DATOS DEL SUCESO ---
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
                Text(
                  "DATOS DE CONTEXTO",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Fecha",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.date,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hora",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.time,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
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
                const SizedBox(height: 14),
                const Text(
                  "Lugar del Incidente",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _locationController,
                  onChanged: (val) {
                    widget.onLocationChanged(val);
                  },
                  decoration: InputDecoration(
                    hintText: "Ej. Aula 4° B, Patio, Pasadizos",
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECCIÓN: INVOLUCRADOS ---
          // Buscador
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Buscar estudiante...",
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848)),
          ),
          const SizedBox(height: 16),

          // Chips de seleccionados
          if (widget.selectedStudents.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Seleccionados (${widget.selectedStudents.length})",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onStudentsChanged([]),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text(
                    "Limpiar",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedStudents.map((student) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(student.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  label: Text(
                    student.fullName.split(',').last.trim(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                  ),
                  backgroundColor: const Color(0xFFEFF6FF),
                  deleteIcon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF1D2848)),
                  onDeleted: () {
                    final list = List<InvolvedStudent>.from(widget.selectedStudents);
                    list.removeWhere((s) => s.id == student.id);
                    widget.onStudentsChanged(list);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFDBEAFE)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Lista de Estudiantes
          Text(
            "Todos los estudiantes (4º B)",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredStudents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final studentData = filteredStudents[index];
              final isChecked = widget.selectedStudents.any((s) => s.id == studentData['id']);
              final selectedStudent = widget.selectedStudents.firstWhere(
                (s) => s.id == studentData['id'],
                orElse: () => InvolvedStudent(id: '', fullName: '', avatarUrl: '', classroom: ''),
              );

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isChecked ? const Color(0xFF1D2848) : const Color(0xFFE2E8F0),
                    width: isChecked ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => _toggleStudent(studentData),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(studentData['avatar']!),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: const Icon(LucideIcons.user, size: 20, color: Color(0xFF94A3B8)),
                      ),
                    title: Text(
                      studentData['name']!,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "Aula actual: ${studentData['classroom']}",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                    trailing: Checkbox(
                      value: isChecked,
                      onChanged: (val) => _toggleStudent(studentData),
                      activeColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  // Acordeón / Desplegable si está seleccionado
                  if (isChecked)
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            const Text(
                              "Selecciona el rol de este estudiante:",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2848),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildRoleChip(
                                  studentId: selectedStudent.id,
                                  roleName: 'Responsable',
                                  currentRole: selectedStudent.role,
                                  icon: LucideIcons.alertTriangle,
                                  color: const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 8),
                                _buildRoleChip(
                                  studentId: selectedStudent.id,
                                  roleName: 'Afectado',
                                  currentRole: selectedStudent.role,
                                  icon: LucideIcons.user,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRoleChip({
    required String studentId,
    required String roleName,
    required String currentRole,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = currentRole == roleName;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(
        roleName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : const Color(0xFF1D2848),
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.white,
      onSelected: (val) {
        if (val) {
          _updateStudentRole(studentId, roleName);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
