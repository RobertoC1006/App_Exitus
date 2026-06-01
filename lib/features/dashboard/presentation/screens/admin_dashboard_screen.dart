import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;
  final MockDatabase _db = MockDatabase();

  // Cambiar pestaña activa
  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Abrir Bottom Sheet para Registrar Nuevo Usuario (FAB central '+')
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
                        // Tirador visual
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

                        // Dropdown Rol
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

                        // Nombre Completo
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

                        // Correo Electrónico
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

                        // Usuario
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

                        // Contraseña Temporal
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

                        // Cursos Asignados (solo profesores)
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

                              // Guardar en la base de datos
                              _db.registerUser(newUser, passwordController.text);

                              // Cerrar BottomSheet
                              Navigator.pop(context);

                              // Mostrar mensaje de éxito
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

                              // Forzar actualización de pantalla si estamos en la vista de Portal (donde se listan usuarios)
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final adminUser = authState.user;

    // Vistas asociadas a cada pestaña
    final List<Widget> views = [
      AdminHomeView(onTabChanged: _onTabChanged, onRegisterUserPressed: _showCreateUserSheet),
      const AdminAulasView(),
      const AdminAttendanceView(),
      AdminPortalView(onRefreshRequested: () => setState(() {})),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // 1. Cabecera Custom siguiendo la estructura exacta de la imagen
      body: SafeArea(
        child: Column(
          children: [
            AdminHeader(adminUser: adminUser),
            // Separador sutil
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            // Contenido Principal
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: views,
              ),
            ),
          ],
        ),
      ),

      // 2. Botón Flotante Central FAB Docked
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserSheet,
        backgroundColor: const Color(0xFF002244),
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 3. Barra de navegación inferior Custom
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
              _buildBottomNavItem(1, LucideIcons.bookOpen, "AULAS"),
              const SizedBox(width: 48), // Espacio para el botón flotante central
              _buildBottomNavItem(2, LucideIcons.calendarCheck, "ASISTENCIA"),
              _buildBottomNavItem(3, LucideIcons.user, "PORTAL ADMIN", showBadge: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, {bool showBadge = false}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF002244) : const Color(0xFF94A3B8);

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
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC0392B), // Punto rojo
                        shape: BoxShape.circle,
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
}

// ==========================================
// WIDGET: CABECERA PERSONALIZADA DE REFERENCIA (AdminHeader)
// ==========================================
class AdminHeader extends ConsumerWidget {
  final User adminUser;
  const AdminHeader({super.key, required this.adminUser});

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.bell, color: Color(0xFF002244)),
            const SizedBox(width: 8),
            const Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _handleLogout(BuildContext context, WidgetRef ref) {
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
        content: const Text("¿Estás seguro de que deseas salir del portal de administración?"),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Izquierdo: Logotipo "E" Exitus + Texto INTRANET (Estructura de la Imagen)
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF002244), // Azul Marino oscuro Exitus
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "E",
                  style: TextStyle(
                    color: Color(0xFFE5A93B), // Dorado Exitus
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

          // Lado Derecho: Avatar con dropdown + Campana de notificaciones (Estructura de la Imagen)
          Row(
            children: [
              // Avatar con flecha abajo en borde tipo píldora
              GestureDetector(
                onTap: () => _handleLogout(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(adminUser.avatarUrl),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Notificaciones con campana y badge rojo 2
              GestureDetector(
                onTap: () => _showNotificationsDialog(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        LucideIcons.bell,
                        size: 19,
                        color: Color(0xFF002244),
                      ),
                    ),
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC0392B), // Rojo de alerta
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "2",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}

// ==========================================
// VISTA: INICIO (AdminHomeView)
// ==========================================
class AdminHomeView extends StatelessWidget {
  final Function(int) onTabChanged;
  final VoidCallback onRegisterUserPressed;

  const AdminHomeView({
    super.key,
    required this.onTabChanged,
    required this.onRegisterUserPressed,
  });

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final totalTeachers = db.users.where((u) => u.role == 'teacher').length;
    final totalAdmins = db.users.where((u) => u.role == 'admin').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de Bienvenida
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002244), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002244).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel de Control Exitus",
                  style: TextStyle(color: Color(0xFFE5A93B), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Bienvenido, Administrador",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Sistema Intranet de Gestión Académica",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título de Métricas
          const Text(
            "Resumen Institucional",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 12),

          // Grid de Métricas
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                "Profesores",
                "$totalTeachers Activos",
                LucideIcons.users,
                Colors.blue,
              ),
              _buildStatCard(
                "Administradores",
                "$totalAdmins",
                LucideIcons.shieldAlert,
                Colors.purple,
              ),
              _buildStatCard(
                "Asistencia Hoy",
                "96.4%",
                LucideIcons.calendarCheck,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                "Aulas Activas",
                "3 secciones",
                LucideIcons.bookOpen,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Accesos Rápidos
          const Text(
            "Acciones Rápidas",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 12),

          // Lista de botones de accesos rápidos
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: LucideIcons.userPlus,
                  title: "Crear Nuevo Usuario",
                  subtitle: "Docentes o Administradores del sistema",
                  color: const Color(0xFF002244),
                  onTap: onRegisterUserPressed,
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildActionTile(
                  icon: LucideIcons.bookOpen,
                  title: "Gestionar Aulas",
                  subtitle: "Visualizar secciones y tutores",
                  color: const Color(0xFF3B82F6),
                  onTap: () => onTabChanged(1),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildActionTile(
                  icon: LucideIcons.fileSpreadsheet,
                  title: "Reporte de Asistencia",
                  subtitle: "Ver inasistencias y asistencia diaria",
                  color: const Color(0xFF10B981),
                  onTap: () => onTabChanged(2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002244))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}

// ==========================================
// VISTA: AULAS (AdminAulasView)
// ==========================================
class AdminAulasView extends StatelessWidget {
  const AdminAulasView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos algunas secciones de ejemplo
    final List<Map<String, dynamic>> classrooms = [
      {
        "name": "5to de Secundaria A",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 6,
        "subjects": ["Matemática", "Taller de Cálculo"],
        "classroomCode": "Aula 301",
      },
      {
        "name": "5to de Secundaria B",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 4,
        "subjects": ["Matemática"],
        "classroomCode": "Aula 302",
      },
      {
        "name": "4to de Secundaria A",
        "tutor": "Prof. Roberto Carlos",
        "studentsCount": 8,
        "subjects": ["Física"],
        "classroomCode": "Lab. Física",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classrooms.length,
      itemBuilder: (context, index) {
        final classroom = classrooms[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classroom["name"],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        classroom["classroomCode"],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "Tutor: ${classroom["tutor"]}",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.users, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "Alumnos matriculados: ${classroom["studentsCount"]}",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: (classroom["subjects"] as List<String>).map((subject) {
                    return Chip(
                      label: Text(subject, style: const TextStyle(fontSize: 11, color: Color(0xFF002244), fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// VISTA: ASISTENCIA GENERAL (AdminAttendanceView)
// ==========================================
class AdminAttendanceView extends StatelessWidget {
  const AdminAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();

    // Sumar estadísticas rápidas
    final all5toA = db.students5toA;
    final all5toB = db.students5toB;

    int present5toA = all5toA.where((s) => s.attendanceStatus == 'Presente').length;
    int absent5toA = all5toA.where((s) => s.attendanceStatus == 'Falta').length;
    int tardy5toA = all5toA.where((s) => s.attendanceStatus == 'Tardanza').length;

    int present5toB = all5toB.where((s) => s.attendanceStatus == 'Presente').length;
    int absent5toB = all5toB.where((s) => s.attendanceStatus == 'Falta').length;
    int tardy5toB = all5toB.where((s) => s.attendanceStatus == 'Tardanza').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          const Text(
            "Reporte Diario de Asistencia",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const Text(
            "Resumen consolidad de hoy para todas las secciones",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Secciones de Asistencia
          _buildAttendanceProgressCard(
            title: "5to de Secundaria - Sección A",
            present: present5toA,
            absent: absent5toA,
            tardy: tardy5toA,
            total: all5toA.length,
          ),
          const SizedBox(height: 12),
          _buildAttendanceProgressCard(
            title: "5to de Secundaria - Sección B",
            present: present5toB,
            absent: absent5toB,
            tardy: tardy5toB,
            total: all5toB.length,
          ),
          const SizedBox(height: 20),

          // Alumnos con faltas registradas hoy
          const Text(
            "Inasistencias del Día",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC0392B)),
          ),
          const SizedBox(height: 10),
          _buildAbsentList(db),
        ],
      ),
    );
  }

  Widget _buildAttendanceProgressCard({
    required String title,
    required int present,
    required int absent,
    required int tardy,
    required int total,
  }) {
    final double percent = total > 0 ? (present + tardy) / total : 0;
    final percentStr = (percent * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002244))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: percent > 0.85 ? const Color(0xFF10B981) : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$percentStr%",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIndicatorBadge("Presentes", present, const Color(0xFF10B981)),
                _buildIndicatorBadge("Tardanzas", tardy, Colors.amber),
                _buildIndicatorBadge("Faltas", absent, const Color(0xFFC0392B)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorBadge(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Text(
          "$value",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
      ],
    );
  }

  Widget _buildAbsentList(MockDatabase db) {
    final List<Student> absentStudents = [];
    absentStudents.addAll(db.students5toA.where((s) => s.attendanceStatus == 'Falta'));
    absentStudents.addAll(db.students5toB.where((s) => s.attendanceStatus == 'Falta'));

    if (absentStudents.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "¡Hoy no se registran faltas!",
              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: absentStudents.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final student = absentStudents[index];
          final String aula = db.students5toA.contains(student) ? "5to A" : "5to B";
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student.avatarUrl),
            ),
            title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002244))),
            subtitle: Text("Sección: $aula", style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "FALTA",
                style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// VISTA: PORTAL ADMIN (AdminPortalView)
// ==========================================
class AdminPortalView extends ConsumerWidget {
  final VoidCallback onRefreshRequested;
  const AdminPortalView({super.key, required this.onRefreshRequested});

  void _resetDatabase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.orange),
            SizedBox(width: 8),
            Text("Restablecer Sistema", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Esto reiniciará los datos de asistencia, calificaciones y usuarios creados durante esta sesión. ¿Deseas continuar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Restablecer base de datos volviendo a inicializar los datos base
              final db = MockDatabase();
              db.users.clear();
              db.users.addAll([
                const User(
                  id: 'teacher_01',
                  username: 'profesor123',
                  fullName: 'Prof. Roberto Carlos',
                  email: 'roberto.carlos@exitus.edu.pe',
                  role: 'teacher',
                  avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
                  subjects: ['Matemática - 5to A', 'Matemática - 5to B', 'Física - 4to A'],
                ),
                const User(
                  id: 'admin_01',
                  username: 'admin123',
                  fullName: 'Ing. Carlos Mendoza',
                  email: 'carlos.mendoza@exitus.edu.pe',
                  role: 'admin',
                  avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
                  subjects: [],
                ),
              ]);
              db.userPasswords.clear();
              db.userPasswords['profesor123'] = '12345678';
              db.userPasswords['admin123'] = '12345678';

              // Reiniciar estados de asistencia a Presente
              for (var s in db.students5toA) {
                s.attendanceStatus = 'Presente';
              }
              for (var s in db.students5toB) {
                s.attendanceStatus = 'Presente';
              }

              // Reiniciar calificaciones
              db.submissions.clear();
              db.submissions.addAll([
                HomeworkSubmission(
                  id: 'sub_01',
                  studentName: 'Alvarez Quispe, Jose',
                  studentAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Profesor, aquí le adjunto el desarrollo...',
                  date: '26 May, 09:15 PM',
                ),
                HomeworkSubmission(
                  id: 'sub_02',
                  studentName: 'Bustamante Diaz, María',
                  studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Adjunto foto del cuaderno con la resolución completa del tema de límites.',
                  date: '26 May, 11:30 PM',
                ),
                HomeworkSubmission(
                  id: 'sub_03',
                  studentName: 'Chavez Rojas, Carlos',
                  studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                  title: 'Práctica de Derivadas',
                  description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
                  submittedText: 'Desarrollo del cuestionario sobre derivadas e interpretación geométrica.',
                  date: '27 May, 07:10 AM',
                ),
              ]);

              onRefreshRequested();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Base de datos de demostración restablecida correctamente."),
                  backgroundColor: const Color(0xFF002244),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            child: const Text("Restablecer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = MockDatabase();
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Perfil del Administrador
          if (user != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002244))),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "ADMINISTRADOR",
                              style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Lista de Usuarios del Sistema
          const Text(
            "Cuentas del Sistema",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = db.users[index];
                final isAdmin = u.role == 'admin';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(u.avatarUrl),
                  ),
                  title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002244))),
                  subtitle: Text("@${u.username} • ${u.email}", style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAdmin ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAdmin ? "ADMIN" : "DOCENTE",
                      style: TextStyle(
                        color: isAdmin ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Opciones de Configuración
          const Text(
            "Opciones del Desarrollador",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.refreshCw, color: Colors.orange),
                  title: const Text("Restablecer Base de Datos de Prueba", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text("Elimina usuarios e historial creado en esta sesión.", style: TextStyle(fontSize: 11)),
                  onTap: () => _resetDatabase(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.logOut, color: Color(0xFFC0392B)),
                  title: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFC0392B))),
                  subtitle: const Text("Salir de la sesión del administrador de manera segura.", style: TextStyle(fontSize: 11)),
                  onTap: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
