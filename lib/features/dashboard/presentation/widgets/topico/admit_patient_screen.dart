import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class AdmitPatientScreen extends StatefulWidget {
  const AdmitPatientScreen({super.key});

  @override
  State<AdmitPatientScreen> createState() => _AdmitPatientScreenState();
}

class _AdmitPatientScreenState extends State<AdmitPatientScreen> {
  final MockDatabase _db = MockDatabase();
  bool _isFormView = true; // true: Form editing (Step 1), false: Review/Submit (Step 2)

  // Search variables
  final TextEditingController _searchController = TextEditingController();
  List<Student> _searchResults = [];
  Student? _selectedStudent;

  // Motivo variables
  String _selectedReason = "";
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, dynamic>> _reasonsList = [
    {
      'label': 'Dolor de cabeza',
      'color': const Color(0xFF6366F1), // Indigo
      'selectedBg': const Color(0xFFEEF2FF),
    },
    {
      'label': 'Dolor estomacal',
      'color': const Color(0xFFEF4444), // Red
      'selectedBg': const Color(0xFFFEF2F2),
    },
    {
      'label': 'Golpe / Caída',
      'color': const Color(0xFFF97316), // Orange
      'selectedBg': const Color(0xFFFFF7ED),
    },
    {
      'label': 'Fiebre',
      'color': const Color(0xFFEC4899), // Pink
      'selectedBg': const Color(0xFFFCE7F3),
    },
    {
      'label': 'Malestar general',
      'color': const Color(0xFFF97316), // Orange
      'selectedBg': const Color(0xFFFFF7ED),
    },
    {
      'label': 'Otro motivo',
      'color': const Color(0xFF64748B), // Grey
      'selectedBg': const Color(0xFFF8FAFC),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<Student> _getAllStudentsList() {
    return [
      ..._db.students5toA,
      ..._db.students5toB,
      Student(
        id: 's101',
        fullName: 'Juan Pérez Romero',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
      ),
      Student(
        id: 's102',
        fullName: 'Ana Torres Medina',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      ),
      Student(
        id: 's103',
        fullName: 'Diego Ramos León',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      ),
    ];
  }

  String _getStudentGrade(Student student) {
    if (student.id == 's101') return '4° A Secundaria';
    if (student.id == 's7' || student.id == 's8' || student.id == 's9' || student.id == 's10') {
      return '5° B Secundaria';
    }
    return '5° A Secundaria';
  }

  String _getStudentDni(Student student) {
    if (student.id == 's101') return '76543210';
    if (student.id.startsWith('s')) {
      final sub = student.id.substring(1);
      return '7654321$sub';
    }
    return '76543210';
  }

  void _onSearchChanged() {
    if (_selectedStudent != null) return;

    final query = _searchController.text.trim().toLowerCase();
    final allStudents = _getAllStudentsList();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final filtered = allStudents.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _searchResults = filtered;
    });
  }

  void _selectStudent(Student student) {
    setState(() {
      _selectedStudent = student;
      _searchResults = [];
      _searchController.text = student.fullName;
    });
    FocusScope.of(context).unfocus();
  }

  void _nextStep() {
    if (_isFormView) {
      if (_selectedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, busque y seleccione un alumno.")),
        );
        return;
      }
      if (_selectedReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, seleccione un motivo de consulta.")),
        );
        return;
      }
      setState(() {
        _isFormView = false;
      });
    } else {
      _registerAdmission();
    }
  }

  void _registerAdmission() {
    if (_selectedStudent == null || _selectedReason.isEmpty) return;

    final newPatient = {
      'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
      'name': _selectedStudent!.fullName,
      'grade': _getStudentGrade(_selectedStudent!),
      'avatar': _selectedStudent!.avatarUrl,
      'reason': _selectedReason,
      'time': 'Hace un momento',
      'entryTime': _formatCurrentTime(),
      'dni': _getStudentDni(_selectedStudent!),
      'description': _descController.text.trim(),
    };

    // Agregar a la lista de pacientes en espera
    _db.nurseWaitingPatients.insert(0, newPatient);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Alumno ${_selectedStudent!.fullName} admitido con éxito.",
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

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'p. m.' : 'a. m.';
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848)),
          onPressed: () {
            if (!_isFormView) {
              setState(() {
                _isFormView = true;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Admitir Paciente",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2848)),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: Column(
        children: [
          // Indicador de Pasos (2 pasos: Formulario -> Registrar)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepIndicator(0, "Datos y Motivo"),
                _buildStepConnector(),
                _buildStepIndicator(1, "Registrar"),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _isFormView ? _buildFormViewContent() : _buildPreviewContent(),
            ),
          ),

          // Footer de Navegación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isFormView) ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isFormView = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1D2848),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Atrás", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                ],
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isFormView ? const Color(0xFF2E7D32) : const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          !_isFormView ? "REGISTRAR INGRESO" : "Siguiente",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          !_isFormView ? LucideIcons.check : LucideIcons.arrowRight,
                          size: 16,
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

  Widget _buildStepIndicator(int stepIndex, String title) {
    bool isActive = false;
    bool isCompleted = false;

    if (_isFormView) {
      if (stepIndex == 0) {
        isActive = true;
      }
    } else {
      if (stepIndex == 0) {
        isCompleted = true;
      } else if (stepIndex == 1) {
        isActive = true;
      }
    }

    Color color = const Color(0xFF94A3B8);
    Widget icon = Text(
      "${stepIndex + 1}",
      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
    );

    if (isActive) {
      color = const Color(0xFF4F46E5);
    } else if (isCompleted) {
      color = const Color(0xFF2E7D32);
      icon = const Icon(LucideIcons.check, color: Colors.white, size: 12);
    }

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    final isCompleted = !_isFormView;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 2,
        color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildFormViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Buscar Alumno",
          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Buscar por nombre o DNI...",
            suffixIcon: _selectedStudent != null || _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedStudent = null;
                        _searchResults = [];
                      });
                    },
                  )
                : const Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
          ),
        ),
        
        // Search dropdown results
        if (_selectedStudent == null && _searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final student = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(student.avatarUrl),
                  ),
                  title: Text(
                    student.fullName,
                    style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  ),
                  subtitle: Text(
                    _getStudentGrade(student),
                    style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B)),
                  ),
                  onTap: () => _selectStudent(student),
                );
              },
            ),
          ),
        ],
        
        if (_selectedStudent != null) ...[
          const SizedBox(height: 16),
          Text(
            "Alumno encontrado",
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(_selectedStudent!.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStudent!.fullName,
                          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStudentGrade(_selectedStudent!),
                          style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "DNI: ${_getStudentDni(_selectedStudent!)}",
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Text(
          "Seleccione el motivo",
          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemCount: _reasonsList.length,
          itemBuilder: (context, index) {
            final reason = _reasonsList[index];
            final isSelected = _selectedReason == reason['label'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedReason = reason['label'];
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D2848).withValues(alpha: 0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildReasonIcon(reason['label'], reason['color'], isSelected),
                    const SizedBox(height: 10),
                    Text(
                      reason['label'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          "Descripción breve (opcional)",
          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          maxLength: 150,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: "Escribe aquí los detalles...",
            counterStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Resumen de Admisión",
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(_selectedStudent!.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStudent!.fullName,
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStudentGrade(_selectedStudent!),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                
                _buildSummaryRow(LucideIcons.activity, "Motivo", _selectedReason, const Color(0xFFEF4444)),
                const SizedBox(height: 12),
                _buildSummaryRow(LucideIcons.calendar, "Fecha de ingreso", "Hoy (05/06/2026)", const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                _buildSummaryRow(LucideIcons.clock, "Hora estimada", _formatCurrentTime(), const Color(0xFFF59E0B)),
                
                if (_descController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 16),
                  CrossAxisAlignmentColumn(
                    label: "Detalles / Observaciones",
                    content: _descController.text.trim(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
          ),
        ),
      ],
    );
  }
}

class CrossAxisAlignmentColumn extends StatelessWidget {
  final String label;
  final String content;

  const CrossAxisAlignmentColumn({
    super.key,
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF1D2848)),
          ),
        ),
      ],
    );
  }
}

// ================= Custom Icons for Motives =================

class StomachIcon extends StatelessWidget {
  final Color color;
  final double size;

  const StomachIcon({
    super.key,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StomachPainter(color: color),
      ),
    );
  }
}

class _StomachPainter extends CustomPainter {
  final Color color;

  _StomachPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // We draw the esophagus (top tube)
    path.moveTo(w * 0.45, h * 0.1);
    path.lineTo(w * 0.45, h * 0.22);

    // Left bulge (greater curvature)
    path.cubicTo(
      w * 0.15, h * 0.22,
      w * 0.05, h * 0.75,
      w * 0.45, h * 0.85,
    );

    // Duodenum exit (bottom right)
    path.cubicTo(
      w * 0.65, h * 0.9,
      w * 0.85, h * 0.75,
      w * 0.8, h * 0.55,
    );
    path.lineTo(w * 0.68, h * 0.52);

    // Lesser curvature (inner right curve)
    path.cubicTo(
      w * 0.62, h * 0.62,
      w * 0.55, h * 0.48,
      w * 0.55, h * 0.22,
    );
    path.lineTo(w * 0.55, h * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrossedBandageIcon extends StatelessWidget {
  final Color color;
  final double size;

  const CrossedBandageIcon({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CrossedBandagePainter(color: color),
      ),
    );
  }
}

class _CrossedBandagePainter extends CustomPainter {
  final Color color;

  _CrossedBandagePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final paintPad = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // First bandage (rotated -45 deg)
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(-0.785); // -45 deg in rad
    final rrect1 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.8, height: h * 0.24),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(rrect1, paint);
    canvas.drawLine(Offset(-w * 0.12, -h * 0.12), Offset(-w * 0.12, h * 0.12), paintPad);
    canvas.drawLine(Offset(w * 0.12, -h * 0.12), Offset(w * 0.12, h * 0.12), paintPad);
    canvas.restore();

    // Second bandage (rotated 45 deg)
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(0.785); // 45 deg in rad
    final rrect2 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.8, height: h * 0.24),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(rrect2, paint);
    canvas.drawLine(Offset(-w * 0.12, -h * 0.12), Offset(-w * 0.12, h * 0.12), paintPad);
    canvas.drawLine(Offset(w * 0.12, -h * 0.12), Offset(w * 0.12, h * 0.12), paintPad);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MoreCircleIcon extends StatelessWidget {
  final Color color;
  final double size;

  const MoreCircleIcon({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoreCirclePainter(color: color),
      ),
    );
  }
}

class _MoreCirclePainter extends CustomPainter {
  final Color color;

  _MoreCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final w = size.width;
    final h = size.height;

    // Draw outer circle
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.4, paint);

    // Draw three dots in the center
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.35, h / 2), w * 0.05, dotPaint);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.05, dotPaint);
    canvas.drawCircle(Offset(w * 0.65, h / 2), w * 0.05, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Icon helper builder
Widget _buildReasonIcon(String label, Color color, bool isSelected) {
  final iconColor = isSelected ? const Color(0xFF4F46E5) : color;
  const double iconSize = 32.0;

  switch (label) {
    case 'Dolor de cabeza':
      return Icon(LucideIcons.brain, color: iconColor, size: iconSize);
    case 'Dolor estomacal':
      return StomachIcon(color: iconColor, size: iconSize);
    case 'Golpe / Caída':
      return CrossedBandageIcon(color: iconColor, size: iconSize);
    case 'Fiebre':
      return Transform.rotate(
        angle: -0.4,
        child: Icon(LucideIcons.thermometer, color: iconColor, size: iconSize),
      );
    case 'Malestar general':
      return Icon(LucideIcons.frown, color: iconColor, size: iconSize);
    case 'Otro motivo':
      return MoreCircleIcon(color: iconColor, size: iconSize);
    default:
      return Icon(LucideIcons.helpCircle, color: iconColor, size: iconSize);
  }
}
