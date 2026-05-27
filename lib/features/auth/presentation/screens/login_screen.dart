import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../widgets/school_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedTab = 0; // 0: Tradicional, 1: WhatsApp, 2: Código

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authControllerProvider.notifier).login(
            _usernameController.text,
            _passwordController.text,
          );
      if (!mounted) return;
      if (!success) {
        final state = ref.read(authControllerProvider);
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: const Color(0xFFC0392B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Imagen de Fondo de Pantalla Completa
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/school_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Capa de difuminado y tinte para lograr efecto glassmorphism
          Container(
            color: Colors.white.withOpacity(0.4),
          ),
          // 3. Contenido Principal Scrollable
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Logo y Título Institucional
                    const SchoolLogo(size: 70),
                    const SizedBox(height: 40),


                              Text(
                                "Acceso al Colegio Exitus",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002244),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Custom Tab Selector (Replicando la UI del usuario)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildTabItem(0, "Tradicional"),
                                    _buildTabItem(1, "WhatsApp"),
                                    _buildTabItem(2, "Código", icon: LucideIcons.qrCode),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Formulario condicional según Tab seleccionado
                              if (_selectedTab == 0) ...[
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Usuario",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF002244),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _usernameController,
                                        enabled: !isLoading,
                                        decoration: InputDecoration(
                                          hintText: "Tu usuario",
                                          prefixIcon: const Icon(LucideIcons.user, size: 20),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.35),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFF002244), width: 1.5),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Ingresa tu usuario';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      const Text(
                                        "Contraseña",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF002244),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        enabled: !isLoading,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: "••••••••",
                                          prefixIcon: const Icon(LucideIcons.lock, size: 20),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.35),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFF002244), width: 1.5),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingresa tu contraseña';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                ElevatedButton(
                                  onPressed: isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF002244),
                                    disabledBackgroundColor: const Color(0xFF002244).withOpacity(0.6),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "INGRESAR",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
                                          ],
                                        ),
                                ),
                              ] else ...[
                                // Vista amigable para métodos de Login alternativos en construcción
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle, size: 40, color: Color(0xFFE5A93B)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Acceso en Mantenimiento",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF002244),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Este método de acceso está temporalmente en mantenimiento. Por favor, usa el método Tradicional.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  _showInfoDialog(
                                    context,
                                    "¿Olvidaste tu contraseña?",
                                    "Por seguridad institucional, si has olvidado tu contraseña de docente debes comunicarte con el departamento de TI/Administración para realizar el restablecimiento.",
                                  );
                                },
                                child: const Text(
                                  "¿Olvidaste tu contraseña?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF002244),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showInfoDialog(
                                        context,
                                        "Crear cuenta",
                                        "Las cuentas de los docentes son creadas y gestionadas exclusivamente por el Administrador de la institución.",
                                      );
                                    },
                                    child: const Text(
                                      "Crear cuenta",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Text(" or ", style: TextStyle(color: Color(0xFF64748B))),
                                  GestureDetector(
                                    onTap: () {
                                      _showInfoDialog(
                                        context,
                                        "Soporte Exitus",
                                        "Para soporte técnico, escríbenos a soporte@exitus.edu.pe o comunícate al anexo de TI: 405.",
                                      );
                                    },
                                    child: const Text(
                                      "Soporte",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),


                    const SizedBox(height: 30),
                    const Text(
                      "© 2026 I.E.P. Colegio Exitus - Piura",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF002244),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, {IconData? icon}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? const Color(0xFF002244) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF002244) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.info, color: Color(0xFF002244)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002244))),
          ],
        ),
        content: Text(message),
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
}
