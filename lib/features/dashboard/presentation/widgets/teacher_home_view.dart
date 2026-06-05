import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_exitus/features/dashboard/presentation/widgets/fab_menu_overlay.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/launchpad_overlay.dart';
import 'package:app_exitus/features/digitacion/presentation/screens/digitacion_dashboard_screen.dart';
import 'package:app_exitus/features/classroom/presentation/screens/teacher_courses_screen.dart';
import 'package:app_exitus/features/bitacora/presentation/screens/bitacora_dashboard_screen.dart';

class TeacherHomeView extends ConsumerStatefulWidget {
  final User teacherUser;
  final List<Map<String, dynamic>> teacherCourses;
  final Function(int index) onTabChanged;

  const TeacherHomeView({
    super.key,
    required this.teacherUser,
    required this.teacherCourses,
    required this.onTabChanged,
  });

  @override
  ConsumerState<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends ConsumerState<TeacherHomeView> {
  final MockDatabase _db = MockDatabase();
  bool _showAllAttendance = false;

  // Estados de overlays
  bool _isFABMenuOpen = false;
  bool _isLaunchpadOpen = false;

  void _handleFABAction(String action) {
    if (action == 'portal') {
      setState(() {
        _isLaunchpadOpen = true;
      });
    } else if (action == 'post') {
      _showCreatePostSheet();
    } else if (action == 'schedule') {
      _showScheduleSheet();
    } else if (action == 'qr_attendance') {
      _showQRModal();
    } else if (action == 'digitacion') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DigitacionDashboardScreen(),
        ),
      );
    } else if (action == 'my_attendance' || action == 'attendance_report') {
      final currentAuthState = ref.read(authControllerProvider);
      if (currentAuthState is AuthAuthenticated) {
        _showAttendanceBottomSheet(currentAuthState.user);
      }
    } else if (action == 'tesoreria') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Módulo exclusivo para administración y tesorería escolar.",
          ),
        ),
      );
    } else {
      _showSimulatedSubmenu(action);
    }
  }

  void _showSimulatedSubmenu(String actionId) {
    String title = "Módulo Exitus";
    IconData icon = LucideIcons.compass;
    Color color = const Color(0xFF1D2848);
    List<String> items = [];

    if (actionId == 'topico') {
      title = "Tópico / Enfermería";
      icon = LucideIcons.activity;
      color = const Color(0xFFEF4444);
      items = [
        "Ficha Médica Consolidada",
        "Registrar Incidente en Aula",
        "Historial de Derivaciones",
        "Medicamentos Autorizados",
      ];
    } else if (actionId == 'psicologia') {
      title = "Psicología & Consejería";
      icon = LucideIcons.heart;
      color = const Color(0xFFEC4899);
      items = [
        "Derivaciones Pendientes",
        "Talleres Emocionales Activos",
        "Recomendaciones Psicoeducativas",
        "Mis Alumnos en Seguimiento",
      ];
    } else if (actionId == 'actia') {
      title = "Sesiones ActIA";
      icon = LucideIcons.cpu;
      color = const Color(0xFF6366F1);
      items = [
        "Asistente IA de Clases",
        "Analítica de Progreso IA",
        "Sugerencias de Planificación",
        "Consultas Recientes",
      ];
    } else if (actionId == 'firma') {
      title = "Firma Rápida de Actas";
      icon = LucideIcons.penTool;
      color = const Color(0xFF6B7280);
      items = [
        "Firma de Actas Trimestrales",
        "Registros de Asistencia Oficial",
        "Firmar Justificaciones Aprobadas",
      ];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      items[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 14),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Abriendo ${items[index]}...")),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePostSheet() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "CREAR COMUNICADO EN EL MURO",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText:
                        "Escribe un comunicado para compartir con padres y alumnos en el muro...",
                    filled: true,
                    fillColor: const Color(0xFFF5F6F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final currentAuthState = ref.read(authControllerProvider);
                      final newPost = SocialPost(
                        id: _db.getSocialPosts().length + 1,
                        publisher: currentAuthState is AuthAuthenticated
                            ? currentAuthState.user.fullName
                            : "Docente Exitus",
                        avatar: currentAuthState is AuthAuthenticated
                            ? currentAuthState.user.avatarUrl
                            : "https://images.unsplash.com/photo-1544717305-2782549b5136?w=150",
                        time: 'Hace un momento',
                        tag: 'Comunicado',
                        content: text,
                        userReactions: {
                          'likes': false,
                          'loves': false,
                          'bravos': false,
                          'insights': false,
                          'haha': false,
                          'sad': false,
                        },
                        comments: [],
                      );
                      _db.getSocialPosts().insert(0, newPost);
                      Navigator.pop(context);
                      widget.onTabChanged(1); // Redirigir a muro
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Comunicado publicado con éxito."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("PUBLICAR COMUNICADO"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String activeDay = "Miércoles";

        return StatefulBuilder(
          builder: (context, setModalState) {
            final items = _db.teacherSchedule[activeDay] ?? [];
            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "MI AGENDA Y HORARIO DE CLASES",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Selector de días de la semana
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              'Lunes',
                              'Martes',
                              'Miércoles',
                              'Jueves',
                              'Viernes',
                            ].map((day) {
                              final isSel = day == activeDay;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSel
                                          ? const Color(0xFF1D2848)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: const Color(
                                    0xFFEDC620,
                                  ).withValues(alpha: 0.2),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  onSelected: (val) {
                                    setModalState(() {
                                      activeDay = day;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de clases
                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Text(
                                "No tienes clases asignadas para este día.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isComp = item.status == 'completed';
                                final isActive = item.status == 'active';

                                return Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isComp
                                                ? const Color(0xFF2E7D32)
                                                : (isActive
                                                      ? const Color(0xFFEDC620)
                                                      : const Color(
                                                          0xFF64748B,
                                                        )),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.subject,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D2848),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${item.time} • ${item.classroom}",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF8E1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  LucideIcons.activity,
                                                  size: 8,
                                                  color: Color(0xFFE6A817),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  "EN VIVO",
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE6A817),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
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
          },
        );
      },
    );
  }

  void _showQRModal() {
    showDialog(
      context: context,
      builder: (context) {
        final currentAuthState = ref.read(authControllerProvider);
        if (currentAuthState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }
        final user = currentAuthState.user;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDC620), width: 1.5),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pase Digital de Docente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2848),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16),
                const SizedBox(height: 10),
                Image.network(
                  'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${user.id}',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 20),
                Text(
                  user.fullName.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        LucideIcons.check,
                        size: 12,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Ingreso Autorizado",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthState = ref.watch(authControllerProvider);
    if (currentAuthState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final teacherUser = currentAuthState.user;

    // Configurar los cursos/aulas asignadas al docente
    final List<Map<String, dynamic>> teacherCourses = teacherUser.subjects.map((
      sub,
    ) {
      String level = "SECUNDARIA";
      String levelNum = sub.contains('5to') ? '5°' : '4°';
      String room = sub.contains('5to A')
          ? 'Aula A'
          : (sub.contains('5to B') ? 'Aula B' : 'Aula C');
      String avatar = sub.contains('Matemática')
          ? 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100'
          : 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100';

      return {
        'id': 'c_${sub.replaceAll(' ', '_')}',
        'title': sub,
        'level': level,
        'levelNum': levelNum,
        'room': room,
        'avatar': avatar,
        'teacher': teacherUser.fullName,
      };
    }).toList();

    return Stack(
      children: [
        _buildTeacherHomeView(teacherUser, teacherCourses),

        // 3. Superposición del Menú FAB
        if (_isFABMenuOpen)
          Positioned.fill(
            child: FABMenuOverlay(
              user: {'role': 'teacher'},
              onClose: () {
                setState(() {
                  _isFABMenuOpen = false;
                });
              },
              onActionTap: _handleFABAction,
            ),
          ),

        // 4. Superposición del Launchpad
        if (_isLaunchpadOpen)
          Positioned.fill(
            child: LaunchpadOverlay(
              user: {'role': 'teacher'},
              onClose: () {
                setState(() {
                  _isLaunchpadOpen = false;
                });
              },
              onNavigate: (route) {
                setState(() {
                  _isLaunchpadOpen = false;
                  if (route == 'classroom') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherCoursesScreen(
                          teacherUser: teacherUser,
                          courses: teacherCourses,
                        ),
                      ),
                    ).then((value) {
                      if (value != null && value is int && value != 99) {
                        widget.onTabChanged(value);
                      }
                    });
                  } else if (route == 'digitacion') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DigitacionDashboardScreen(),
                      ),
                    );
                  }
                });
              },
              onSubmenuTap: (submenuId) {
                setState(() {
                  _isLaunchpadOpen = false;
                });
                _handleFABAction(submenuId);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTeacherAttendanceTab(User teacherUser) {
    final attendanceLogs = _db.getAttendanceLogsForUser(teacherUser.id);
    final validLogs = attendanceLogs
        .where((log) => log.status != 'SIN_REGISTRO')
        .toList();
    final totalDays = validLogs.length;
    final punctualDays = validLogs
        .where((log) => log.status == 'PUNTUAL')
        .length;
    final tardanzaDays = validLogs
        .where((log) => log.status == 'TARDANZA')
        .length;
    final faltaDays = validLogs.where((log) => log.status == 'FALTA').length;
    final double punctualRate = totalDays > 0
        ? (punctualDays / totalDays) * 100
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Control de Asistencia Docente",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Visualiza tus registros diarios de ingreso y salida al centro educativo.",
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAttendanceKpi(
                          "Puntualidad",
                          "${punctualRate.toStringAsFixed(0)}%",
                          const Color(0xFF2E7D32),
                          const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceKpi(
                          "Tardanzas",
                          "$tardanzaDays",
                          const Color(0xFFC09F00),
                          const Color(0xFFFFFDE7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAttendanceKpi(
                          "Faltas",
                          "$faltaDays",
                          const Color(0xFFD32F2F),
                          const Color(0xFFFFEBEE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  const Text(
                    "Registro de Asistencia de Docente (Mayo 2026)",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      _showAllAttendance
                          ? attendanceLogs.length
                          : 5.clamp(0, attendanceLogs.length),
                      (index) {
                        final log = attendanceLogs[index];
                        return _buildAttendanceTimelineItem(log);
                      },
                    ),
                  ),
                  if (attendanceLogs.length > 5) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllAttendance = !_showAllAttendance;
                        });
                      },
                      child: Text(
                        _showAllAttendance
                            ? "VER MENOS"
                            : "VER DETALLE MENSUAL COMPLETO",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2848),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceKpi(
    String label,
    String value,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTimelineItem(AttendanceLog log) {
    Color bg;
    Color fg;
    String statusText;
    IconData icon;

    switch (log.status) {
      case 'PUNTUAL':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        statusText = "Puntual";
        icon = LucideIcons.checkCircle;
        break;
      case 'TARDANZA':
        bg = const Color(0xFFFFFDE7);
        fg = const Color(0xFFC09F00);
        statusText = "Tardanza";
        icon = LucideIcons.clock;
        break;
      case 'FALTA':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFD32F2F);
        statusText = "Falta";
        icon = LucideIcons.xCircle;
        break;
      case 'SIN_REGISTRO':
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        statusText = "Sin Registro";
        icon = LucideIcons.minusCircle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 12, color: fg),
              ),
              Container(width: 1.5, height: 32, color: const Color(0xFFE2E8F0)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${log.dayName} ${log.dayNum} de ${log.month.split(' ')[0]}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log.status == 'SIN_REGISTRO'
                            ? "Fin de semana / Feriado"
                            : "Entrada: ${log.entry} • Salida: ${log.exit}",
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceBottomSheet(User teacherUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(child: _buildTeacherAttendanceTab(teacherUser)),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildTeacherHomeView(
    User teacherUser,
    List<Map<String, dynamic>> teacherCourses,
  ) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 250 + statusBarHeight;

    final firstName = teacherUser.fullName.split(' ').first;
    final displayName = "Prof. $firstName";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner Card
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9F3FF), Color(0xFFF5F9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  left: 24,
                  top: 24 + statusBarHeight,
                  child: Container(
                    width: 36,
                    height: 36,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: OverflowBox(
                      maxWidth: 140,
                      maxHeight: 36,
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/school_logo.png',
                        height: 36,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 68,
                  top: 22 + statusBarHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EXITUS",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1D2848),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        "COLEGIO",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEDC620),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 22 + statusBarHeight,
                  child: GestureDetector(
                    onTap: () => widget.onTabChanged(1),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.bell,
                            size: 16,
                            color: Color(0xFF1D2848),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDC620),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 12,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Hola, ",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1D2848),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    displayName,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFEDC620),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 100,
                                height: 1,
                                color: const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    "ROL: ",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF64748B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Profesor",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1D2848),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/profesor_avatar.png',
                        height: 230,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 140,
                          alignment: Alignment.bottomCenter,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Tarjeta Cursos
          _buildFullWidthCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherCoursesScreen(
                    teacherUser: teacherUser,
                    courses: teacherCourses,
                  ),
                ),
              ).then((value) {
                if (value != null && value is int && value != 99) {
                  widget.onTabChanged(value);
                }
              });
            },
            icon: LucideIcons.bookOpen,
            iconColor: const Color(0xFF1E88E5),
            iconBg: const Color(0xFFE3F2FD),
            title: "Mis Cursos",
            subtitle: "Gestiona tus cursos, materiales, tareas y contenidos.",
            arrowColor: const Color(0xFF1E88E5),
            assetImage: "assets/images/mascot_cursos_3d.png",
          ),
          const SizedBox(height: 16),

          // 3. Grid de Digitación y Bitácoras
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DigitacionDashboardScreen(),
                        ),
                      );
                    },
                    icon: LucideIcons.printer,
                    iconColor: const Color(0xFF7E57C2),
                    iconBg: const Color(0xFFEDE7F6),
                    title: "Digitación",
                    subtitle:
                        "Envía solicitudes de impresión y revisa su estado.",
                    arrowColor: const Color(0xFF7E57C2),
                    assetImage: "assets/images/mascot_digitacion.png",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BitacoraDashboardScreen(),
                        ),
                      );
                    },
                    icon: LucideIcons.clipboard,
                    iconColor: const Color(0xFFEC407A),
                    iconBg: const Color(0xFFFCE4EC),
                    title: "Bitácoras",
                    subtitle:
                        "Registra y gestiona incidencias de tus estudiantes.",
                    arrowColor: const Color(0xFFEC407A),
                    assetImage: "assets/images/mascot_bitacoras.png",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Tarjeta Horario
          _buildFullWidthCard(
            onTap: _showScheduleSheet,
            icon: LucideIcons.calendar,
            iconColor: const Color(0xFFF57C00),
            iconBg: const Color(0xFFFFF3E0),
            title: "Horario",
            subtitle: "Consulta tu horario de clases.",
            arrowColor: const Color(0xFFF57C00),
            assetImage: "assets/images/mascot_horario_3d.png",
          ),
          const SizedBox(height: 24),

          // 5. Horario Hoy
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hoy",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showScheduleSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Ver horario completo",
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.chevronRight,
                              color: Color(0xFF1D2848),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 4),
                _buildSchedulePreviewRow(
                  "08:00",
                  "Álgebra",
                  "5° A",
                  const Color(0xFF42A5F5),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSchedulePreviewRow(
                  "10:00",
                  "Física",
                  "4° B",
                  const Color(0xFFFFA726),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSchedulePreviewRow(
                  "12:00",
                  "Tutoría",
                  "3° A",
                  const Color(0xFF66BB6A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color arrowColor,
    required String assetImage,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              // Leave 65px on the right to avoid overlapping the 3D asset image
              final textWidth = (cardWidth - 20 - 65).clamp(
                0.0,
                double.infinity,
              );

              return Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    left: 20,
                    width: textWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Icon(
                      LucideIcons.arrowRight,
                      color: arrowColor,
                      size: 16,
                    ),
                  ),
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Image.asset(
                      assetImage,
                      width: 75,
                      height: 95,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthCard({
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color arrowColor,
    required String assetImage,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 145,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
              Positioned(
                top: 54,
                left: 24,
                right: 125,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 24,
                child: Icon(
                  LucideIcons.arrowRight,
                  color: arrowColor,
                  size: 16,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Image.asset(
                  assetImage,
                  width: 110,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulePreviewRow(
    String time,
    String subject,
    String section,
    Color dotColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            subject,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D2848),
            ),
          ),
          const Spacer(),
          Text(
            section,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
