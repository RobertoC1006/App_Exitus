import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

// ─── Tokens ───────────────────────────────────────────────────────────────────
const _dark      = Color(0xFF111827);
const _mid       = Color(0xFF6B7280);
const _light     = Color(0xFF9CA3AF);

const _green     = Color(0xFF16A34A);
const _greenBg   = Color(0xFFDCFCE7);
const _indigo    = Color(0xFF5B4FCF);

const _tempColor = Color(0xFF16A34A);
const _tempBg    = Color(0xFFF0FDF4);
const _tempBd    = Color(0xFFBBF7D0);

const _presColor = Color(0xFF2563EB);
const _presBg    = Color(0xFFEFF6FF);
const _presBd    = Color(0xFFBFDBFE);

const _pulseColor = Color(0xFFDC2626);
const _pulseBg    = Color(0xFFFEF2F2);
const _pulseBd    = Color(0xFFFECACA);

// ─────────────────────────────────────────────────────────────────────────────

class ClinicalAttentionScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  const ClinicalAttentionScreen({super.key, required this.patient});

  @override
  State<ClinicalAttentionScreen> createState() => _ClinicalAttentionScreenState();
}

class _ClinicalAttentionScreenState extends State<ClinicalAttentionScreen>
    with SingleTickerProviderStateMixin {
  final MockDatabase _db = MockDatabase();

  final _tempCtrl     = TextEditingController(text: '36.8');
  final _pressureCtrl = TextEditingController(text: '120/80');
  final _pulseCtrl    = TextEditingController(text: '80');
  final _obsCtrl      = TextEditingController();

  bool _reposo  = true;
  bool _hidra   = true;
  bool _med     = false;
  bool _llamar  = false;
  bool _derivar = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    final desc = widget.patient['description'] as String?;
    _obsCtrl.text = (desc != null && desc.isNotEmpty)
        ? desc
        : 'Paciente refiere dolor leve en la cabeza.\nSin otros síntomas asociados.';
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _tempCtrl.dispose();
    _pressureCtrl.dispose();
    _pulseCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  // ─── Logic ────────────────────────────────────────────────────────────────────

  void _discharge() {
    final id = '#${484 + _db.nurseAuditLogs.length}';
    _db.nurseAuditLogs.insert(0, {
      'id': id.replaceAll('#', ''),
      'student': widget.patient['name'],
      'date': _dateLabel(),
      'time': _timeLabel(),
      'status': 'Firmado',
    });
    _db.nurseWaitingPatients.removeWhere((p) => p['id'] == widget.patient['id']);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${widget.patient['name']} dado de alta ($id).',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
    Navigator.pop(context, true);
  }

  void _showMoreActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _MoreActionsSheet(
        onDerivar: () {
          Navigator.pop(ctx);
          setState(() => _derivar = true);
          _snack('Derivación a médico registrada.', _presColor);
        },
        onLlamar: () {
          Navigator.pop(ctx);
          setState(() => _llamar = true);
          _snack('Notificación a padres marcada.', _green);
        },
        onAuditoria: () {
          Navigator.pop(ctx);
          _snack('Registro de auditoría generado.', _dark);
        },
      ),
    );
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));

  String _dateLabel() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year}';
  }

  String _timeLabel() {
    final n = DateTime.now();
    final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
    return '$h:${n.minute.toString().padLeft(2,'0')} ${n.hour >= 12 ? 'p. m.' : 'a. m.'}';
  }

  String _entryLabel() {
    final n = DateTime.now();
    final d = '${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year}';
    return '$d – ${widget.patient['entryTime'] ?? _timeLabel()}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final name   = widget.patient['name']   as String? ?? 'Alumno';
    final grade  = widget.patient['grade']  as String? ?? 'Sección';
    final avatar = widget.patient['avatar'] as String? ??
        'https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _patientCard(name, grade, avatar),
                    const SizedBox(height: 22),
                    _label('Signos Vitales'),
                    const SizedBox(height: 10),
                    _vitalsRow(),
                    const SizedBox(height: 22),
                    _label('Observaciones'),
                    const SizedBox(height: 10),
                    _obsField(),
                    const SizedBox(height: 22),
                    _label('Acciones realizadas'),
                    const SizedBox(height: 10),
                    _actionsCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: _dark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Atención Clínica',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: _dark),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF3F4F6)),
        ),
      );

  // ─── Section label ────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: _dark),
      );

  // ─── Patient card ─────────────────────────────────────────────────────────────

  Widget _patientCard(String name, String grade, String avatar) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(avatar),
            backgroundColor: const Color(0xFFF3F4F6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.outfit(fontSize: 15.5, fontWeight: FontWeight.bold, color: _dark)),
                const SizedBox(height: 3),
                Text(grade,
                    style: GoogleFonts.inter(fontSize: 13, color: _mid, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 11, color: _light),
                    const SizedBox(width: 4),
                    Text('Ingreso: ${_entryLabel()}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: _light)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _greenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('En atención',
                style: GoogleFonts.outfit(
                    fontSize: 11, fontWeight: FontWeight.bold, color: _green)),
          ),
        ],
      ),
    );
  }

  // ─── Vitals ───────────────────────────────────────────────────────────────────

  Widget _vitalsRow() => Row(
        children: [
          Expanded(child: _vitalCard('Temp.',    '°C',   _tempCtrl,     _tempColor,  _tempBg,  _tempBd,  LucideIcons.thermometer,  TextInputType.numberWithOptions(decimal: true))),
          const SizedBox(width: 10),
          Expanded(child: _vitalCard('Presión',  'mmHg', _pressureCtrl, _presColor,  _presBg,  _presBd,  LucideIcons.activity,     TextInputType.text)),
          const SizedBox(width: 10),
          Expanded(child: _vitalCard('Pulso',    'lpm',  _pulseCtrl,    _pulseColor, _pulseBg, _pulseBd, LucideIcons.heartPulse,   TextInputType.number)),
        ],
      );

  Widget _vitalCard(
    String label,
    String unit,
    TextEditingController ctrl,
    Color color,
    Color bg,
    Color bd,
    IconData icon,
    TextInputType keyboard,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bd, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color.withValues(alpha: 0.75)),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicWidth(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboard,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: color),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(unit,
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.65))),
        ],
      ),
    );
  }

  // ─── Observations ─────────────────────────────────────────────────────────────

  Widget _obsField() => _Card(
        padding: EdgeInsets.zero,
        child: TextFormField(
          controller: _obsCtrl,
          maxLines: 4,
          maxLength: 150,
          style: GoogleFonts.inter(fontSize: 13.5, color: _dark, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Describe los síntomas o condición del paciente...',
            hintStyle: GoogleFonts.inter(fontSize: 13.5, color: _light),
            filled: false,
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _indigo, width: 1.5),
            ),
            counterStyle: GoogleFonts.inter(fontSize: 11, color: _light),
          ),
        ),
      );

  // ─── Actions checklist ────────────────────────────────────────────────────────

  Widget _actionsCard() {
    final items = [
      (label: 'Reposo en tópico', value: _reposo,  set: (bool v) => setState(() => _reposo  = v)),
      (label: 'Hidratación',      value: _hidra,   set: (bool v) => setState(() => _hidra   = v)),
      (label: 'Medicación',       value: _med,     set: (bool v) => setState(() => _med     = v)),
      (label: 'Llamar a padres',  value: _llamar,  set: (bool v) => setState(() => _llamar  = v)),
      (label: 'Derivar a médico', value: _derivar, set: (bool v) => setState(() => _derivar = v)),
    ];

    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _checkTile(items[i].label, items[i].value, items[i].set),
            if (i < items.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF9FAFB), indent: 54, endIndent: 16),
          ],
        ],
      ),
    );
  }

  Widget _checkTile(String label, bool value, void Function(bool) onSet) {
    return InkWell(
      onTap: () => onSet(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? _indigo : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: value ? _indigo : const Color(0xFFD1D5DB),
                  width: 1.8,
                ),
                boxShadow: value
                    ? [BoxShadow(color: _indigo.withValues(alpha: 0.28), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: value
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: value ? _dark : _mid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────────

  Widget _footer() => Container(
        padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: _showMoreActions,
              icon: const Icon(LucideIcons.moreHorizontal, size: 16),
              label: Text('Más acciones',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _dark,
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _discharge,
                icon: const Icon(LucideIcons.check, size: 18, color: Colors.white),
                label: Text('Dar de alta',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Reusable card wrapper ────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0xFFE5E7EB), blurRadius: 0, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

// ─── More Actions sheet ───────────────────────────────────────────────────────

class _MoreActionsSheet extends StatelessWidget {
  final VoidCallback onDerivar;
  final VoidCallback onLlamar;
  final VoidCallback onAuditoria;

  const _MoreActionsSheet({
    required this.onDerivar,
    required this.onLlamar,
    required this.onAuditoria,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Acciones adicionales',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
            const SizedBox(height: 14),
            _option(context,
                icon: LucideIcons.stethoscope,
                color: const Color(0xFF2563EB),
                label: 'Derivar a médico externo',
                sub: 'Registra derivación formal',
                onTap: onDerivar),
            const SizedBox(height: 10),
            _option(context,
                icon: LucideIcons.phone,
                color: const Color(0xFF16A34A),
                label: 'Llamar a padres / apoderados',
                sub: 'Marca llamada como realizada',
                onTap: onLlamar),
            const SizedBox(height: 10),
            _option(context,
                icon: LucideIcons.fileText,
                color: const Color(0xFF7C3AED),
                label: 'Registro de auditoría',
                sub: 'Genera acta digital firmada',
                onTap: onAuditoria),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                  Text(sub,
                      style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: color.withValues(alpha: 0.45)),
          ],
        ),
      ),
    );
  }
}
