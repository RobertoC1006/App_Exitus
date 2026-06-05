import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';
import '../widgets/step_incident_type.dart';
import '../widgets/step_involved_students.dart';
import '../widgets/step_description_ai.dart';
import '../widgets/step_measures.dart';
import '../widgets/step_preview.dart';

class NewBitacoraFlow extends StatefulWidget {
  const NewBitacoraFlow({super.key});

  @override
  State<NewBitacoraFlow> createState() => _NewBitacoraFlowState();
}

class _NewBitacoraFlowState extends State<NewBitacoraFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 a 4

  // Form State
  String _incidentType = "Conductual";
  List<InvolvedStudent> _involvedStudents = [];
  String _date = "";
  String _time = "";
  String _location = "";
  String _description = "";
  List<String> _selectedMeasures = [];
  Map<String, String> _measureContexts = {};
  Map<String, String> _measureFollowUps = {};

  @override
  void initState() {
    super.initState();
    _initDateTime();
  }

  void _initDateTime() {
    final now = DateTime.now();
    // Formatear Fecha: dd/mm/yyyy
    _date = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    
    // Formatear Hora: hh:mm am/pm
    final period = now.hour >= 12 ? "p. m." : "a. m.";
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    _time = "$hour:$minute $period";
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool _isStepValid() {
    if (_currentStep == 1) {
      // Paso 2: Involucrados. Debe haber al menos 1 estudiante seleccionado y lugar especificado
      return _involvedStudents.isNotEmpty && _location.trim().isNotEmpty;
    }
    if (_currentStep == 2) {
      // Paso 3: Descripción. Debe haber algo de texto
      return _description.trim().isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848), size: 18),
            onPressed: () {
              if (_currentStep > 0) {
                _prevPage();
              } else {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          _currentStep == 4 ? "Vista Previa" : "Nueva Bitácora",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // 1. Indicador de Progreso Superior
            _buildProgressIndicator(),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 2. Step Viewport
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    // Paso 1: Tipo de Incidencia (Index 0)
                    StepIncidentType(
                      selectedType: _incidentType,
                      onTypeSelected: (type) {
                        setState(() {
                          _incidentType = type;
                        });
                        _nextPage(); // Auto-avanza al seleccionar
                      },
                      onCancel: () => Navigator.pop(context),
                    ),

                    // Paso 2: Estudiantes & Lugar (Index 1)
                    StepInvolvedStudents(
                      selectedStudents: _involvedStudents,
                      onStudentsChanged: (list) {
                        setState(() {
                          _involvedStudents = list;
                        });
                      },
                      date: _date,
                      onDateChanged: (val) => setState(() => _date = val),
                      time: _time,
                      onTimeChanged: (val) => setState(() => _time = val),
                      location: _location,
                      onLocationChanged: (val) => setState(() => _location = val),
                    ),

                    // Paso 3: Descripción & IA (Index 2)
                    StepDescriptionAI(
                      description: _description,
                      onDescriptionChanged: (val) {
                        setState(() {
                          _description = val;
                        });
                      },
                      incidentType: _incidentType,
                    ),

                    // Paso 4: Medidas Adoptadas (Index 3)
                    StepMeasures(
                      selectedMeasures: _selectedMeasures,
                      onMeasuresChanged: (list) {
                        setState(() {
                          _selectedMeasures = list;
                        });
                      },
                      measureContexts: _measureContexts,
                      onContextsChanged: (map) {
                        setState(() {
                          _measureContexts = map;
                        });
                      },
                      measureFollowUps: _measureFollowUps,
                      onFollowUpsChanged: (map) {
                        setState(() {
                          _measureFollowUps = map;
                        });
                      },
                    ),

                    // Paso 5: Vista Previa final (Index 4)
                    StepPreview(
                      incidentType: _incidentType,
                      involvedStudents: _involvedStudents,
                      onStudentsChanged: (list) {
                        setState(() {
                          _involvedStudents = list;
                        });
                      },
                      date: _date,
                      time: _time,
                      location: _location,
                      description: _description,
                      selectedMeasures: _selectedMeasures,
                      measureContexts: _measureContexts,
                      measureFollowUps: _measureFollowUps,
                      onEdit: () => _goToPage(0), // Regresa al paso 1
                      onSubmit: () {}, // Handled internally by widget
                    ),
                  ],
                ),
              ),
            ),

            // 3. Navigation Bar (Atrás / Siguiente) - only visible for steps 1, 2, 3
            if (_currentStep > 0 && _currentStep < 4)
              _buildNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStepNode(1, "Tipo"),
          _buildStepLine(1),
          _buildStepNode(2, "Personas"),
          _buildStepLine(2),
          _buildStepNode(3, "Detalles"),
          _buildStepLine(3),
          _buildStepNode(4, "Medidas"),
          _buildStepLine(4),
          _buildStepNode(5, "Resumen"),
        ],
      ),
    );
  }

  Widget _buildStepNode(int step, String label) {
    final stepIndex = step - 1;
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF1E88E5)
                  : (isActive ? const Color(0xFF1D2848) : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(
                      color: isActive ? const Color(0xFF1D2848) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                : Text(
                    "$step",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF1D2848)
                  : (isCompleted ? const Color(0xFF1E88E5) : const Color(0xFF94A3B8)),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final stepIndex = afterStep - 1;
    final isCompleted = _currentStep > stepIndex;
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildNavigationFooter() {
    final isValid = _isStepValid();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prevPage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Text(
                "Atrás",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isValid ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Siguiente",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
