import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../widgets/school_header_card.dart';
import '../widgets/login_tab_selector.dart';
import '../widgets/login_text_field.dart';

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
                  const Icon(LucideIcons.alertCircle, color: Colors.white),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Card con Logo y Nombre del Colegio
                const Center(
                  child: SchoolHeaderCard(),
                ),
                const SizedBox(height: 28),

                // Títulos
                Text(
                  "Acceso al Portal",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F2C59),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Ingresa tus credenciales para continuar",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de pestañas
                LoginTabSelector(
                  selectedTab: _selectedTab,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // Formulario
                if (_selectedTab == 0) ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoginTextField(
                          label: "Usuario",
                          hintText: "Tu usuario",
                          prefixIcon: LucideIcons.user,
                          controller: _usernameController,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        LoginTextField(
                          label: "Contraseña",
                          hintText: "••••••••",
                          prefixIcon: LucideIcons.lock,
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !isLoading,
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

                  // Botón de ingresar
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062446),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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
                            children: const [
                              Text(
                                "INGRESAR",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                            ],
                          ),
                  ),
                ] else ...[
                  // Vista alternativo en mantenimiento
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                            color: Color(0xFF0F2C59),
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

                const SizedBox(height: 28),

                // Link ¿Olvidaste tu contraseña?
                GestureDetector(
                  onTap: () {
                    _showInfoDialog(
                      context,
                      "¿Olvidaste tu contraseña?",
                      "Por seguridad institucional, si has olvidado tu contraseña debes comunicarte con el departamento de TI/Administración para realizar el restablecimiento.",
                    );
                  },
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F2C59),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
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
            const Icon(LucideIcons.info, color: Color(0xFF0F2C59)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2C59)),
            ),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(color: Color(0xFF0F2C59), fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
