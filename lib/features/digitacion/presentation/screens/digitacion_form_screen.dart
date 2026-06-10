import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF6C4EF2); // Purple-indigo (mockup principal)
const _kPrimaryBg  = Color(0xFFF3EFFF); // Tint suave
const _kDark       = Color(0xFF1D2848);
const _kMuted      = Color(0xFF94A3B8);
const _kSurface    = Color(0xFFF8FAFC);
const _kBorder     = Color(0xFFE8ECEF);
const _kSuccess    = Color(0xFF22C55E);
const _kErrorRed   = Color(0xFFD32F2F);

class DigitacionFormScreen extends StatefulWidget {
  final PrintRequest? request;
  final VoidCallback onSaved;

  const DigitacionFormScreen({super.key, this.request, required this.onSaved});

  @override
  State<DigitacionFormScreen> createState() => _DigitacionFormScreenState();
}

class _DigitacionFormScreenState extends State<DigitacionFormScreen>
    with TickerProviderStateMixin {
  final MockDatabase _db = MockDatabase();

  int _currentStep = 1; // 1: Documento, 2: Producción, 3: Destino, 4: Entrega

  // Animación de entrada del contenido al cambiar de paso
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  // Paso 1
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _uploadedFileName = '';
  double _uploadedFileSizeMB = 0.0;

  // Paso 2
  String _colorMode = 'b/n';
  String _paperSize = 'A4';

  // Paso 3
  String _selectedNivel = 'Secundaria';
  String _selectedGrado = '4°';
  String _selectedSeccion = 'A';
  late TextEditingController _copiesController;

  // Paso 4
  late TextEditingController _limitDateController;
  String _selectedFinish = 'Suelto';
  late TextEditingController _obsController;

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

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();

    _titleController = TextEditingController(text: widget.request?.title ?? '');
    _descController = TextEditingController(text: widget.request?.description ?? '');
    _copiesController = TextEditingController(
      text: widget.request?.classrooms.isNotEmpty == true
          ? widget.request!.classrooms.first.copies.toString()
          : '35',
    );
    _limitDateController =
        TextEditingController(text: widget.request?.limitDate ?? '25 / 05 / 2024');
    _obsController = TextEditingController(text: widget.request?.instructions ?? '');

    if (widget.request != null) {
      _colorMode = widget.request!.colorMode;
      _paperSize = widget.request!.paperSize;
      _uploadedFileName = widget.request!.file;
      _uploadedFileSizeMB = 2.4;
      _selectedFinish = widget.request!.finish;

      if (widget.request!.classrooms.isNotEmpty) {
        final targetName = widget.request!.classrooms.first.name;
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
    _slideCtrl.dispose();
    _titleController.dispose();
    _descController.dispose();
    _copiesController.dispose();
    _limitDateController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _pickMockFile() {
    setState(() {
      _uploadedFileName =
          "Examen_${_titleController.text.isNotEmpty ? _titleController.text.trim().replaceAll(' ', '_') : 'Material'}.pdf";
      _uploadedFileSizeMB = Random().nextDouble() * 5 + 1.2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Archivo adjuntado: $_uploadedFileName"),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              primary: _kPrimary,
              onPrimary: Colors.white,
              onSurface: _kDark,
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

  void _animateStepTransition(VoidCallback action) {
    _slideCtrl.reset();
    action();
    _slideCtrl.forward();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_titleController.text.trim().isEmpty) {
        _showError("El título del documento es obligatorio.");
        return;
      }
      if (_uploadedFileName.isEmpty) {
        _showError("Debe adjuntar un archivo PDF.");
        return;
      }
    } else if (_currentStep == 3) {
      final copies = int.tryParse(_copiesController.text) ?? 0;
      if (copies <= 0) {
        _showError("La cantidad de ejemplares debe ser mayor a 0.");
        return;
      }
    }
    if (_currentStep < 4) {
      _animateStepTransition(() => setState(() => _currentStep++));
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      _animateStepTransition(() => setState(() => _currentStep--));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kErrorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveForm() {
    if (_limitDateController.text.trim().isEmpty) {
      _showError("La fecha límite es obligatoria.");
      return;
    }

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final limitDate = _limitDateController.text.trim();
    final instructions = _obsController.text.trim();
    final copies = int.tryParse(_copiesController.text) ?? 35;
    final targetClassroom = "$_selectedGrado $_selectedNivel $_selectedSeccion";
    final classroomTargets = [PrintClassroomTarget(name: targetClassroom, copies: copies)];

    if (widget.request != null) {
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
          backgroundColor: _kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
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
        date: "01 Jun 2026",
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
          backgroundColor: _kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Timer(const Duration(seconds: 6), () {
        final newMsgId = 'msg_lg_${Random().nextInt(10000)}';
        final mockMsg = InboxMessage(
          id: newMsgId,
          sender: "Luis Gonzaga",
          subject: "[Digitación] Solicitud #$ticketNum Registrada",
          date: "Hoy",
          snippet: "Confirmación de recepción de ticket #$ticketNum...",
          content:
              "Hola Nicole,\n\nHemos recibido correctamente su solicitud de digitación #$ticketNum para el documento \"$title\". El trabajo ha sido asignado al centro de producción con estado PENDIENTE.\n\nDetalles:\n- Curso/Sección: $targetClassroom\n- Copias: $copies\n- Modo: ${_colorMode == 'b/n' ? 'Blanco y negro' : 'A color'} ($_paperSize)\n- Acabado: $_selectedFinish\n- Fecha límite requerida: $limitDate\n\nAtentamente,\nLuis Gonzaga - Coordinación de Producción.",
          unread: true,
          urgent: false,
        );
        _db.adminMessages.insert(0, mockMsg);
      });
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildProgressIndicator(),
            const SizedBox(height: 4),
            Container(height: 1, color: _kBorder.withValues(alpha: 0.6)),
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: _kBorder),
        ),
        child: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: _kDark, size: 18),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          tooltip: 'Volver',
        ),
      ),
      title: Text(
        "Nueva solicitud",
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _kDark,
        ),
      ),
      centerTitle: true,
    );
  }

  // ─── Progress Stepper (Mockup Style) ──────────────────────────────────────

  Widget _buildProgressIndicator() {
    final steps = ['Documento', 'Producción', 'Destino', 'Entrega'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Línea conectora
            final afterStep = (i ~/ 2) + 1;
            final isCompleted = _currentStep > afterStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isCompleted ? _kPrimary : _kBorder,
                ),
              ),
            );
          }
          final step = (i ~/ 2) + 1;
          return _buildStepNode(step, steps[step - 1]);
        }),
      ),
    );
  }

  Widget _buildStepNode(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          width: isActive ? 34 : 28,
          height: isActive ? 34 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? _kPrimary
                : (isActive ? _kPrimary : Colors.white),
            border: Border.all(
              color: isCompleted || isActive ? _kPrimary : _kBorder,
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
              : Text(
                  "$step",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : _kMuted,
                  ),
                ),
        ),
        const SizedBox(height: 5),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? _kPrimary
                : (isCompleted ? _kPrimary.withValues(alpha: 0.6) : _kMuted),
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // ─── Step Content Router ───────────────────────────────────────────────────

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

  // ─── Step Header Widget ────────────────────────────────────────────────────

  Widget _buildStepHeader(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _kDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(fontSize: 11.5, color: _kMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Paso 1: Detalles del documento ────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          "Detalles del documento",
          "Agrega el título y el archivo a imprimir",
          LucideIcons.fileText,
          _kPrimary,
        ),
        const SizedBox(height: 24),

        _buildLabel("Título del documento", required: true),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _titleController,
          hint: "Ej. Examen de Álgebra - Trimestre II",
          prefixIcon: LucideIcons.pencil,
        ),
        const SizedBox(height: 20),

        _buildLabel("Archivo PDF", required: true),
        const SizedBox(height: 8),
        _buildFileUploadCard(),
        const SizedBox(height: 20),

        _buildLabel("Descripción o contenido"),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _descController,
          hint: "Describe brevemente el contenido del documento...",
          maxLines: 4,
          prefixIcon: LucideIcons.alignLeft,
        ),
      ],
    );
  }

  Widget _buildFileUploadCard() {
    final hasFile = _uploadedFileName.isNotEmpty;
    return GestureDetector(
      onTap: _pickMockFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile ? _kPrimaryBg : _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasFile ? _kPrimary : _kBorder,
            width: hasFile ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasFile ? _kPrimary.withValues(alpha: 0.12) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: hasFile
                        ? _kPrimary.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Icon(
                hasFile ? LucideIcons.fileCheck2 : LucideIcons.uploadCloud,
                size: 30,
                color: hasFile ? _kPrimary : _kMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasFile ? _uploadedFileName : "Sube tu archivo (PDF)",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: hasFile ? _kPrimary : _kDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasFile ? "${_uploadedFileSizeMB.toStringAsFixed(1)} MB" : "Máx. 20 MB",
              style: GoogleFonts.outfit(fontSize: 11, color: _kMuted),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5FF5), _kPrimary],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Text(
                hasFile ? "Cambiar archivo" : "Elegir archivo",
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
    );
  }

  // ─── Paso 2: Especificaciones de producción ────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          "Especificaciones de producción",
          "Elige el tipo de impresión y tamaño",
          LucideIcons.printer,
          const Color(0xFF0284C7),
        ),
        const SizedBox(height: 24),

        _buildLabel("Tipo de impresión"),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildColorModeCard(
                label: "Blanco y negro",
                value: "b/n",
                icon: _buildBWIcon(),
                accentColor: const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildColorModeCard(
                label: "A color",
                value: "color",
                icon: _buildColorIcon(),
                accentColor: const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildLabel("Tamaño del papel"),
        const SizedBox(height: 10),
        _buildPaperRadioOption("A4 (21 × 29.7 cm)", "A4"),
        const SizedBox(height: 8),
        _buildPaperRadioOption("Oficio (21.6 × 33 cm)", "Oficio"),
        const SizedBox(height: 8),
        _buildPaperRadioOption("Otro tamaño", "Otro"),
      ],
    );
  }

  Widget _buildBWIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Color(0xFF1D2848), shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
          ),
        ),
      ],
    );
  }

  Widget _buildColorIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 14, height: 14, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Container(width: 14, height: 14, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Container(width: 14, height: 14, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildColorModeCard({
    required String label,
    required String value,
    required Widget icon,
    required Color accentColor,
  }) {
    final isSelected = _colorMode == value;
    return GestureDetector(
      onTap: () => setState(() => _colorMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : _kBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : _kDark,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaperRadioOption(String label, String value) {
    final isSelected = _paperSize == value;
    return GestureDetector(
      onTap: () => setState(() => _paperSize = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _kPrimary : _kBorder,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _kPrimary : Colors.white,
                border: Border.all(
                  color: isSelected ? _kPrimary : _kMuted,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.circle, color: Colors.white, size: 8)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _kPrimary : _kDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Paso 3: Destino del material ─────────────────────────────────────────

  Widget _buildStep3() {
    final listGrados = _gradosPorNivel[_selectedNivel] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          "Destino del material",
          "Indica el aula y la cantidad de ejemplares",
          LucideIcons.school,
          const Color(0xFF16A34A),
        ),
        const SizedBox(height: 24),

        _buildLabel("Nivel / Ciclo"),
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

        _buildLabel("Grado"),
        const SizedBox(height: 6),
        _buildDropdown(_selectedGrado, listGrados, (val) {
          if (val != null) setState(() => _selectedGrado = val);
        }),
        const SizedBox(height: 16),

        _buildLabel("Sección"),
        const SizedBox(height: 6),
        _buildDropdown(_selectedSeccion, _secciones, (val) {
          if (val != null) setState(() => _selectedSeccion = val);
        }),
        const SizedBox(height: 20),

        _buildLabel("Ejemplares requeridos", required: true),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _copiesController,
          hint: "Ej. 35",
          suffixText: "ejemplares",
          keyboardType: TextInputType.number,
          prefixIcon: LucideIcons.copy,
        ),
      ],
    );
  }

  // ─── Paso 4: Logística de entrega ─────────────────────────────────────────

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          "Logística de entrega",
          "Fecha límite y tipo de acabado final",
          LucideIcons.package,
          const Color(0xFFD97706),
        ),
        const SizedBox(height: 24),

        _buildLabel("Fecha límite requerida", required: true),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: _buildTextField(
              controller: _limitDateController,
              hint: "Seleccionar fecha límite",
              prefixIcon: LucideIcons.calendar,
              readOnly: true,
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildLabel("Instrucciones especiales / Acabado"),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFinishCard(
                label: "Anillado",
                value: "Anillado",
                icon: LucideIcons.bookOpen,
                color: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishCard(
                label: "Engrapado",
                value: "Engrapado",
                icon: LucideIcons.folderOpen,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishCard(
                label: "Suelto",
                value: "Suelto",
                icon: LucideIcons.fileText,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildLabel("Observaciones adicionales"),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _obsController,
          hint: "Ej. Entregar en secretaría, engrapar por grupos de 2 hojas...",
          maxLines: 4,
          prefixIcon: LucideIcons.messageSquare,
        ),
      ],
    );
  }

  Widget _buildFinishCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedFinish == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFinish = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.09) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : _kBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : _kSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color : _kMuted,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : _kDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────────────────

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: _kDark,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    IconData? prefixIcon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.outfit(fontSize: 13, color: _kDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 13, color: _kMuted, fontWeight: FontWeight.normal),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.outfit(fontSize: 12, color: _kMuted),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 16, color: _kMuted)
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 4 : 14,
          vertical: 13,
        ),
        filled: true,
        fillColor: _kSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: _kDark,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(LucideIcons.chevronDown, color: _kMuted, size: 16),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Navigation Buttons ────────────────────────────────────────────────────

  Widget _buildNavigationButtons() {
    final isFirstStep = _currentStep == 1;
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
      ),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: _kBorder, width: 1.2),
                  foregroundColor: _kDark,
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
            child: _buildPrimaryButton(
              label: isLastStep ? "Revisar y enviar" : "Siguiente",
              icon: isLastStep ? LucideIcons.send : LucideIcons.chevronRight,
              onTap: isLastStep ? _saveForm : _nextStep,
              gradient: isLastStep
                  ? const LinearGradient(
                      colors: [Color(0xFFEDC620), Color(0xFFD4A017)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF7C5FF5), _kPrimary],
                    ),
              labelColor: isLastStep ? _kDark : Colors.white,
              iconColor: isLastStep ? _kDark : Colors.white,
              shadowColor: isLastStep
                  ? const Color(0xFFEDC620)
                  : _kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
    required Color labelColor,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 15, color: iconColor),
          ],
        ),
      ),
    );
  }
}
