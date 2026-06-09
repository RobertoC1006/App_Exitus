import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _indigo = Color(0xFF5B4FCF);
const _indigoLight = Color(0xFFEEEBFF);
const _textDark = Color(0xFF1A1D2E);
const _textMid = Color(0xFF6B7280);
const _textLight = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _bgPage = Color(0xFFF7F8FC);

class AdmitPatientScreen extends StatefulWidget {
  const AdmitPatientScreen({super.key});

  @override
  State<AdmitPatientScreen> createState() => _AdmitPatientScreenState();
}

class _AdmitPatientScreenState extends State<AdmitPatientScreen> {
  final MockDatabase _db = MockDatabase();
  bool _onReviewStep = false; // false = Datos, true = Registrar

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Student> _results = [];
  Student? _selected;
  String _reason = '';

  static const _reasons = [
    _Reason(
      label: 'Dolor de\ncabeza',
      raw: 'Dolor de cabeza',
      color: Color(0xFF6366F1),
      bg: Color(0xFFEEF2FF),
    ),
    _Reason(
      label: 'Dolor\nestomacal',
      raw: 'Dolor estomacal',
      color: Color(0xFFEC4899),
      bg: Color(0xFFFDF2F8),
    ),
    _Reason(
      label: 'Golpe /\nCaída',
      raw: 'Golpe / Caída',
      color: Color(0xFFF59E0B),
      bg: Color(0xFFFFFBEB),
    ),
    _Reason(
      label: 'Fiebre',
      raw: 'Fiebre',
      color: Color(0xFFEF4444),
      bg: Color(0xFFFEF2F2),
    ),
    _Reason(
      label: 'Malestar\ngeneral',
      raw: 'Malestar general',
      color: Color(0xFFF97316),
      bg: Color(0xFFFFF7ED),
    ),
    _Reason(
      label: 'Otro\nmotivo',
      raw: 'Otro motivo',
      color: Color(0xFF64748B),
      bg: Color(0xFFF1F5F9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_search);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Student> get _allStudents => [
        ..._db.students5toA,
        ..._db.students5toB,
        Student(id: 's101', fullName: 'Juan Pérez Romero', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'),
        Student(id: 's102', fullName: 'Ana Torres Medina', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'),
        Student(id: 's103', fullName: 'Diego Ramos León', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100'),
      ];

  String _grade(Student s) {
    if (s.id == 's101') return '4° A Secundaria';
    if (['s7', 's8', 's9', 's10'].contains(s.id)) return '5° B Secundaria';
    return '5° A Secundaria';
  }

  String _dni(Student s) {
    if (s.id == 's101') return '76543210';
    return '7654321${s.id.replaceFirst('s', '')}';
  }

  void _search() {
    if (_selected != null) return;
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? []
          : _allStudents.where((s) => s.fullName.toLowerCase().contains(q) || s.id.contains(q)).toList();
    });
  }

  void _pick(Student s) {
    setState(() {
      _selected = s;
      _results = [];
      _searchCtrl.text = s.fullName;
    });
    _searchFocus.unfocus();
  }

  void _clear() => setState(() {
        _selected = null;
        _results = [];
        _searchCtrl.clear();
      });

  void _onNext() {
    if (!_onReviewStep) {
      if (_selected == null) { _snack('Selecciona un alumno.'); return; }
      if (_reason.isEmpty) { _snack('Selecciona un motivo.'); return; }
      setState(() => _onReviewStep = true);
    } else {
      _register();
    }
  }

  void _onBack() {
    if (_onReviewStep) {
      setState(() => _onReviewStep = false);
    } else {
      Navigator.pop(context);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  void _register() {
    _db.nurseWaitingPatients.insert(0, {
      'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
      'name': _selected!.fullName,
      'grade': _grade(_selected!),
      'avatar': _selected!.avatarUrl,
      'reason': _reason,
      'time': 'Hace un momento',
      'entryTime': _nowFormatted(),
      'dni': _dni(_selected!),
      'description': _descCtrl.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text('${_selected!.fullName} admitido con éxito.', style: const TextStyle(fontWeight: FontWeight.bold))),
      ]),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    Navigator.pop(context, true);
  }

  String _nowFormatted() {
    final n = DateTime.now();
    final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
    return '$h:${n.minute.toString().padLeft(2, '0')} ${n.hour >= 12 ? 'p.m.' : 'a.m.'}';
  }

  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: _textDark, size: 22),
          onPressed: _onBack,
        ),
        title: Text(
          'Admitir Paciente',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: Column(
        children: [
          _StepBar(onReview: _onReviewStep),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: _onReviewStep ? _buildReview() : _buildForm(),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── STEP 1: Datos ────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Search label ──
        _SectionLabel('Buscar Alumno'),
        const SizedBox(height: 8),

        // ── Search field ──
        _SearchField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          hasValue: _selected != null || _searchCtrl.text.isNotEmpty,
          onClear: _clear,
        ),

        // ── Dropdown results ──
        if (_selected == null && _results.isNotEmpty) ...[
          const SizedBox(height: 6),
          _SearchDropdown(students: _results, gradeOf: _grade, onTap: _pick),
        ],

        // ── Found student card ──
        if (_selected != null) ...[
          const SizedBox(height: 18),
          _FoundLabel(),
          const SizedBox(height: 8),
          _StudentCard(student: _selected!, grade: _grade(_selected!), dni: _dni(_selected!)),
        ],

        // ── Reasons ──
        const SizedBox(height: 24),
        _SectionLabel('Seleccione el motivo'),
        const SizedBox(height: 12),
        _ReasonsGrid(
          reasons: _reasons,
          selected: _reason,
          onSelect: (r) => setState(() => _reason = r),
        ),

        // ── Description ──
        const SizedBox(height: 20),
        _SectionLabel('Descripción breve (opcional)'),
        const SizedBox(height: 8),
        _DescField(controller: _descCtrl),
      ],
    );
  }

  // ── STEP 2: Registrar ────────────────────────────────────────────────────────

  Widget _buildReview() {
    final reasonData = _reasons.firstWhere(
      (r) => r.raw == _reason,
      orElse: () => _reasons.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confirma los datos antes de registrar',
          style: GoogleFonts.outfit(fontSize: 13.5, color: _textMid, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _StudentCard(student: _selected!, grade: _grade(_selected!), dni: _dni(_selected!)),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 16),
              _ReviewRow(
                icon: LucideIcons.stethoscope,
                label: 'Motivo',
                value: _reason,
                color: reasonData.color,
              ),
              const SizedBox(height: 12),
              _ReviewRow(
                icon: LucideIcons.calendarDays,
                label: 'Fecha de ingreso',
                value: _todayLabel(),
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 12),
              _ReviewRow(
                icon: LucideIcons.clock,
                label: 'Hora estimada',
                value: _nowFormatted(),
                color: const Color(0xFFF59E0B),
              ),
              if (_descCtrl.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 14),
                _ObsBlock(text: _descCtrl.text.trim()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _todayLabel() {
    final n = DateTime.now();
    return 'Hoy (${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year})';
  }

  // ── Footer ───────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          if (_onReviewStep) ...[
            _BackButton(onTap: _onBack),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: _NextButton(
              label: _onReviewStep ? 'Registrar Ingreso' : 'Siguiente',
              icon: _onReviewStep ? LucideIcons.check : LucideIcons.arrowRight,
              color: _onReviewStep ? const Color(0xFF16A34A) : _indigo,
              onTap: _onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Bar ─────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final bool onReview;
  const _StepBar({required this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
      child: Row(
        children: [
          _dot(0, 'Datos', onReview),
          Expanded(child: _line(onReview)),
          _dot(1, 'Registrar', onReview),
        ],
      ),
    );
  }

  Widget _dot(int index, String label, bool reviewActive) {
    final isDone = index == 0 && reviewActive;
    final isActive = (index == 0 && !reviewActive) || (index == 1 && reviewActive);

    final dotColor = isDone
        ? const Color(0xFF16A34A)
        : isActive
            ? _indigo
            : const Color(0xFFD1D5DB);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: _indigo.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                : [],
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(LucideIcons.check, color: Colors.white, size: 13)
              : Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? _indigo
                : isDone
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _line(bool reviewActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 2,
      decoration: BoxDecoration(
        color: reviewActive ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
      );
}

// ─── Search field ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasValue;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hasValue,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: GoogleFonts.inter(fontSize: 13.5, color: _textDark),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o DNI...',
        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: _textLight),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: hasValue
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: _textLight),
                onPressed: onClear,
              )
            : const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(LucideIcons.search, size: 20, color: _textLight),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _indigo, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Search dropdown ──────────────────────────────────────────────────────────

class _SearchDropdown extends StatelessWidget {
  final List<Student> students;
  final String Function(Student) gradeOf;
  final void Function(Student) onTap;

  const _SearchDropdown({required this.students, required this.gradeOf, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 210),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
          itemBuilder: (_, i) {
            final s = students[i];
            return InkWell(
              onTap: () => onTap(s),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundImage: NetworkImage(s.avatarUrl)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.fullName,
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark)),
                          Text(gradeOf(s),
                              style: GoogleFonts.inter(fontSize: 11, color: _textMid)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 16, color: _textLight),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Found label ──────────────────────────────────────────────────────────────

class _FoundLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(color: _indigo, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          'Alumno encontrado',
          style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: _indigo),
        ),
      ],
    );
  }
}

// ─── Student card ─────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final Student student;
  final String grade;
  final String dni;

  const _StudentCard({required this.student, required this.grade, required this.dni});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF), width: 1.5),
        boxShadow: [
          BoxShadow(color: _indigo.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar with ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _indigoLight, width: 2.5),
            ),
            child: CircleAvatar(radius: 26, backgroundImage: NetworkImage(student.avatarUrl)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
                ),
                const SizedBox(height: 3),
                Text(grade, style: GoogleFonts.inter(fontSize: 12, color: _textMid, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('DNI: $dni', style: GoogleFonts.inter(fontSize: 11.5, color: _textLight)),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
            child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

// ─── Reasons grid ─────────────────────────────────────────────────────────────

class _ReasonsGrid extends StatelessWidget {
  final List<_Reason> reasons;
  final String selected;
  final void Function(String) onSelect;

  const _ReasonsGrid({required this.reasons, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: reasons.length,
      itemBuilder: (_, i) => _ReasonCard(
        reason: reasons[i],
        isSelected: selected == reasons[i].raw,
        onTap: () => onSelect(reasons[i].raw),
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  final _Reason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonCard({required this.reason, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? reason.bg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? reason.color : _borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: reason.color.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 5))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with colored circle background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reason.color.withValues(alpha: isSelected ? 0.15 : 0.09),
                shape: BoxShape.circle,
              ),
              child: Center(child: _ReasonIcon(label: reason.raw, color: reason.color, size: 26)),
            ),
            const SizedBox(height: 8),
            Text(
              reason.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? reason.color : _textDark,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Description field ────────────────────────────────────────────────────────

class _DescField extends StatelessWidget {
  final TextEditingController controller;
  const _DescField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 150,
      style: GoogleFonts.inter(fontSize: 13.5, color: _textDark),
      decoration: InputDecoration(
        hintText: 'Escribe aquí los detalles...',
        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: _textLight),
        counterStyle: GoogleFonts.inter(fontSize: 11, color: _textLight),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _indigo, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Review row ───────────────────────────────────────────────────────────────

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ReviewRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: _textLight, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: _textDark)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Obs block ────────────────────────────────────────────────────────────────

class _ObsBlock extends StatelessWidget {
  final String text;
  const _ObsBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'OBSERVACIONES',
          style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.w800, color: _textLight, letterSpacing: 0.7),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor),
          ),
          child: Text(text, style: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: _textDark)),
        ),
      ],
    );
  }
}

// ─── Footer buttons ───────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _textDark,
        side: const BorderSide(color: _borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text('Atrás', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NextButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.5)),
          const SizedBox(width: 8),
          Icon(icon, size: 18),
        ],
      ),
    );
  }
}

// ─── Reason data model ────────────────────────────────────────────────────────

class _Reason {
  final String label; // display (with \n)
  final String raw;   // logic key
  final Color color;
  final Color bg;

  const _Reason({required this.label, required this.raw, required this.color, required this.bg});
}

// ─── Reason icon widget ───────────────────────────────────────────────────────

class _ReasonIcon extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const _ReasonIcon({required this.label, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (label) {
      case 'Dolor de cabeza':
        return Icon(LucideIcons.brain, color: color, size: size);
      case 'Dolor estomacal':
        return _StomachIcon(color: color, size: size);
      case 'Golpe / Caída':
        return _BandageIcon(color: color, size: size);
      case 'Fiebre':
        return Transform.rotate(
          angle: -0.4,
          child: Icon(LucideIcons.thermometer, color: color, size: size),
        );
      case 'Malestar general':
        return _SickFaceIcon(color: color, size: size);
      default:
        return _DotsCircleIcon(color: color, size: size);
    }
  }
}

// ─── Custom painters ──────────────────────────────────────────────────────────

class _StomachIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _StomachIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _StomachPainter(color)));
}

class _StomachPainter extends CustomPainter {
  final Color color;
  _StomachPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final w = s.width;
    final h = s.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .45, h * .08)
        ..lineTo(w * .45, h * .22)
        ..cubicTo(w * .13, h * .22, w * .04, h * .76, w * .44, h * .86)
        ..cubicTo(w * .65, h * .91, w * .86, h * .75, w * .81, h * .54)
        ..lineTo(w * .68, h * .51)
        ..cubicTo(w * .62, h * .62, w * .55, h * .47, w * .55, h * .22)
        ..lineTo(w * .55, h * .08),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BandageIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _BandageIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _BandagePainter(color)));
}

class _BandagePainter extends CustomPainter {
  final Color color;
  _BandagePainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final thin = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final w = s.width;
    final h = s.height;

    for (final angle in [-0.8, 0.8]) {
      canvas.save();
      canvas.translate(w / 2, h / 2);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w * .82, height: h * .26),
          Radius.circular(w * .08),
        ),
        stroke,
      );
      canvas.drawLine(Offset(-w * .13, -h * .13), Offset(-w * .13, h * .13), thin);
      canvas.drawLine(Offset(w * .13, -h * .13), Offset(w * .13, h * .13), thin);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Sick face: emoji-style face with X eyes
class _SickFaceIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _SickFaceIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _SickFacePainter(color)));
}

class _SickFacePainter extends CustomPainter {
  final Color color;
  _SickFacePainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w / 2;
    final cy = h / 2;

    // Outer circle (filled lightly)
    canvas.drawCircle(
      Offset(cx, cy),
      w * .44,
      Paint()..color = color.withValues(alpha: 0.18)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      w * .44,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // X eyes
    final eyePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const r = 0.07;
    // left eye X
    canvas.drawLine(Offset(cx - w * .2 - w * r, cy - h * .12 - h * r), Offset(cx - w * .2 + w * r, cy - h * .12 + h * r), eyePaint);
    canvas.drawLine(Offset(cx - w * .2 + w * r, cy - h * .12 - h * r), Offset(cx - w * .2 - w * r, cy - h * .12 + h * r), eyePaint);
    // right eye X
    canvas.drawLine(Offset(cx + w * .2 - w * r, cy - h * .12 - h * r), Offset(cx + w * .2 + w * r, cy - h * .12 + h * r), eyePaint);
    canvas.drawLine(Offset(cx + w * .2 + w * r, cy - h * .12 - h * r), Offset(cx + w * .2 - w * r, cy - h * .12 + h * r), eyePaint);

    // Wavy/sad mouth
    final mouthPath = Path();
    mouthPath.moveTo(cx - w * .2, cy + h * .12);
    mouthPath.cubicTo(cx - w * .08, cy + h * .22, cx + w * .08, cy + h * .22, cx + w * .2, cy + h * .12);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotsCircleIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _DotsCircleIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _DotsCirclePainter(color)));
}

class _DotsCirclePainter extends CustomPainter {
  final Color color;
  _DotsCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * .42,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );
    final dot = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * .35, h / 2), w * .055, dot);
    canvas.drawCircle(Offset(w / 2, h / 2), w * .055, dot);
    canvas.drawCircle(Offset(w * .65, h / 2), w * .055, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
