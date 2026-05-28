import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

// Vistas del estudiante
import 'package:app_exitus/features/social_feed/presentation/widgets/social_feed_view.dart';
import 'package:app_exitus/features/messages/presentation/widgets/inbox_messages_view.dart';
import 'package:app_exitus/features/profile/presentation/widgets/student_profile_view.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/inner_classroom_drawer.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/fab_menu_overlay.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/launchpad_overlay.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _currentIndex = 0;
  final MockDatabase _db = MockDatabase();

  // Estados de overlays
  bool _isFABMenuOpen = false;
  bool _isLaunchpadOpen = false;

  // Estados de la vista de aula virtual estudiantil
  int _classroomTab = 0; // 0: Cursos, 1: Tareas
  String _taskFilter = 'pending'; // 'pending' o 'completed'

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.logOut, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("¿Estás seguro de que deseas salir del portal estudiantil?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  void _openCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: InnerClassroomDrawer(course: course),
        );
      },
    );
  }

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
    } else if (action == 'tesoreria') {
      setState(() {
        _currentIndex = 3; // Redirigir a Mi Cuenta (finanzas)
      });
    } else {
      // Submenús simulados
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
      items = ["Ficha Médica Alumno", "Registrar Incidente de Salud", "Historial de Atenciones", "Alergias y Medicamentos"];
    } else if (actionId == 'psicologia') {
      title = "Psicología & Consejería";
      icon = LucideIcons.heart;
      color = const Color(0xFFEC4899);
      items = ["Solicitar Cita de Consejería", "Mis Citaciones Pendientes", "Talleres Emocionales", "Recursos Psicoeducativos"];
    } else if (actionId == 'actia') {
      title = "Sesiones ActIA";
      icon = LucideIcons.cpu;
      color = const Color(0xFF6366F1);
      items = ["Nueva Consulta a ActIA", "Sugerencias de Estudio", "Reporte de Progreso IA", "Historial de Consultas"];
    } else if (actionId == 'firma') {
      // Exclusivo directivos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Acceso denegado: Módulo de firma exclusiva para directivos y docentes."),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
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
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(items[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(
                  "CREAR PUBLICACIÓN EN MURO",
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: "Escribe un comunicado o mensaje para compartir en el muro...",
                    filled: true,
                    fillColor: const Color(0xFFF5F6F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final newPost = SocialPost(
                        id: _db.getSocialPosts().length + 1,
                        publisher: ref.read(authControllerProvider) is AuthAuthenticated
                            ? (ref.read(authControllerProvider) as AuthAuthenticated).user.fullName
                            : "Estudiante Exitus",
                        avatar: ref.read(authControllerProvider) is AuthAuthenticated
                            ? (ref.read(authControllerProvider) as AuthAuthenticated).user.avatarUrl
                            : "https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150",
                        time: 'Hace un momento',
                        tag: 'Estudiante',
                        content: text,
                        userReactions: {'likes': false, 'loves': false, 'bravos': false, 'insights': false, 'haha': false, 'sad': false},
                        comments: [],
                      );
                      _db.getSocialPosts().insert(0, newPost);
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0; // Redirigir a muro
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Publicado en el muro con éxito.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("PUBLICAR"),
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
    final schedule = ref.read(authControllerProvider) is AuthAuthenticated &&
            (ref.read(authControllerProvider) as AuthAuthenticated).user.username.contains('sofia')
        ? _db.sofiaSchedule
        : _db.mateoSchedule;

    String activeDay = "Miércoles";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final items = schedule[activeDay] ?? [];
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
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "MI AGENDA Y HORARIO",
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Selector de días de la semana
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'].map((day) {
                          final isSel = day == activeDay;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(day, style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, color: isSel ? const Color(0xFF1D2848) : const Color(0xFF64748B))),
                              selected: isSel,
                              selectedColor: const Color(0xFFEDC620).withOpacity(0.2),
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
                          ? const Center(child: Text("No hay clases programadas para este día.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))))
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isComp = item.status == 'completed';
                                final isActive = item.status == 'active';

                                return Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Indicador visual estado
                                        Container(
                                          width: 4,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isComp
                                                ? const Color(0xFF2E7D32)
                                                : (isActive ? const Color(0xFFEDC620) : const Color(0xFF64748B)),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.subject, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                                              const SizedBox(height: 2),
                                              Text("${item.time} • ${item.classroom}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
                                            child: Row(
                                              children: const [
                                                Icon(LucideIcons.activity, size: 8, color: Color(0xFFE6A817)),
                                                SizedBox(width: 2),
                                                Text("EN VIVO", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFE6A817))),
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
        if (currentAuthState is! AuthAuthenticated) return const SizedBox.shrink();
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
                    const Text("Pase Digital de Ingreso", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                    IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => Navigator.pop(context)),
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
                Text(user.fullName.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.check, size: 12, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text("Pase Autorizado", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
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
    final studentUser = currentAuthState.user;

    // Configurar los 5 cursos del alumno
    final List<Map<String, dynamic>> studentCourses = studentUser.username.contains('sofia')
        ? [
            {'id': 'c1', 'title': 'Matemáticas', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'teacher': 'Prof. Carlos Oliva'},
            {'id': 'c2', 'title': 'Ciencias', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Miss Ana María'},
            {'id': 'c3', 'title': 'Literatura', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Miss Ana María'},
            {'id': 'c4', 'title': 'Inglés', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Lab. Primaria', 'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'teacher': 'Miss Sara Conner'},
          ]
        : [
            {'id': 'c1', 'title': 'Matemáticas', 'level': 'SECUNDARIA', 'levelNum': '5°', 'room': 'Aula A', 'avatar': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', 'teacher': 'Prof. Roberto Carlos'},
            {'id': 'c2', 'title': 'Física', 'level': 'SECUNDARIA', 'levelNum': '5°', 'room': 'Aula A', 'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'teacher': 'Ing. Carlos Mendoza'},
            {'id': 'c3', 'title': 'Ciencias', 'level': 'SECUNDARIA', 'levelNum': '5°', 'room': 'Lab. Química', 'avatar': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=100', 'teacher': 'Dr. Alberto Rossi'},
            {'id': 'c4', 'title': 'Literatura', 'level': 'SECUNDARIA', 'levelNum': '5°', 'room': 'Aula A', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Dra. Julia Mendoza'},
            {'id': 'c5', 'title': 'Inglés', 'level': 'SECUNDARIA', 'levelNum': '5°', 'room': 'Lab. Idiomas', 'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'teacher': 'Miss Sara Conner'},
          ];

    // Vistas asociadas a las 4 pestañas
    final List<Widget> views = [
      SocialFeedView(currentUser: studentUser),
      _buildClassroomTabContent(studentCourses, studentUser),
      InboxMessagesView(currentUser: studentUser, onMessageRead: () => setState(() {})),
      StudentProfileView(currentUser: studentUser, onLogout: _handleLogout),
    ];

    // Títulos de la cabecera
    final List<String> titles = [
      "Muro Institucional",
      "Aula Virtual",
      "Bandeja de Entrada",
      "Mi Cuenta Exitus",
    ];

    // Mensajes no leídos para la cabecera
    final unreadMessages = _db.getMessagesForUser(studentUser.id).where((m) => m.unread).length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // Cabecera premium del estudiante
                _buildStudentHeader(studentUser, titles[_currentIndex], unreadMessages),
                Container(height: 1, color: const Color(0xFFE2E8F0)),

                // Contenido de pestaña activa
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: views,
                  ),
                ),
              ],
            ),
          ),

          // Botón Flotante Central FAB Docked
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isFABMenuOpen = true;
              });
            },
            backgroundColor: const Color(0xFF1D2848),
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          // Barra de navegación inferior
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            elevation: 16,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(0, LucideIcons.home, "INICIO"),
                  _buildBottomNavItem(1, LucideIcons.bookOpen, "AULA"),
                  const SizedBox(width: 48), // Espacio para el FAB central
                  _buildBottomNavItem(2, LucideIcons.mail, "MENSAJES", badgeCount: unreadMessages),
                  _buildBottomNavItem(3, LucideIcons.user, "PERFIL"),
                ],
              ),
            ),
          ),
        ),

        // 3. Superposición del Menú FAB
        if (_isFABMenuOpen)
          Positioned.fill(
            child: FABMenuOverlay(
              user: {'role': 'student'},
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
              user: {'role': 'student'},
              onClose: () {
                setState(() {
                  _isLaunchpadOpen = false;
                });
              },
              onNavigate: (route) {
                setState(() {
                  _isLaunchpadOpen = false;
                  if (route == 'classroom') _currentIndex = 1;
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

  Widget _buildStudentHeader(User student, String title, int unreadCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: const Color(0xFF1D2848), borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child: const Text("E", style: TextStyle(color: Color(0xFFEDC620), fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                  const Text("INTRANET ESTUDIANTIL", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundImage: NetworkImage(student.avatarUrl)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: const Icon(LucideIcons.bell, size: 16, color: Color(0xFF1D2848)),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                          child: Text("$unreadCount", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF1D2848) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 20),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFFEDC620), shape: BoxShape.circle),
                      child: Text("$badgeCount", style: const TextStyle(color: Color(0xFF1D2848), fontSize: 7, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomTabContent(List<Map<String, dynamic>> courses, User user) {
    final tasks = _db.getTasksForUser(user.id);
    final filteredTasks = tasks.where((t) => t.status == _taskFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-navegador de Aula: Cursos vs Tareas
        Container(
          color: Colors.white,
          child: Row(
            children: [
              _buildClassroomSubTab(0, "MIS CURSOS"),
              _buildClassroomSubTab(1, "TAREAS Y ENTREGAS"),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: _classroomTab == 0
              ? ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildCourseCard(course);
                  },
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle de tareas pendientes vs completadas
                      Row(
                        children: [
                          _buildTaskFilterButton('pending', "Pendientes", tasks.where((t) => t.status == 'pending').length),
                          const SizedBox(width: 10),
                          _buildTaskFilterButton('completed', "Entregadas", tasks.where((t) => t.status == 'completed').length),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: filteredTasks.isEmpty
                            ? const Center(child: Text("No hay tareas en esta categoría.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))))
                            : ListView.separated(
                                itemCount: filteredTasks.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return _buildTaskCard(task, user.id);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildClassroomSubTab(int index, String label) {
    final isSelected = _classroomTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _classroomTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF1D2848) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF1D2848) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskFilterButton(String filter, String label, int count) {
    final isSelected = _taskFilter == filter;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _taskFilter = filter),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF1D2848) : const Color(0xFFE2E8F0),
          foregroundColor: isSelected ? Colors.white : const Color(0xFF64748B),
          elevation: 0,
          minimumSize: const Size(100, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEDC620) : const Color(0xFF94A3B8).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1D2848) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      child: InkWell(
        onTap: () => _openCourseDetails(course),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(course['avatar']),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course['teacher'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(StudentTask task, String userId) {
    final isPending = task.status == 'pending';
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.courseName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2848),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  isPending ? "Vence: ${task.due}" : "Entregado",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isPending ? const Color(0xFFEF4444) : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              task.desc,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _db.submitTask(userId, task.id);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(LucideIcons.checkCircle, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Tarea entregada correctamente."),
                        ],
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2848),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("ENTREGAR TAREA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
