import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../social_feed/presentation/widgets/social_feed_view.dart';
import '../../../messages/presentation/widgets/inbox_messages_view.dart';
import '../../../profile/presentation/widgets/student_profile_view.dart';
import '../../../profile/presentation/widgets/teacher_profile_view.dart';
import '../widgets/student_home_view.dart';
import '../widgets/teacher_home_view.dart';
import '../widgets/admin_home_view.dart';
import '../widgets/admin_profile_view.dart';
import '../widgets/admin_views.dart';
import '../widgets/fab_menu_overlay.dart';
import '../widgets/launchpad_overlay.dart';
import '../../../digitacion/presentation/screens/digitacion_dashboard_screen.dart';
import '../../../../features/classroom/presentation/widgets/inner_classroom_drawer.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  final MockDatabase _db = MockDatabase();
  int _currentIndex = 0;
  bool _isFABMenuOpen = false;
  bool _isLaunchpadOpen = false;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      items = ["Ficha Médica Consolidada", "Registrar Incidente", "Historial de Derivaciones", "Medicamentos Autorizados"];
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
    } else if (actionId == 'tesoreria') {
      title = "Pensiones y Pagos";
      icon = LucideIcons.landmark;
      color = const Color(0xFF10B981);
      items = ["Pagar Cuota Mensual", "Estado de Cuenta Completo", "Historial de Boletas", "Facturación Electrónica"];
    }

    if (items.isEmpty) return;

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
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((item) => Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: ListTile(
                  title: Text(item, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Accediendo a: $item (Simulación)")),
                    );
                  },
                ),
              )),
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
                      final currentAuthState = ref.read(authControllerProvider);
                      final String userFullName = currentAuthState is AuthAuthenticated ? currentAuthState.user.fullName : "Usuario Exitus";
                      final String userAvatar = currentAuthState is AuthAuthenticated ? currentAuthState.user.avatarUrl : "https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150";
                      final String userRole = currentAuthState is AuthAuthenticated ? currentAuthState.user.role : "student";

                      final newPost = SocialPost(
                        id: _db.getSocialPosts().length + 1,
                        publisher: userFullName,
                        avatar: userAvatar,
                        time: 'Hace un momento',
                        tag: userRole == 'admin' ? 'Administrador' : (userRole == 'teacher' ? 'Docente' : 'Estudiante'),
                        content: text,
                        userReactions: {'likes': false, 'loves': false, 'bravos': false, 'insights': false, 'haha': false, 'sad': false},
                        comments: [],
                      );
                      _db.getSocialPosts().insert(0, newPost);
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 1; // Redirigir a Muro
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Publicado en el muro con éxito.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("PUBLICAR AHORA", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScheduleSheet() {
    final currentAuthState = ref.read(authControllerProvider);
    if (currentAuthState is! AuthAuthenticated) return;
    final user = currentAuthState.user;

    final schedule = user.role == 'teacher'
        ? _db.teacherSchedule
        : (user.username.contains('sofia') ? _db.sofiaSchedule : _db.mateoSchedule);

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
                    Text(
                      user.role == 'teacher' ? "Pase Digital de Docente" : "Pase Digital de Ingreso",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                    ),
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

  void showUserSwitcherDialog(User currentUser) {
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
                
                _buildUserOptionItem(
                  context,
                  name: "Franco Alexis B.",
                  role: "Administrador (Práctante)",
                  avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150",
                  isSelected: currentUser.role == 'admin',
                  onTap: () => _switchUser('admin123'),
                ),
                
                _buildUserOptionItem(
                  context,
                  name: "Nicole Sulay A.",
                  role: "Profesor",
                  avatar: "https://images.unsplash.com/photo-1544717305-2782549b5136?w=150",
                  isSelected: currentUser.role == 'teacher',
                  onTap: () => _switchUser('profesor123'),
                ),
                
                _buildUserOptionItem(
                  context,
                  name: "Mateo Guerrero",
                  role: "Estudiante (5° Sec.)",
                  avatar: "https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150",
                  isSelected: currentUser.role == 'student' && currentUser.username == 'mateo123',
                  onTap: () => _switchUser('mateo123'),
                ),
                
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
        setState(() {
          _currentIndex = 0; // Reiniciar a la pestaña de inicio del nuevo rol
        });
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

  void _showCreateUserSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final subjectsController = TextEditingController();
    String selectedRole = 'teacher';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
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
                        const Text(
                          "Registrar Nuevo Usuario",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002244),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Rol del Usuario",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'teacher', child: Text("Docente / Profesor")),
                                DropdownMenuItem(value: 'admin', child: Text("Administrador")),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    selectedRole = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nombre Completo",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Ej. Prof. Juan Pérez",
                            prefixIcon: const Icon(LucideIcons.user),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Ingresa el nombre completo";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Correo Electrónico",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "ejemplo@exitus.edu.pe",
                            prefixIcon: const Icon(LucideIcons.mail),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Ingresa el correo electrónico";
                            if (!value.contains('@')) return "Ingresa un correo válido";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nombre de Usuario",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: "Ej. juan123",
                            prefixIcon: const Icon(LucideIcons.userCheck),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Ingresa el usuario";
                            if (value.contains(' ')) return "No debe contener espacios";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Contraseña Temporal",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            prefixIcon: const Icon(LucideIcons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Ingresa la contraseña";
                            if (value.length < 6) return "Mínimo 6 caracteres";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (selectedRole == 'teacher') ...[
                          const Text(
                            "Cursos Asignados (Separados por comas)",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF002244)),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: subjectsController,
                            decoration: InputDecoration(
                              hintText: "Ej. Matemática - 5to A, Física - 4to A",
                              prefixIcon: const Icon(LucideIcons.bookOpen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final List<String> subjects = subjectsController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              final newUser = User(
                                id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                username: usernameController.text.trim(),
                                fullName: nameController.text.trim(),
                                email: emailController.text.trim(),
                                role: selectedRole,
                                avatarUrl: selectedRole == 'admin'
                                    ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'
                                    : 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                                subjects: subjects,
                              );

                              _db.registerUser(newUser, passwordController.text);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(LucideIcons.checkCircle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Usuario ${newUser.fullName} registrado correctamente como ${selectedRole == 'admin' ? 'Administrador' : 'Docente'}."
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2E7D32),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );

                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002244),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "REGISTRAR USUARIO",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAdminAulasBottomSheet(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "GESTIÓN DE AULAS",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002244)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(child: AdminAulasView()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdminAttendanceBottomSheet(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "REPORTE DE ASISTENCIA DIARIO",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002244)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(child: AdminAttendanceView()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    final currentAuthState = ref.watch(authControllerProvider);
    final String userRole = currentAuthState is AuthAuthenticated ? currentAuthState.user.role : "student";
    final isSelected = _currentIndex == index;
    final activeColor = userRole == 'student' ? const Color(0xFFF9C824) : const Color(0xFF1D2848);
    final color = isSelected ? activeColor : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$badgeCount",
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
        content: const Text("¿Estás seguro de que deseas salir del portal de Exitus?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Messages tab
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

  Widget buildTeacherHeader(User teacher, String title, int unreadCount) {
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
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Messages tab
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

  Widget buildAdminHeader(User admin) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF002244),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "E",
                  style: TextStyle(
                    color: Color(0xFFE5A93B),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Colegio Exitus",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002244),
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    "INTRANET",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [

              GestureDetector(
                onTap: () => _showAdminNotificationsDialog(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(LucideIcons.bell, size: 16, color: Color(0xFF002244)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAdminNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(LucideIcons.bell, color: Color(0xFF002244)),
            SizedBox(width: 8),
            Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(LucideIcons.alertTriangle, color: Colors.orange),
              title: Text("Alerta de inasistencias"),
              subtitle: Text("Sección 5to B reporta 25% de inasistencia hoy."),
            ),
            ListTile(
              leading: Icon(LucideIcons.info, color: Colors.blue),
              title: Text("Calificaciones listas"),
              subtitle: Text("El Prof. Roberto Carlos terminó de calificar Física."),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Color(0xFF002244), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthState = ref.watch(authControllerProvider);
    if (currentAuthState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = currentAuthState.user;

    final List<Map<String, dynamic>> studentCourses = user.username.contains('sofia')
        ? [
            {'id': 'c1', 'title': 'Matemáticas', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'teacher': 'Prof. Carlos Oliva', 'tag': 'CIENCIA Y TECNOLOGÍA'},
            {'id': 'c2', 'title': 'Ciencias', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Miss Ana María', 'tag': 'CIENCIA Y TECNOLOGÍA'},
            {'id': 'c3', 'title': 'Literatura', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Aula B', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Miss Ana María', 'tag': 'COMUNICACIÓN'},
            {'id': 'c4', 'title': 'Inglés', 'level': 'PRIMARIA', 'levelNum': '2°', 'room': 'Lab. Primaria', 'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'teacher': 'Miss Sara Conner', 'tag': 'INGLÉS'},
          ]
        : [
            {'id': 'c1', 'title': 'Tutoría', 'level': 'SECUNDARIA', 'levelNum': '4° B', 'room': 'Secundaria', 'avatar': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', 'teacher': 'Nicole Sulay A.', 'tag': 'PLATAFORMA EDUCATIVA EXITUS'},
            {'id': 'c2', 'title': 'Tech Savvy', 'level': 'SECUNDARIA', 'levelNum': '2° A', 'room': 'Aula 201', 'avatar': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', 'teacher': 'Nicole Sulay A.', 'tag': 'EDUCACIÓN PARA EL TRABAJO'},
            {'id': 'c3', 'title': 'Biología', 'level': 'SECUNDARIA', 'levelNum': '5° A', 'room': 'Lab. Química', 'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'teacher': 'Prof. Luis Gonzaga', 'tag': 'CIENCIA Y TECNOLOGÍA'},
            {'id': 'c4', 'title': 'Literatura', 'level': 'SECUNDARIA', 'levelNum': '5° A', 'room': 'Aula A', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'teacher': 'Dra. Julia Mendoza', 'tag': 'COMUNICACIÓN'},
          ];

    final List<Map<String, dynamic>> teacherCourses = user.subjects.map((sub) {
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
        'teacher': user.fullName,
      };
    }).toList();

    Widget homeView;
    if (user.role == 'admin') {
      homeView = AdminHomeView(
        onTabChanged: (index) {
          if (index == 1) {
            _showAdminAulasBottomSheet(context);
          } else if (index == 2) {
            _showAdminAttendanceBottomSheet(context);
          }
        },
        onRegisterUserPressed: _showCreateUserSheet,
      );
    } else if (user.role == 'teacher') {
      homeView = TeacherHomeView(
        teacherUser: user,
        teacherCourses: teacherCourses,
        onTabChanged: _onTabChanged,
      );
    } else {
      homeView = StudentHomeView(
        studentUser: user,
        studentCourses: studentCourses,
        onTabChanged: _onTabChanged,
      );
    }

    Widget profileView;
    if (user.role == 'admin') {
      profileView = AdminProfileView(
        onRefreshRequested: () => setState(() {}),
      );
    } else if (user.role == 'teacher') {
      profileView = TeacherProfileView(
        currentUser: user,
        onLogout: _handleLogout,
      );
    } else {
      profileView = StudentProfileView(
        currentUser: user,
        onLogout: _handleLogout,
      );
    }

    final List<Widget> views = [
      homeView,
      SocialFeedView(currentUser: user),
      InboxMessagesView(currentUser: user, onMessageRead: () => setState(() {})),
      profileView,
    ];



    final unreadMessages = _db.getMessagesForUser(user.id).where((m) => m.unread).length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: views,
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isFABMenuOpen = true;
              });
            },
            backgroundColor: user.role == 'student' ? const Color(0xFFF9C824) : const Color(0xFF1D2848),
            elevation: 8,
            shape: const CircleBorder(),
            child: Icon(
              LucideIcons.plus,
              color: Colors.white,
              size: user.role == 'student' ? 28 : 24,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            elevation: 16,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(0, LucideIcons.home, "Inicio"),
                  _buildBottomNavItem(1, LucideIcons.megaphone, "Muro"),
                  const SizedBox(width: 48), // gap for FAB
                  _buildBottomNavItem(2, LucideIcons.messageSquare, "Mensajes", badgeCount: unreadMessages),
                  _buildBottomNavItem(3, LucideIcons.user, "Perfil"),
                ],
              ),
            ),
          ),
        ),

        if (_isFABMenuOpen)
          Positioned.fill(
            child: FABMenuOverlay(
              user: {'role': user.role},
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
              user: {'role': user.role},
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
                  if (user.role == 'student') {
                    _showStudentClassroomBottomSheet(user, studentCourses);
                  } else if (user.role == 'teacher') {
                    if (teacherCourses.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.85,
                            child: InnerClassroomDrawer(
                              course: teacherCourses[0],
                              isTeacher: true,
                              currentUser: user,
                            ),
                          );
                        },
                      );
                    }
                  }
                } else if (route == 'messages') {
                  setState(() {
                    _currentIndex = 2; // Mensajes
                  });
                } else if (route == 'digitacion') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DigitacionDashboardScreen()),
                  );
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

  void _showStudentClassroomBottomSheet(User studentUser, List<Map<String, dynamic>> studentCourses) {
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "AULAS VIRTUALES",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: studentCourses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = studentCourses[index];
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        child: ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(course['avatar'])),
                          title: Text(course['title'], style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                          subtitle: Text("Prof: ${course['teacher']} • ${course['room']}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                          onTap: () {
                            Navigator.pop(context);
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
                          },
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
  }
}
