import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

// Vistas del docente
import 'package:app_exitus/features/social_feed/presentation/widgets/social_feed_view.dart';
import 'package:app_exitus/features/messages/presentation/widgets/inbox_messages_view.dart';
import 'package:app_exitus/features/profile/presentation/widgets/teacher_profile_view.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/inner_classroom_drawer.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/fab_menu_overlay.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/launchpad_overlay.dart';
import 'package:app_exitus/features/digitacion/presentation/screens/digitacion_dashboard_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final MockDatabase _db = MockDatabase();
  bool _showAllAttendance = false;

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
            Icon(LucideIcons.logOut, color: Color(0xFFC0392B)),
            SizedBox(width: 8),
            Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("¿Estás seguro de que deseas salir del portal docente?"),
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
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  void _openCourseDetails(Map<String, dynamic> course, User teacherUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: InnerClassroomDrawer(
            course: course,
            isTeacher: true,
            currentUser: teacherUser,
          ),
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
    } else if (action == 'digitacion') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DigitacionDashboardScreen()),
      );
    } else if (action == 'tesoreria') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Módulo exclusivo para administración y tesorería escolar.")),
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
      items = ["Ficha Médica Consolidada", "Registrar Incidente en Aula", "Historial de Derivaciones", "Medicamentos Autorizados"];
    } else if (actionId == 'psicologia') {
      title = "Psicología & Consejería";
      icon = LucideIcons.heart;
      color = const Color(0xFFEC4899);
      items = ["Derivaciones Pendientes", "Talleres Emocionales Activos", "Recomendaciones Psicoeducativas", "Mis Alumnos en Seguimiento"];
    } else if (actionId == 'actia') {
      title = "Sesiones ActIA";
      icon = LucideIcons.cpu;
      color = const Color(0xFF6366F1);
      items = ["Asistente IA de Clases", "Analítica de Progreso IA", "Sugerencias de Planificación", "Consultas Recientes"];
    } else if (actionId == 'firma') {
      title = "Firma Rápida de Actas";
      icon = LucideIcons.penTool;
      color = const Color(0xFF6B7280);
      items = ["Firma de Actas Trimestrales", "Registros de Asistencia Oficial", "Firmar Justificaciones Aprobadas"];
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
                  "CREAR COMUNICADO EN EL MURO",
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: "Escribe un comunicado para compartir con padres y alumnos en el muro...",
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
                        userReactions: {'likes': false, 'loves': false, 'bravos': false, 'insights': false, 'haha': false, 'sad': false},
                        comments: [],
                      );
                      _db.getSocialPosts().insert(0, newPost);
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0; // Redirigir a muro
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Comunicado publicado con éxito.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "MI AGENDA Y HORARIO DE CLASES",
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
                          ? const Center(child: Text("No tienes clases asignadas para este día.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))))
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
                    const Text("Pase Digital de Docente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
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
                      Text("Ingreso Autorizado", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
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
    final List<Map<String, dynamic>> teacherCourses = teacherUser.subjects.map((sub) {
      String level = "SECUNDARIA";
      String levelNum = sub.contains('5to') ? '5°' : '4°';
      String room = sub.contains('5to A') ? 'Aula A' : (sub.contains('5to B') ? 'Aula B' : 'Aula C');
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

    // Vistas asociadas a las 5 pestañas
    final List<Widget> views = [
      SocialFeedView(currentUser: teacherUser),
      _buildClassroomTabContent(teacherCourses),
      InboxMessagesView(currentUser: teacherUser, onMessageRead: () => setState(() {})),
      _buildTeacherAttendanceTab(teacherUser), // Nueva pestaña de registro de asistencia
      TeacherProfileView(currentUser: teacherUser, onLogout: _handleLogout),
    ];

    // Títulos de la cabecera
    final List<String> titles = [
      "Muro Institucional",
      "Mis Aulas Virtuales",
      "Mensajes de Docente",
      "Control de Asistencia",
      "Mi Perfil Docente",
    ];

    // Mensajes no leídos para la cabecera
    final unreadMessages = _db.getMessagesForUser(teacherUser.id).where((m) => m.unread).length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // Cabecera premium del docente
                _buildTeacherHeader(teacherUser, titles[_currentIndex], unreadMessages),
                Container(height: 1, color: const Color(0xFFE2E8F0)),

                // Contenido de pestaña activa
                Expanded(
                  child: views[_currentIndex],
                ),
              ],
            ),
          ),

          // Botón Flotante Central FAB now endFloat
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          // Barra de navegación inferior
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            elevation: 16,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(0, LucideIcons.home, "INICIO"),
                  _buildBottomNavItem(1, LucideIcons.bookOpen, "AULAS"),
                  _buildBottomNavItem(2, LucideIcons.mail, "MENSAJES", badgeCount: unreadMessages),
                  _buildBottomNavItem(3, LucideIcons.userCheck, "ASISTENCIAS"),
                  _buildBottomNavItem(4, LucideIcons.user, "MI PERFIL"),
                ],
              ),
            ),
          ),
        ),

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
                    _currentIndex = 1;
                  } else if (route == 'digitacion') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DigitacionDashboardScreen()),
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
        color: isSelected ? const Color(0xFFEDC620).withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFEDC620).withOpacity(0.2) : Colors.transparent,
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

  Widget _buildTeacherHeader(User teacher, String title, int unreadCount) {
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
                  const Text("INTRANET DOCENTE", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showUserSwitcherDialog(teacher),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundImage: NetworkImage(teacher.avatarUrl)),
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

  Widget _buildClassroomTabContent(List<Map<String, dynamic>> courses) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course, index);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final userState = ref.read(authControllerProvider);
    final User user = userState is AuthAuthenticated
        ? userState.user
        : const User(id: 'dummy', username: 'dummy', fullName: 'Docente', email: '', role: 'teacher', avatarUrl: '', subjects: []);

    final gradient = _courseGradients[index % _courseGradients.length];

    // Formatear el badge de la sección (ej. 4° B - SEC o 5° A - SEC)
    String sectionBadge = "${course['levelNum']} ${course['room'].replaceAll('Aula ', '')} - SEC";

    // Tag o Area academica
    String areaTag = course['title'].contains('Matemática')
        ? 'CIENCIAS EXACTAS y MATEMÁTICA'
        : 'EDUCACIÓN PARA EL TRABAJO';

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
          onTap: () => _openCourseDetails(course, user),
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
                        // Fila superior: Badge de nivel y punto indicador verde
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                sectionBadge.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1D2848),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Título del curso
                        Text(
                          course['title'],
                          style: GoogleFonts.outfit(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Área académica
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            areaTag,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats: Alumnos y Dojo
                        Row(
                          children: [
                            // Alumnos
                            Row(
                              children: [
                                const Icon(LucideIcons.users, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("33", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                                    Text("ALUMNOS", style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Dojo
                            Row(
                              children: [
                                const Icon(LucideIcons.sparkles, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Dojo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                                    Text("EVOLUCIÓN", style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 8),
                        
                        // Footer: Gestionar Aula ->
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Gestionar Aula",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFE5A93B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.arrowRight,
                              color: Color(0xFFE5A93B),
                              size: 13,
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

  Widget _buildTeacherAttendanceTab(User teacherUser) {
    final attendanceLogs = _db.getAttendanceLogsForUser(teacherUser.id);
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
            "Control de Asistencia Docente",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
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
}
