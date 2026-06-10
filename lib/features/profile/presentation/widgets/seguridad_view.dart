import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';

class SeguridadView extends StatefulWidget {
  final User currentUser;

  const SeguridadView({
    super.key,
    required this.currentUser,
  });

  @override
  State<SeguridadView> createState() => _SeguridadViewState();
}

class _SeguridadViewState extends State<SeguridadView> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Criterios de validación
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      if (!_hasMinLength || !_hasUppercase || !_hasNumber || !_hasSpecialChar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La contraseña no cumple con todos los requisitos."),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Las contraseñas nuevas no coinciden."),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
        return;
      }

      ApiLogger.logCall(
        method: "POST",
        endpoint: ApiEndpoints.updateProfile,
        body: {
          "userId": widget.currentUser.id,
          "contrasenaActual": _currentPasswordController.text,
          "nuevaContrasena": _newPasswordController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "¡Contraseña actualizada con éxito!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Seguridad",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner mascota seguridad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/mascot_bitacoras.png',
                      width: 65,
                      height: 65,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.shieldCheck, size: 30, color: Color(0xFF2E7D32)),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mantén tu cuenta segura",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Cambia tu contraseña periódicamente.",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: const Color(0xFF2E7D32).withOpacity(0.8),
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
              const SizedBox(height: 24),

              // Campo: Contraseña actual
              _buildPasswordField(
                label: "Contraseña actual",
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrent = !_obscureCurrent;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Por favor ingresa tu contraseña actual";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Nueva contraseña
              _buildPasswordField(
                label: "Nueva contraseña",
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Por favor ingresa la nueva contraseña";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Confirmar nueva contraseña
              _buildPasswordField(
                label: "Confirmar nueva contraseña",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Por favor confirma la nueva contraseña";
                  }
                  if (val != _newPasswordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Reglas de contraseña
              Text(
                "Tu contraseña debe tener:",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
              const SizedBox(height: 12),
              _buildCriteriaRow("Mínimo 8 caracteres", _hasMinLength),
              const SizedBox(height: 8),
              _buildCriteriaRow("Una mayúscula", _hasUppercase),
              const SizedBox(height: 8),
              _buildCriteriaRow("Un número", _hasNumber),
              const SizedBox(height: 8),
              _buildCriteriaRow("Un carácter especial", _hasSpecialChar),
              const SizedBox(height: 32),

              // Botón Actualizar Contraseña
              ElevatedButton.icon(
                onPressed: _updatePassword,
                icon: const Icon(LucideIcons.lock, size: 16, color: Colors.white),
                label: const Text(
                  "Actualizar Contraseña",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2848),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(LucideIcons.lock, size: 16, color: Color(0xFF94A3B8)),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 16,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: onToggleVisibility,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D2848), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? LucideIcons.checkCircle2 : LucideIcons.circle,
          size: 16,
          color: isMet ? const Color(0xFF2E7D32) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            color: isMet ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
