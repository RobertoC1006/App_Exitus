import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';



class CambiarRolView extends ConsumerStatefulWidget {
  final User currentUser;

  const CambiarRolView({
    super.key,
    required this.currentUser,
  });

  @override
  ConsumerState<CambiarRolView> createState() => _CambiarRolViewState();
}

class _CambiarRolViewState extends ConsumerState<CambiarRolView> {
  int _currentStep = 1; // 1: Selección, 3: Éxito (el paso 2 es el diálogo modal)
  String _selectedRole = '';

  final List<Map<String, dynamic>> _rolesList = [
    {'id': 'student', 'label': 'Estudiante', 'icon': LucideIcons.graduationCap},
    {'id': 'teacher', 'label': 'Profesor', 'icon': LucideIcons.userCheck},
    {'id': 'biblioteca', 'label': 'Biblioteca', 'icon': LucideIcons.bookOpen},
    {'id': 'topico', 'label': 'Enfermería / Tópico', 'icon': LucideIcons.activity},
    {'id': 'tesoreria', 'label': 'Tesorería', 'icon': LucideIcons.landmark},
    {'id': 'admin', 'label': 'Administración', 'icon': LucideIcons.building},
    {'id': 'eventos', 'label': 'Eventos', 'icon': LucideIcons.calendar},
    {'id': 'convivencia', 'label': 'Convivencia', 'icon': LucideIcons.shieldAlert},
  ];

  String _getRoleDisplayName(String role) {
    final match = _rolesList.firstWhere((r) => r['id'] == role, orElse: () => {});
    return match.isNotEmpty ? match['label'] : role;
  }

  @override
  void initState() {
    super.initState();
    // Inicializar con el rol activo actual
    Future.microtask(() {
      setState(() {
        _selectedRole = ref.read(activeRoleProvider);
      });
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final roleName = _getRoleDisplayName(_selectedRole);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono mascota superior
                Image.asset(
                  'assets/images/mascot_bitacoras.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(LucideIcons.userPlus, size: 48, color: Color(0xFFEDC620));
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  "¿Cambiar a este rol?",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Círculo de check verde
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.check, size: 32, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 16),

                // Card de información del rol destino
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        roleName,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Accederás a las herramientas y vista correspondientes a este rol.",
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          setState(() {
                            _currentStep = 3; // Mostrar pantalla de éxito
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEDC620),
                          foregroundColor: const Color(0xFF1D2848),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Cambiar Rol",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyRoleChangeAndGoHome() {
    // 1. Cambiar el rol activo en Riverpod
    ref.read(activeRoleProvider.notifier).setRole(_selectedRole);

    // 2. Limpiar la pila de navegación del nested navigator del tab de perfil para volver a ExitusProfileView
    Navigator.popUntil(context, (route) => route.isFirst);

    // 3. Redirigir a la pestaña de Inicio (Tab 0) en la navegación principal
    ref.read(navigationIndexProvider.notifier).changeIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 3) {
      return _buildSuccessStep();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cambiar de Rol",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner mascota "¿Quién eres hoy?"
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFF59D)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/mascot_bitacoras.png',
                          width: 65,
                          height: 65,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(LucideIcons.helpCircle, size: 48, color: Colors.amber);
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¿Quién eres hoy?",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB78A00),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Elige el rol con el que quieres trabajar ahora.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFFB78A00).withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lista de selección de roles
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: List.generate(_rolesList.length, (index) {
                        final role = _rolesList[index];
                        final isSelected = _selectedRole == role['id'];

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedRole = role['id'];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFEDC620).withOpacity(0.15)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        role['icon'],
                                        size: 18,
                                        color: isSelected
                                            ? const Color(0xFFE5A93B)
                                            : const Color(0xFF1D2848),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        role['label'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight:
                                              isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: const Color(0xFF1D2848),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFE5A93B)
                                              : const Color(0xFFCBD5E1),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE5A93B),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < _rolesList.length - 1)
                              const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón inferior de Aplicar Rol
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRole.isNotEmpty ? _showConfirmationDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDC620),
                  foregroundColor: const Color(0xFF1D2848),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                ),
                child: const Text(
                  "Aplicar Rol Seleccionado",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    final roleName = _getRoleDisplayName(_selectedRole);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Imagen animada confeti / mascota alegre
              Center(
                child: Image.asset(
                  'assets/images/mascot_horario.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(LucideIcons.sparkles, size: 80, color: Color(0xFFEDC620));
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "¡Rol cambiado!",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Ahora estás trabajando como",
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Badge verde con el rol
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleName,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Botón Ir al inicio
              ElevatedButton(
                onPressed: _applyRoleChangeAndGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2848),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  "Ir al inicio",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
