import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FABMenuOverlay extends StatefulWidget {
  final Map<String, dynamic> user; // Rol e info de usuario
  final VoidCallback onClose;
  final Function(String action) onActionTap;

  const FABMenuOverlay({
    super.key,
    required this.user,
    required this.onClose,
    required this.onActionTap,
  });

  @override
  State<FABMenuOverlay> createState() => _FABMenuOverlayState();
}

class _FABMenuOverlayState extends State<FABMenuOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _staggeredAnimations;

  final List<Map<String, dynamic>> _allActions = [
    {'id': 'post', 'label': 'Crear Publicación', 'icon': LucideIcons.edit3, 'color': const Color(0xFF3B82F6)},
    {'id': 'schedule', 'label': 'Ver Agenda / Horario', 'icon': LucideIcons.calendar, 'color': const Color(0xFFF59E0B)},
    {'id': 'portal', 'label': 'Portal Exitus', 'icon': LucideIcons.compass, 'color': const Color(0xFF8B5CF6)},
    {'id': 'topico', 'label': 'Tópico / Enfermería', 'icon': LucideIcons.activity, 'color': const Color(0xFFEF4444)},
    {'id': 'psicologia', 'label': 'Psicología', 'icon': LucideIcons.heart, 'color': const Color(0xFFEC4899)},
    {'id': 'tesoreria', 'label': 'Pensiones y Pagos', 'icon': LucideIcons.landmark, 'color': const Color(0xFF10B981)},
    {'id': 'firma', 'label': 'Firma Rápida', 'icon': LucideIcons.penTool, 'color': const Color(0xFF6B7280)},
    {'id': 'qr_attendance', 'label': 'Asistencia / QR', 'icon': LucideIcons.userCheck, 'color': const Color(0xFF06B6D4)},
    {'id': 'actia', 'label': 'Sesiones ActIA', 'icon': LucideIcons.cpu, 'color': const Color(0xFF6366F1)},
    {'id': 'digitacion', 'label': 'Área de Digitación', 'icon': LucideIcons.printer, 'color': const Color(0xFF7C3AED)},
    {'id': 'dojo_shop', 'label': 'Tienda Dojo', 'icon': LucideIcons.shoppingBag, 'color': const Color(0xFFFF7043)},
    {'id': 'curr', 'label': 'Plan Curricular', 'icon': LucideIcons.briefcase, 'color': const Color(0xFF26C6DA)},
    {'id': 'diary', 'label': 'Bitácoras / Diario', 'icon': LucideIcons.book, 'color': const Color(0xFFAB47BC)},
    {'id': 'my_attendance', 'label': 'Mi Asistencia', 'icon': LucideIcons.calendarCheck2, 'color': const Color(0xFF66BB6A)},
  ];

  late final List<Map<String, dynamic>> _actions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Filtrar según el rol del usuario
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

    // Animación escalonada para los botones filtrados
    _staggeredAnimations = List.generate(_actions.length, (index) {
      final double start = (index * 0.05).clamp(0.0, 0.4);
      final double end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
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
    return GestureDetector(
      onTap: _closeWithAnim,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 1. Fondo de desenfoque frosted glass
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: const Color(0xFF1D2848).withValues(alpha: 0.25),
                ),
              ),
            ),

            // 2. Columna de 9 Acciones Rápidas (flotando del lado derecho hacia arriba)
            Positioned(
              right: 20,
              bottom: 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_actions.length, (index) {
                  // Invertir orden visual para que las primeras estén más cerca del botón FAB
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
                            // Etiqueta del botón
                            Card(
                              color: const Color(0xFF1D2848),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

                            // Botón Circular de Acción
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
                                      color: const Color(0xFF1D2848).withValues(alpha: 0.12),
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

            // 3. Botón Flotante Central FAB convertido en X roja
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2.356, // Rotar 135 grados en radianes (3/4 de pi)
                    child: FloatingActionButton(
                      onPressed: _closeWithAnim,
                      backgroundColor: Color.lerp(
                        const Color(0xFF1D2848),
                        const Color(0xFFD32F2F),
                        _controller.value,
                      ),
                      elevation: 8,
                      shape: const CircleBorder(),
                      child: const Icon(
                        LucideIcons.plus,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
