import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitacionFormScreen extends StatefulWidget {
  final PrintRequest? request;
  final VoidCallback onSaved;

  const DigitacionFormScreen({super.key, this.request, required this.onSaved});

  @override
  State<DigitacionFormScreen> createState() => _DigitacionFormScreenState();
}

class _DigitacionFormScreenState extends State<DigitacionFormScreen> {
  final MockDatabase _db = MockDatabase();
  
  int _currentStep = 1; // 1: Documento, 2: Producción, 3: Destino, 4: Entrega

  // Paso 1: Detalles del documento
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _uploadedFileName = '';
  double _uploadedFileSizeMB = 0.0;

  // Paso 2: Especificaciones de producción
  String _colorMode = 'b/n'; // 'b/n', 'color'
  String _paperSize = 'A4'; // 'A4', 'Oficio', 'Otro'

  // Paso 3: Destino del material
  String _selectedNivel = 'Secundaria';
  String _selectedGrado = '4°';
  String _selectedSeccion = 'A';
  late TextEditingController _copiesController;

  // Paso 4: Logística de entrega
  late TextEditingController _limitDateController;
  String _selectedFinish = 'Suelto'; // 'Anillado', 'Engrapado', 'Suelto'
  late TextEditingController _obsController;

  // Opciones de Dropdowns
  final List<String> _niveles = ['Inicial', 'Primaria', 'Secundaria'];
  final Map<String, List<String>> _gradosPorNivel = {
    'Inicial': ['3 años', '4 años', '5 años'],
    'Primaria': ['1°', '2°', '3°', '4°', '5°', '6°'],
    'Secundaria': ['1°', '2°', '3°', '4°', '5°'],
  };
  final List<String> _secciones = ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.request?.title ?? '');
    _descController = TextEditingController(text: widget.request?.description ?? '');
    _copiesController = TextEditingController(
      text: widget.request?.classrooms.isNotEmpty == true
          ? widget.request!.classrooms.first.copies.toString()
          : '35',
    );
    _limitDateController = TextEditingController(text: widget.request?.limitDate ?? '25 / 05 / 2024');
    _obsController = TextEditingController(text: widget.request?.instructions ?? '');

    if (widget.request != null) {
      _colorMode = widget.request!.colorMode;
      _paperSize = widget.request!.paperSize;
      _uploadedFileName = widget.request!.file;
      _uploadedFileSizeMB = 2.4;
      _selectedFinish = widget.request!.finish;

      // Intentar parsear el aula de destino
      if (widget.request!.classrooms.isNotEmpty) {
        final targetName = widget.request!.classrooms.first.name;
        // Ej: "4° Secundaria A"
        for (var n in _niveles) {
          if (targetName.contains(n)) {
            _selectedNivel = n;
            break;
          }
        }
        final listGrados = _gradosPorNivel[_selectedNivel] ?? [];
        for (var g in listGrados) {
          if (targetName.startsWith(g)) {
            _selectedGrado = g;
            break;
          }
        }
        for (var s in _secciones) {
          if (targetName.endsWith(s)) {
            _selectedSeccion = s;
            break;
          }
        }
      }
    } else {
      _selectedGrado = _gradosPorNivel[_selectedNivel]!.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _copiesController.dispose();
    _limitDateController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _pickMockFile() {
    setState(() {
      _uploadedFileName = "Examen_${_titleController.text.isNotEmpty ? _titleController.text.trim().replaceAll(' ', '_') : 'Material'}.pdf";
      _uploadedFileSizeMB = Random().nextDouble() * 5 + 1.2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Archivo adjuntado con éxito: $_uploadedFileName"),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        _limitDateController.text = "$day / $month / $year";
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("El título del documento es obligatorio."), backgroundColor: Color(0xFFD32F2F)),
        );
        return;
      }
      if (_uploadedFileName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe adjuntar un archivo PDF."), backgroundColor: Color(0xFFD32F2F)),
        );
        return;
      }
    } else if (_currentStep == 3) {
      final copies = int.tryParse(_copiesController.text) ?? 0;
      if (copies <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La cantidad de ejemplares debe ser mayor a 0."), backgroundColor: Color(0xFFD32F2F)),
        );
        return;
      }
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _saveForm() {
    // Validar el paso 4
    if (_limitDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La fecha límite es obligatoria."), backgroundColor: Color(0xFFD32F2F)),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final limitDate = _limitDateController.text.trim();
    final instructions = _obsController.text.trim();
    final copies = int.tryParse(_copiesController.text) ?? 35;

    // Crear el nombre del aula destino concatenado
    // Ej: "4° Secundaria A"
    final targetClassroom = "$_selectedGrado $_selectedNivel $_selectedSeccion";
    final classroomTargets = [
      PrintClassroomTarget(name: targetClassroom, copies: copies)
    ];

    if (widget.request != null) {
      // Editar
      final updated = PrintRequest(
        id: widget.request!.id,
        ticketNumber: widget.request!.ticketNumber,
        title: title,
        description: description,
        requester: widget.request!.requester,
        date: widget.request!.date,
        colorMode: _colorMode,
        paperSize: _paperSize,
        status: widget.request!.status,
        classrooms: classroomTargets,
        file: _uploadedFileName,
        limitDate: limitDate,
        instructions: instructions,
        finish: _selectedFinish,
      );
      _db.updatePrintRequest(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Solicitud #${widget.request!.ticketNumber} guardada con éxito"),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else {
      // Crear
      final nextId = _db.getPrintRequests().isEmpty
          ? 1048
          : _db.getPrintRequests().map((j) => j.id).reduce(max) + 1;
      final ticketNum = "DG-$nextId";

      final newReq = PrintRequest(
        id: nextId,
        ticketNumber: ticketNum,
        title: title,
        description: description,
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "01 Jun 2026", // Fecha simulada actual
        colorMode: _colorMode,
        paperSize: _paperSize,
        status: "pending",
        classrooms: classroomTargets,
        file: _uploadedFileName,
        limitDate: limitDate,
        instructions: instructions,
        finish: _selectedFinish,
      );

      _db.addPrintRequest(newReq);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Solicitud #$ticketNum creada correctamente"),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );

      // Simulación de Luis Gonzaga: 6 segundos de delay
      Timer(const Duration(seconds: 6), () {
        final newMsgId = 'msg_lg_${Random().nextInt(10000)}';
        
        final mockMsg = InboxMessage(
          id: newMsgId,
          sender: "Luis Gonzaga",
          subject: "[Digitación] Solicitud #$ticketNum Registrada",
          date: "Hoy",
          snippet: "Confirmación de recepción de ticket #$ticketNum para impresiones...",
          content: "Hola Nicole,\n\nHemos recibido correctamente su solicitud de digitación #$ticketNum para el documento \"$title\". El trabajo ha sido asignado al centro de producción con estado PENDIENTE.\n\nDetalles:\n- Curso/Sección: $targetClassroom\n- Copias: $copies\n- Modo: ${_colorMode == 'b/n' ? 'Blanco y negro' : 'A color'} ($_paperSize)\n- Acabado: $_selectedFinish\n- Fecha límite requerida: $limitDate\n\nAtentamente,\nLuis Gonzaga - Coordinación de Producción.",
          unread: true,
          urgent: false,
        );

        _db.adminMessages.insert(0, mockMsg);

        // Notificación flotante
        if (Navigator.of(context).canPop()) {
          // Si estamos en la app
        }
      });
    }

    widget.onSaved();
    Navigator.pop(context);
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
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          "Nueva solicitud",
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

            // 2. Contenido del paso actual
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildStepContent(),
              ),
            ),

            // 3. Botones de Navegación Inferiores
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Widget para construir el indicador de progreso (Step Tracker)
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepNode(1, "Documento"),
              _buildStepLine(1),
              _buildStepNode(2, "Producción"),
              _buildStepLine(2),
              _buildStepNode(3, "Destino"),
              _buildStepLine(3),
              _buildStepNode(4, "Entrega"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

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
    final isCompleted = _currentStep > afterStep;
    return Container(
      width: 18,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
    );
  }

  // Renderizar el contenido según el paso actual
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // Paso 1: Detalles del documento
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Detalles del documento",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 20),

        // Campo Título
        Row(
          children: [
            Text(
              "Título del documento",
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _titleController,
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1D2848)),
          decoration: InputDecoration(
            hintText: "Ej. Examen de Álgebra - Trimestre II",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Carga de Archivo PDF
        Row(
          children: [
            Text(
              "Archivo",
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMockFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _uploadedFileName.isNotEmpty ? const Color(0xFF1E88E5) : const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.uploadCloud,
                  size: 36,
                  color: Color(0xFF1E88E5),
                ),
                const SizedBox(height: 10),
                Text(
                  _uploadedFileName.isNotEmpty ? _uploadedFileName : "Sube tu archivo (PDF)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _uploadedFileName.isNotEmpty
                      ? "${_uploadedFileSizeMB.toStringAsFixed(1)} MB"
                      : "Máx. 20 MB",
                  style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Elegir archivo",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Campo Descripción
        Text(
          "Descripción o contenido",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _descController,
          maxLines: 4,
          style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF1D2848)),
          decoration: InputDecoration(
            hintText: "Describe brevemente el contenido del documento...",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Paso 2: Especificaciones de producción
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Especificaciones de producción",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 24),

        // Tipo de Impresión
        Text(
          "Tipo de impresión",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildProductionCard(
                label: "Blanco y negro",
                value: "b/n",
                isSelected: _colorMode == 'b/n',
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D2848),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                onTap: () => setState(() => _colorMode = 'b/n'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProductionCard(
                label: "A color",
                value: "color",
                isSelected: _colorMode == 'color',
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 2),
                    Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 2),
                    Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                  ],
                ),
                onTap: () => setState(() => _colorMode = 'color'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tamaño del papel
        Text(
          "Tamaño del papel",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 8),
        _buildPaperRadioOption("A4 (21 x 29.7 cm)", "A4"),
        const SizedBox(height: 8),
        _buildPaperRadioOption("Oficio (21.6 x 33 cm)", "Oficio"),
        const SizedBox(height: 8),
        _buildPaperRadioOption("Otro tamaño", "Otro"),
      ],
    );
  }

  Widget _buildProductionCard({
    required String label,
    required String value,
    required bool isSelected,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperRadioOption(String label, String value) {
    final isSelected = _paperSize == value;
    return InkWell(
      onTap: () => setState(() => _paperSize = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
          ),
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF94A3B8),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF1D2848),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Paso 3: Destino del material
  Widget _buildStep3() {
    final listGrados = _gradosPorNivel[_selectedNivel] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Destino del material",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 24),

        // Nivel / Ciclo
        Text(
          "Nivel / Ciclo",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 6),
        _buildDropdown(_selectedNivel, _niveles, (val) {
          if (val != null) {
            setState(() {
              _selectedNivel = val;
              _selectedGrado = _gradosPorNivel[_selectedNivel]!.first;
            });
          }
        }),
        const SizedBox(height: 16),

        // Grado
        Text(
          "Grado",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 6),
        _buildDropdown(_selectedGrado, listGrados, (val) {
          if (val != null) {
            setState(() {
              _selectedGrado = val;
            });
          }
        }),
        const SizedBox(height: 16),

        // Sección
        Text(
          "Sección",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 6),
        _buildDropdown(_selectedSeccion, _secciones, (val) {
          if (val != null) {
            setState(() {
              _selectedSeccion = val;
            });
          }
        }),
        const SizedBox(height: 20),

        // Ejemplares requeridos
        Row(
          children: [
            Text(
              "Ejemplares requeridos",
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _copiesController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1D2848), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Ej. 35",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            suffixText: "ejemplares",
            suffixStyle: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1D2848), fontWeight: FontWeight.w600),
          icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF94A3B8), size: 16),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Paso 4: Logística de entrega
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Logística de entrega",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 24),

        // Fecha límite requerida
        Row(
          children: [
            Text(
              "Fecha límite requerida",
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _limitDateController,
          readOnly: true,
          onTap: _selectDate,
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1D2848), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Seleccionar fecha límite",
            prefixIcon: const Icon(LucideIcons.calendar, color: Color(0xFF94A3B8), size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Instrucciones especiales / Acabado
        Text(
          "Instrucciones especiales / Acabado",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFinishCard(
                label: "Anillado",
                isSelected: _selectedFinish == 'Anillado',
                icon: LucideIcons.bookOpen,
                onTap: () => setState(() => _selectedFinish = 'Anillado'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishCard(
                label: "Engrapado",
                isSelected: _selectedFinish == 'Engrapado',
                icon: LucideIcons.folderOpen,
                onTap: () => setState(() => _selectedFinish = 'Engrapado'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishCard(
                label: "Suelto",
                isSelected: _selectedFinish == 'Suelto',
                icon: LucideIcons.fileText,
                onTap: () => setState(() => _selectedFinish = 'Suelto'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Observaciones adicionales
        Text(
          "Observaciones adicionales",
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _obsController,
          maxLines: 4,
          style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF1D2848)),
          decoration: InputDecoration(
            hintText: "Ej. Entregar en secretaría, engrapar por grupos de 2 hojas, etc.",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishCard({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir los botones de navegación en la parte inferior
  Widget _buildNavigationButtons() {
    final isFirstStep = _currentStep == 1;
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
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
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLastStep ? _saveForm : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? const Color(0xFFEDC620) : const Color(0xFF1E88E5),
                foregroundColor: isLastStep ? const Color(0xFF1D2848) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastStep ? "Revisar y enviar" : "Siguiente",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isLastStep ? LucideIcons.send : LucideIcons.chevronRight,
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
