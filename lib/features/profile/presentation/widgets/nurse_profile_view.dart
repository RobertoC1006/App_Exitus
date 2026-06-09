import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class NurseProfileView extends StatefulWidget {
  final User currentUser;
  final VoidCallback onLogout;
  final Function(String newRole) onRoleChanged;

  const NurseProfileView({
    super.key,
    required this.currentUser,
    required this.onLogout,
    required this.onRoleChanged,
  });

  @override
  State<NurseProfileView> createState() => _NurseProfileViewState();
}

class _NurseProfileViewState extends State<NurseProfileView> {
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
    _phoneController = TextEditingController(text: "987654321");

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

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "¡Cambios guardados con éxito!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pase de Acceso Tópico",
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
                  "Código de Empleado: EX-00892",
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

  @override
  Widget build(BuildContext context) {
    final activeRole = widget.currentUser.role;
    final isNurse = activeRole == 'enfermero';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D2848),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "CONFIGURACIÓN DE IDENTIDAD",
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D2848),
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
                "Administra tu información personal y conmuta tus roles asignados.",
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

          // Tarjeta del Workspace Selector (Switcher de Rol)
          _buildWorkspaceSwitcher(activeRole),
          const SizedBox(height: 16),

          // Tarjeta del Perfil
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
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D2848).withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
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
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2848),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    widget.currentUser.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D2848),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Active role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isNurse ? const Color(0xFF2E7D32) : const Color(0xFF8B5CF6)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isNurse ? "Lic. en Enfermería" : "Bibliotecario Escolar",
                      style: GoogleFonts.outfit(
                        color: isNurse ? const Color(0xFF2E7D32) : const Color(0xFF8B5CF6),
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
                      _buildMetadataRow("Código", "EX-00892"),
                      const SizedBox(height: 12),
                      _buildMetadataRow("Miembro Desde", "15 Ene, 2023"),
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

          // Formulario de Datos Personales / Seguridad (Tabs)
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

          // Enlaces Rápidos: Cerrar Sesión
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x0F1D2848)),
            ),
            child: ListTile(
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
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkspaceSwitcher(String activeRole) {
    final isNurse = activeRole == 'enfermero';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Espacio de Trabajo Activo".toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Nurse Card option
            Expanded(
              child: _buildRoleCard(
                title: "Tópico / Salud",
                icon: LucideIcons.activity,
                activeColor: const Color(0xFF2E7D32),
                roleKey: 'enfermero',
                isSelected: isNurse,
              ),
            ),
            const SizedBox(width: 10),
            // Library Card option
            Expanded(
              child: _buildRoleCard(
                title: "Biblioteca",
                icon: LucideIcons.bookOpen,
                activeColor: const Color(0xFF8B5CF6),
                roleKey: 'bibliotecario',
                isSelected: !isNurse,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required Color activeColor,
    required String roleKey,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onRoleChanged(roleKey);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
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
