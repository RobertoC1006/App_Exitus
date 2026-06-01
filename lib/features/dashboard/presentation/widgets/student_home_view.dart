import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

// Vistas del estudiante
import 'package:app_exitus/features/messages/presentation/widgets/inbox_messages_view.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/inner_classroom_drawer.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/fab_menu_overlay.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/launchpad_overlay.dart';
import 'package:app_exitus/features/classroom/presentation/screens/student_courses_screen.dart';
import 'package:app_exitus/features/classroom/presentation/screens/student_dojo_store_screen.dart';

class StudentHomeView extends ConsumerStatefulWidget {
  final User studentUser;
  final List<Map<String, dynamic>> studentCourses;
  final Function(int index) onTabChanged;

  const StudentHomeView({
    super.key,
    required this.studentUser,
    required this.studentCourses,
    required this.onTabChanged,
  });

  @override
  ConsumerState<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends ConsumerState<StudentHomeView> {
  int _currentIndex = 0;
  final MockDatabase _db = MockDatabase();
  StateSetter? _modalStateSetter;

  void _updateState(VoidCallback fn) {
    setState(fn);
    if (_modalStateSetter != null) {
      _modalStateSetter!(() {});
    }
  }

  final List<LinearGradient> _courseGradients = const [
    LinearGradient(
      colors: [Color(0xFFFF7043), Color(0xFFFFA726)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFAB47BC), Color(0xFFEC407A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF9CCC65)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  // Estados de overlays
  bool _isFABMenuOpen = false;
  bool _isLaunchpadOpen = false;

  // Estados de la vista de aula virtual estudiantil
  int _classroomTab = 0; // 0: Cursos, 1: Tareas
  String _taskFilter = 'pending'; // 'pending' o 'completed'

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        _classroomTab = 1; // Default to Tareas tab when clicked from bottom bar
      }
    });
  }

  void handleLogout() {
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
    final currentAuthState = ref.read(authControllerProvider);
    if (currentAuthState is! AuthAuthenticated) return;
    final studentUser = currentAuthState.user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: InnerClassroomDrawer(
            course: course,
            isTeacher: false,
            currentUser: studentUser,
          ),
        );
      },
    );
  }

  void _handleFABAction(String action) {
    if (action == 'dojo_shop') {
      final currentAuthState = ref.read(authControllerProvider);
      if (currentAuthState is AuthAuthenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDojoStoreScreen(
              studentUser: currentAuthState.user,
              currentPoints: 4850,
            ),
          ),
        );
      }
      return;
    }
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
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
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
                        _currentIndex = 1; // Redirigir a Avisos (muro)
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
                              selectedColor: const Color(0xFFEDC620).withValues(alpha: 0.2),
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

  void showClassroomBottomSheet(User studentUser, List<Map<String, dynamic>> studentCourses, int initialTab) {
    setState(() {
      _classroomTab = initialTab;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _modalStateSetter = setModalState;
            return FractionallySizedBox(
              heightFactor: 0.85,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF9E6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.bookOpen,
                              color: Color(0xFFE5A93B),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "AULA VIRTUAL",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildClassroomTabContent(studentCourses, studentUser),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _modalStateSetter = null;
    });
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

  bool _showAllAttendance = false;

  void _showUserSwitcherDialog(User currentUser) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "CAMBIAR DE USUARIO",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Franco Alexis B. (Admin)
                _buildUserOptionItem(
                  context,
                  name: "Franco Alexis B.",
                  role: "Administrador (Práctante)",
                  avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150",
                  isSelected: currentUser.role == 'admin',
                  onTap: () => _switchUser('admin123'),
                ),
                
                // Nicole Sulay A. (Profesor)
                _buildUserOptionItem(
                  context,
                  name: "Nicole Sulay A.",
                  role: "Profesor",
                  avatar: "https://images.unsplash.com/photo-1544717305-2782549b5136?w=150",
                  isSelected: currentUser.role == 'teacher',
                  onTap: () => _switchUser('profesor123'),
                ),
                
                // Mateo Guerrero (Estudiante)
                _buildUserOptionItem(
                  context,
                  name: "Mateo Guerrero",
                  role: "Estudiante (5° Sec.)",
                  avatar: "https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150",
                  isSelected: currentUser.role == 'student' && currentUser.username == 'mateo123',
                  onTap: () => _switchUser('mateo123'),
                ),
                
                // Marco Guerrero (Padre / Apoderado)
                _buildUserOptionItem(
                  context,
                  name: "Marco Guerrero",
                  role: "Padre / Apoderado",
                  avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150",
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("El rol de Apoderado está en simulación. Seleccione Estudiante o Profesor."),
                        backgroundColor: Color(0xFF1D2848),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserOptionItem(
    BuildContext context, {
    required String name,
    required String role,
    required String avatar,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDC620).withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFEDC620).withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(avatar),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        subtitle: Text(
          role,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: isSelected
            ? const Icon(LucideIcons.check, color: Color(0xFFE5A93B), size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }

  void _switchUser(String username) async {
    Navigator.pop(context); // Cerrar diálogo switcher
    
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848))),
                SizedBox(height: 12),
                Text("Iniciando sesión...", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await ref.read(authControllerProvider.notifier).login(username, '12345678');
    
    if (mounted) {
      Navigator.pop(context); // Quitar diálogo de carga
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesión iniciada con éxito."),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al cambiar de sesión."),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  Widget _buildStudentAttendanceTab(User studentUser) {
    final attendanceLogs = _db.getAttendanceLogsForUser(studentUser.id);
    final validLogs = attendanceLogs.where((log) => log.status != 'SIN_REGISTRO').toList();
    final totalDays = validLogs.length;
    final punctualDays = validLogs.where((log) => log.status == 'PUNTUAL').length;
    final tardanzaDays = validLogs.where((log) => log.status == 'TARDANZA').length;
    final faltaDays = validLogs.where((log) => log.status == 'FALTA').length;
    final double punctualRate = totalDays > 0 ? (punctualDays / totalDays) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Control de Asistencia",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Visualiza tus registros diarios de ingreso y salida escolar.",
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
                    "Registro de Asistencia Reciente (Mayo 2026)",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      _showAllAttendance ? attendanceLogs.length : 5.clamp(0, attendanceLogs.length),
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
                        _showAllAttendance ? "VER MENOS" : "VER DETALLE MENSUAL COMPLETO",
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

  Widget _buildAttendanceKpi(String label, String value, Color color, Color bg) {
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
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: fg),
              ),
              Container(
                width: 1.5,
                height: 32,
                color: const Color(0xFFE2E8F0),
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  void showMessagesBottomSheet(User studentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: InboxMessagesView(
              currentUser: studentUser,
              onMessageRead: () => setState(() {}),
            ),
          ),
        );
      },
    );
  }

  void _showAttendanceBottomSheet(User studentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _buildStudentAttendanceTab(studentUser),
          ),
        );
      },
    );
  }

  void _showGradesBottomSheet(User studentUser) {
    final grades = _db.getGradesForUser(studentUser.id);
    double totalSum = 0;
    for (var g in grades) {
      totalSum += g.val;
    }
    final average = grades.isNotEmpty ? (totalSum / grades.length) : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      "MIS CALIFICACIONES",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D2848).withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1D2848).withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Promedio General",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D2848),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Segundo Trimestre Escolar",
                                style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D2848),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              average.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEDC620),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: grades.isEmpty
                          ? const Center(
                              child: Text(
                                "No hay calificaciones registradas.",
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: grades.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final grade = grades[index];
                                final isLow = grade.val < 11;
                                
                                return Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: ExpansionTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isLow ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          grade.code,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isLow ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        grade.course,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1D2848),
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLow ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          grade.val.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isLow ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                      children: grade.details.map((d) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                d.type,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                d.val.toStringAsFixed(0),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D2848),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
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

  void _showDojoStoreBottomSheet(User studentUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDojoStoreScreen(
          studentUser: studentUser,
          currentPoints: 4850,
        ),
      ),
    );
  }

  Widget _buildStudentHomeView(User studentUser, List<Map<String, dynamic>> studentCourses) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 250 + statusBarHeight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner Card (Full-Bleed, taller, status-bar aware)
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9F3FF), Color(0xFFF5F9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
                                    studentUser.fullName.split(' ').first,
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
                                    "Estudiante",
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
                        'assets/images/student_avatar.png',
                        height: 230,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 140,
                          alignment: Alignment.bottomCenter,
                          child: const Icon(Icons.person, size: 80, color: Colors.blueGrey),
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
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentCoursesScreen(
                    studentUser: studentUser,
                    initialCourses: studentCourses,
                  ),
                ),
              );
              if (result != null && result is int) {
                if (result == 99) {
                  setState(() {
                    _isFABMenuOpen = true;
                  });
                } else {
                  _onTabChanged(result);
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 160,
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
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 8,
                      child: Container(color: const Color(0xFFF9C824)),
                    ),
                    Positioned(
                      top: 16,
                      left: 24,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.bookOpen,
                          color: Color(0xFFE5A93B),
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 58,
                      left: 24,
                      right: 125,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cursos",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Accede a tus cursos, materiales y actividades.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 24,
                      child: Icon(
                        LucideIcons.arrowRight,
                        color: Color(0xFFF9C824),
                        size: 18,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Image.asset(
                        'assets/images/mascot_cursos.png',
                        width: 120,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Fila Notas y Horario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showGradesBottomSheet(studentUser),
                    child: Container(
                      height: 220,
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
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.fileText,
                                  color: Color(0xFF1E88E5),
                                  size: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 56,
                              left: 20,
                              right: 32,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Notas",
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1D2848),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Revisa tus calificaciones y tu progreso.",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              bottom: 16,
                              left: 20,
                              child: Icon(
                                LucideIcons.arrowRight,
                                color: Color(0xFF1E88E5),
                                size: 16,
                              ),
                            ),
                            Positioned(
                              right: -5,
                              bottom: -5,
                              child: Image.asset(
                                'assets/images/mascot_notas.png',
                                width: 75,
                                height: 95,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomRight,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _showScheduleSheet,
                    child: Container(
                      height: 220,
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
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF3E0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.calendar,
                                  color: Color(0xFFF57C00),
                                  size: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 56,
                              left: 20,
                              right: 32,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Horario",
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1D2848),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Consulta tu horario de clases semanal.",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              bottom: 16,
                              left: 20,
                              child: Icon(
                                LucideIcons.arrowRight,
                                color: Color(0xFFF57C00),
                                size: 16,
                              ),
                            ),
                            Positioned(
                              right: -5,
                              bottom: -5,
                              child: Image.asset(
                                'assets/images/mascot_horario.png',
                                width: 75,
                                height: 95,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomRight,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Tarjeta Tienda Dojo
          GestureDetector(
            onTap: () => _showDojoStoreBottomSheet(studentUser),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 170,
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFE1F5FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.shoppingBag,
                          color: Color(0xFF0288D1),
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 58,
                      left: 24,
                      right: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tienda Dojo",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Canjea tus puntos por premios increíbles.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 24,
                      child: Icon(
                        LucideIcons.arrowRight,
                        color: Color(0xFF0288D1),
                        size: 18,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 0,
                      top: 10,
                      child: Image.asset(
                        'assets/images/mascot_tienda.png',
                        width: 110,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentUser = widget.studentUser;
    final studentCourses = widget.studentCourses;

    return Stack(
      children: [
        _buildStudentHomeView(studentUser, studentCourses),
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
                });
                if (route == 'classroom') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentCoursesScreen(
                        studentUser: studentUser,
                        initialCourses: studentCourses,
                      ),
                    ),
                  ).then((result) {
                    if (result != null && result is int) {
                      if (result == 99) {
                        setState(() {
                          _isFABMenuOpen = true;
                        });
                      } else {
                        widget.onTabChanged(result);
                      }
                    }
                  });
                } else if (route == 'messages') {
                  widget.onTabChanged(2); // Redirect to Messages
                } else if (route == 'attendance') {
                  _showAttendanceBottomSheet(studentUser);
                }
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

  Widget buildStudentHeader(User student, String title, int unreadCount) {
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
                onTap: () => _showUserSwitcherDialog(student),
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
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
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

  Widget buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2848),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFEDC620), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentTasksView(User user) {
    final tasks = _db.getTasksForUser(user.id);
    final filteredTasks = tasks.where((t) => t.status == _taskFilter).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.briefcase,
                    color: Color(0xFFE5A93B),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "MIS TAREAS Y ENTREGAS",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTaskFilterButton('pending', "Pendientes", tasks.where((t) => t.status == 'pending').length),
                const SizedBox(width: 10),
                _buildTaskFilterButton('completed', "Entregadas", tasks.where((t) => t.status == 'completed').length),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No hay tareas en esta categoría.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
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
                    return _buildCourseCard(course, index);
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
        onTap: () => _updateState(() => _classroomTab = index),
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
        onPressed: () => _updateState(() => _taskFilter = filter),
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
                color: isSelected ? const Color(0xFFEDC620) : const Color(0xFF94A3B8).withValues(alpha: 0.3),
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

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final gradient = _courseGradients[index % _courseGradients.length];

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8EAF0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openCourseDetails(course),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: gradient,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila superior: Badge de nivel e icono de libro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D2848).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.book, size: 14, color: Color(0xFF1D2848)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B0FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${course['level']} ${course['levelNum']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Título del curso
                        Text(
                          course['title'],
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Tag/Cápsula de área académica
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['tag'] ?? 'CURSO GENERAL',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Fila del docente (Avatar + info)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(course['avatar']),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "DOCENTE",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    course['teacher'],
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1D2848),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Footer: Ver Aula ->
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Ver Aula",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFE5A93B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.arrowRight,
                              color: Color(0xFFE5A93B),
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
