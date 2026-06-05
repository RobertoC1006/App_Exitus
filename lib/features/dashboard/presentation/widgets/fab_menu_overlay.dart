import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FABMenuOverlay extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onClose;
  final Function(String action) onActionTap;
  final Color fabColor;
  final double fabIconSize;

  const FABMenuOverlay({
    super.key,
    required this.user,
    required this.onClose,
    required this.onActionTap,
    this.fabColor = const Color(0xFF1D2848),
    this.fabIconSize = 24,
  });

  @override
  State<FABMenuOverlay> createState() => _FABMenuOverlayState();
}

class _FABMenuOverlayState extends State<FABMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgAnim;
  late List<Animation<double>> _staggeredAnimations;

  final List<Map<String, dynamic>> _allActions = [
    {'id': 'post',          'label': 'Crear Publicación',   'icon': LucideIcons.edit3,         'color': const Color(0xFF3B82F6)},
    {'id': 'schedule',      'label': 'Ver Agenda / Horario','icon': LucideIcons.calendar,       'color': const Color(0xFFF59E0B)},
    {'id': 'portal',        'label': 'Portal Exitus',       'icon': LucideIcons.compass,        'color': const Color(0xFF8B5CF6)},
    {'id': 'topico',        'label': 'Tópico / Enfermería', 'icon': LucideIcons.activity,       'color': const Color(0xFFEF4444)},
    {'id': 'psicologia',    'label': 'Psicología',          'icon': LucideIcons.heart,          'color': const Color(0xFFEC4899)},
    {'id': 'tesoreria',     'label': 'Pensiones y Pagos',   'icon': LucideIcons.landmark,       'color': const Color(0xFF10B981)},
    {'id': 'firma',         'label': 'Firma Rápida',        'icon': LucideIcons.penTool,        'color': const Color(0xFF6B7280)},
    {'id': 'qr_attendance', 'label': 'Asistencia / QR',    'icon': LucideIcons.userCheck,      'color': const Color(0xFF06B6D4)},
    {'id': 'actia',         'label': 'Sesiones ActIA',      'icon': LucideIcons.cpu,            'color': const Color(0xFF6366F1)},
    {'id': 'digitacion',    'label': 'Área de Digitación',  'icon': LucideIcons.printer,        'color': const Color(0xFF7C3AED)},
    {'id': 'dojo_shop',     'label': 'Tienda Dojo',         'icon': LucideIcons.shoppingBag,    'color': const Color(0xFFFF7043)},
    {'id': 'curr',          'label': 'Plan Curricular',     'icon': LucideIcons.briefcase,      'color': const Color(0xFF26C6DA)},
    {'id': 'diary',         'label': 'Bitácoras / Diario',  'icon': LucideIcons.book,           'color': const Color(0xFFAB47BC)},
    {'id': 'my_attendance', 'label': 'Mi Asistencia',       'icon': LucideIcons.calendarCheck2, 'color': const Color(0xFF66BB6A)},
  ];

  late final List<Map<String, dynamic>> _actions;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _bgAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Filtrar acciones según el rol
    final role = widget.user['role'] ?? 'student';
    List<String> allowedIds;
    if (role == 'teacher') {
      allowedIds = ['schedule', 'qr_attendance', 'actia', 'dojo_shop', 'curr', 'diary', 'digitacion', 'post'];
    } else if (role == 'student') {
      allowedIds = ['schedule', 'topico', 'psicologia', 'tesoreria', 'my_attendance', 'actia'];
    } else if (role == 'admin') {
      allowedIds = ['post', 'schedule', 'topico', 'psicologia', 'tesoreria', 'qr_attendance', 'actia'];
    } else {
      allowedIds = ['schedule', 'portal'];
    }

    _actions = _allActions.where((act) => allowedIds.contains(act['id'])).toList();

    // Animaciones escalonadas — misma curva para apertura y cierre
    _staggeredAnimations = List.generate(_actions.length, (index) {
      final double start = (index * 0.05).clamp(0.0, 0.4);
      final double end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
        reverseCurve: Interval(start, end, curve: Curves.easeInBack),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _closeWithAnim() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const bottomNavHeight = 70.0;
    const fabSize = 56.0;
    final fabBottomOffset = bottomPadding + (bottomNavHeight - fabSize) / 2;

    return GestureDetector(
      onTap: _closeWithAnim,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // ── 1. Fondo frosted-glass animado ────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgAnim,
                builder: (context, _) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * _bgAnim.value,
                    sigmaY: 8 * _bgAnim.value,
                  ),
                  child: Container(
                    color: const Color(0xFF1D2848)
                        .withValues(alpha: 0.28 * _bgAnim.value),
                  ),
                ),
              ),
            ),

            // ── 2. Columna de acciones rápidas ───────────────────────────
            Positioned(
              right: 20,
              bottom: fabBottomOffset + fabSize + 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_actions.length, (index) {
                  // Invertir orden: la primera acción queda más cerca del FAB
                  final reverseIndex = _actions.length - 1 - index;
                  final revAction = _actions[reverseIndex];
                  final revAnim = _staggeredAnimations[reverseIndex];

                  return FadeTransition(
                    opacity: revAnim,
                    child: ScaleTransition(
                      scale: revAnim,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Etiqueta
                            Card(
                              color: const Color(0xFF1D2848),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Text(
                                  revAction['label'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Botón circular de acción
                            GestureDetector(
                              onTap: () {
                                widget.onActionTap(revAction['id']);
                                _closeWithAnim();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFEDC620),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1D2848)
                                          .withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  revAction['icon'],
                                  color: const Color(0xFF1D2848),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── 3. FAB central — mismo que el original, rota al abrir ─────
            Positioned(
              left: 0,
              right: 0,
              bottom: fabBottomOffset,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final angle = _controller.value * (math.pi * 0.75);
                    return Transform.rotate(
                      angle: angle,
                      child: FloatingActionButton(
                        heroTag: 'fab_main_action',
                        onPressed: _closeWithAnim,
                        backgroundColor: widget.fabColor,
                        elevation: 8,
                        shape: const CircleBorder(),
                        child: Icon(
                          LucideIcons.plus,
                          color: Colors.white,
                          size: widget.fabIconSize,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
