import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';

class DatosPersonalesView extends StatefulWidget {
  final User currentUser;

  const DatosPersonalesView({
    super.key,
    required this.currentUser,
  });

  @override
  State<DatosPersonalesView> createState() => _DatosPersonalesViewState();
}

class _DatosPersonalesViewState extends State<DatosPersonalesView> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNamePController;
  late TextEditingController _lastNameMController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final nameParts = widget.currentUser.fullName.split(' ');
    String firstName = "";
    String lastNameP = "";
    String lastNameM = "";

    if (nameParts.isNotEmpty) {
      if (nameParts.length == 1) {
        firstName = nameParts[0];
      } else if (nameParts.length == 2) {
        firstName = nameParts[0];
        lastNameP = nameParts[1];
      } else {
        firstName = nameParts.sublist(0, nameParts.length - 2).join(' ');
        lastNameP = nameParts[nameParts.length - 2];
        lastNameM = nameParts[nameParts.length - 1];
      }
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNamePController = TextEditingController(text: lastNameP);
    _lastNameMController = TextEditingController(text: lastNameM);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _phoneController = TextEditingController(
        text: widget.currentUser.username.contains('mateo') ? "987 654 321" : "918 924 237");
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePController.dispose();
    _lastNameMController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.updateProfile,
      body: {
        "userId": widget.currentUser.id,
        "nombres": _firstNameController.text,
        "apellidoPaterno": _lastNamePController.text,
        "apellidoMaterno": _lastNameMController.text,
        "email": _emailController.text,
        "telefono": _phoneController.text,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "¡Cambios guardados con éxito!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          "Datos Personales",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alerta de datos no modificables
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: Color(0xFF0288D1), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Algunos datos no pueden ser modificados por seguridad.",
                      style: TextStyle(
                        color: const Color(0xFF0288D1),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Datos bloqueados
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  "Datos bloqueados",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              label: "Nombres",
              controller: _firstNameController,
              isEditable: false,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: "Apellido Paterno",
              controller: _lastNamePController,
              isEditable: false,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: "Apellido Materno",
              controller: _lastNameMController,
              isEditable: false,
            ),
            const SizedBox(height: 24),

            // Sección: Datos editables
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  "Datos editables",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              label: "Correo electrónico",
              controller: _emailController,
              isEditable: true,
              suffixIcon: LucideIcons.mail,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: "Teléfono / WhatsApp",
              controller: _phoneController,
              isEditable: true,
              suffixIcon: LucideIcons.phone,
            ),
            const SizedBox(height: 32),

            // Botón Guardar Cambios
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text(
                "Guardar Cambios",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    IconData? suffixIcon,
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
          enabled: isEditable,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isEditable ? const Color(0xFF1D2848) : const Color(0xFF64748B),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isEditable ? Colors.white : const Color(0xFFF1F5F9),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D2848), width: 1.5),
            ),
            suffixIcon: isEditable
                ? (suffixIcon != null
                    ? Icon(suffixIcon, size: 18, color: const Color(0xFF94A3B8))
                    : null)
                : const Icon(LucideIcons.lock, size: 16, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }
}
