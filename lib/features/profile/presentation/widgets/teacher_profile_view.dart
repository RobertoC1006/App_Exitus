import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';

class TeacherProfileView extends StatefulWidget {
  final User currentUser;
  final VoidCallback onLogout;

  const TeacherProfileView({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<TeacherProfileView> createState() => _TeacherProfileViewState();
}

class _TeacherProfileViewState extends State<TeacherProfileView> {
  String _activeFormTab = 'personal'; // 'personal' o 'security'

  late TextEditingController _firstNameController;
  late TextEditingController _lastNamePController;
  late TextEditingController _lastNameMController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

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
    _phoneController = TextEditingController(text: "918924237");

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePController.dispose();
    _lastNameMController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showQRModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDC620), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D2848).withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pase de Acceso Docente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2848),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Contenedor QR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEDC620).withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${widget.currentUser.id}',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 180,
                        height: 180,
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(LucideIcons.qrCode, size: 48, color: Color(0xFF94A3B8)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  widget.currentUser.fullName.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Código de Empleado: EX-09432",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5A93B),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.check, size: 12, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        "Acceso Autorizado",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveChanges() {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.updateProfile,
      body: _activeFormTab == 'personal'
          ? {
              "userId": widget.currentUser.id,
              "nombres": _firstNameController.text,
              "apellidoPaterno": _lastNamePController.text,
              "apellidoMaterno": _lastNameMController.text,
              "email": _emailController.text,
              "telefono": _phoneController.text,
            }
          : {
              "userId": widget.currentUser.id,
              "contrasenaActual": "••••••••",
              "nuevaContrasena": "••••••••",
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera superior
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "CONFIGURACIÓN DE IDENTIDAD",
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Mi Perfil",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D2848),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Gestiona tu información personal y preferencias de seguridad.",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta 1: Información de Usuario y Avatar
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0x0F1D2848)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar con botón de cámara superpuesto
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D2848).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(widget.currentUser.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Subir nueva foto de perfil")),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D2848),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    widget.currentUser.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D2848),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Badge del Rol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDC620).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Docente Tutor",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD3B121),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0x0F1D2848)),
                  const SizedBox(height: 16),

                  // Metadata del Perfil
                  Column(
                    children: [
                      _buildMetadataRow("Usuario", widget.currentUser.username),
                      const SizedBox(height: 12),
                      _buildMetadataRow("Código", "EX-09432"),
                      const SizedBox(height: 12),
                      _buildMetadataRow("Miembro Desde", "12 May, 2021"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón Pase Digital
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showQRModal,
                      icon: const Icon(LucideIcons.qrCode, size: 14),
                      label: const Text(
                        "VER PASE DIGITAL",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE5A93B),
                        side: const BorderSide(color: Color(0xFFE5A93B), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta 2: Formulario de Datos Personales / Seguridad (Tabs)
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0x0F1D2848)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tab Bar del Formulario
                  Row(
                    children: [
                      _buildFormTab("Datos Personales", 'personal', LucideIcons.user),
                      const SizedBox(width: 24),
                      _buildFormTab("Seguridad", 'security', LucideIcons.lock),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    color: const Color(0x0D1D2848),
                  ),
                  const SizedBox(height: 16),

                  // Formulario dinámico
                  if (_activeFormTab == 'personal') ...[
                    _buildTextField(label: "Nombres", controller: _firstNameController),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Apellido Paterno", controller: _lastNamePController),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Apellido Materno", controller: _lastNameMController),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Correo Electrónico", controller: _emailController, placeholder: "correo@ejemplo.com"),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Teléfono / WhatsApp", controller: _phoneController),
                  ] else ...[
                    _buildTextField(label: "Contraseña Actual", controller: _currentPasswordController, obscureText: true, placeholder: "••••••••"),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Nueva Contraseña", controller: _newPasswordController, obscureText: true, placeholder: "••••••••"),
                    const SizedBox(height: 14),
                    _buildTextField(label: "Confirmar Nueva Contraseña", controller: _confirmPasswordController, obscureText: true, placeholder: "••••••••"),
                  ],
                  const SizedBox(height: 20),

                  // Botón Guardar Cambios
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(LucideIcons.save, size: 14, color: Colors.white),
                    label: const Text(
                      "Guardar Cambios",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2848),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta 3: Carga Académica Asignada
          const Text(
            "Carga Académica Asignada",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
          ),
          const SizedBox(height: 12),

          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x0F1D2848)),
            ),
            child: Column(
              children: widget.currentUser.subjects.map((sub) {
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D2848).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.bookOpen, color: Color(0xFF1D2848), size: 16),
                      ),
                      title: Text(
                        sub,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                      ),
                      subtitle: const Text("Dictado Semanal: 4 horas", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      trailing: const Text(
                        "ACTIVO",
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ),
                    if (widget.currentUser.subjects.last != sub)
                      const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x0D1D2848)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Enlaces Rápidos: Ajustes / Cerrar Sesión
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x0F1D2848)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.settings, size: 16, color: Color(0xFF1D2848)),
                  ),
                  title: const Text(
                    "Ajustes de Docente",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF64748B)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ajustes generales del portal docente.")),
                    );
                  },
                ),
                const Divider(height: 1, indent: 48, color: Color(0x0D1D2848)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFD32F2F)),
                  ),
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFFD32F2F)),
                  onTap: widget.onLogout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2848),
          ),
        ),
      ],
    );
  }

  Widget _buildFormTab(String label, String tabKey, IconData icon) {
    final bool isActive = _activeFormTab == tabKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFormTab = tabKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF1D2848) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? const Color(0xFF1D2848) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF1D2848) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x1A1D2848)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1D2848), width: 1.5),
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D2848),
          ),
        ),
      ],
    );
  }
}
