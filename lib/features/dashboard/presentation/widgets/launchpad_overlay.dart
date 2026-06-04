import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchpadOverlay extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onClose;
  final Function(String screen) onNavigate;
  final Function(String menuId) onSubmenuTap;

  const LaunchpadOverlay({
    super.key,
    required this.user,
    required this.onClose,
    required this.onNavigate,
    required this.onSubmenuTap,
  });

  @override
  State<LaunchpadOverlay> createState() => _LaunchpadOverlayState();
}

class _LaunchpadOverlayState extends State<LaunchpadOverlay> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  // Estructura de Módulos por Categoría
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Académico',
      'color': Colors.blue,
      'modules': [
        {'id': 'classroom', 'name': 'Aula Virtual', 'icon': LucideIcons.graduationCap, 'route': 'classroom'},
        {'id': 'boards', 'name': 'Proyectos & Tableros', 'icon': LucideIcons.columns},
        {'id': 'clubs', 'name': 'Clubs Exitus', 'icon': LucideIcons.users2},
        {'id': 'parents', 'name': 'Familias / Padres', 'icon': LucideIcons.users},
        {'id': 'curr', 'name': 'Plan. Curricular', 'icon': LucideIcons.briefcase},
        {'id': 'diary', 'name': 'Bitácoras / Diario', 'icon': LucideIcons.book, 'submenu': true},
        {'id': 'grid', 'name': 'Cursos y Malla', 'icon': LucideIcons.bookMarked},
        {'id': 'eval', 'name': 'Evaluación Docente', 'icon': LucideIcons.star, 'submenu': true},
      ]
    },
    {
      'name': 'Control Escolar',
      'color': Colors.orange,
      'modules': [
        {'id': 'my_attendance', 'name': 'Mi Asistencia', 'icon': LucideIcons.userCheck},
        {'id': 'excuses', 'name': 'Justificaciones', 'icon': LucideIcons.mailOpen},
        {'id': 'quick_sign', 'name': 'Firma Rápida', 'icon': LucideIcons.penTool},
        {'id': 'attendance_report', 'name': 'Asistencia Gral.', 'icon': LucideIcons.calendarCheck2},
        {'id': 'schedules', 'name': 'Horarios', 'icon': LucideIcons.clock},
      ]
    },
    {
      'name': 'Especiales',
      'color': Colors.purple,
      'modules': [
        {'id': 'actia', 'name': 'Sesiones ActIA', 'icon': LucideIcons.cpu, 'submenu': true},
        {'id': 'sims', 'name': 'Simulaciones', 'icon': LucideIcons.bookOpen},
        {'id': 'psy', 'name': 'Psicología', 'icon': LucideIcons.heart, 'submenu': true},
        {'id': 'topico', 'name': 'Tópico / Enfermería', 'icon': LucideIcons.activity, 'submenu': true},
        {'id': 'student_council', 'name': 'Consejo Estudiantil', 'icon': LucideIcons.vote, 'submenu': true},
      ]
    },
    {
      'name': 'Finanzas',
      'color': Colors.green,
      'modules': [
        {'id': 'tesoreria', 'name': 'Tesorería / Pagos', 'icon': LucideIcons.landmark, 'submenu': true},
        {'id': 'dojo_shop', 'name': 'Tienda Dojo', 'icon': LucideIcons.shoppingBag},
        {'id': 'dojo_admin', 'name': 'Gestión Dojo', 'icon': LucideIcons.settings2},
      ]
    },
    {
      'name': 'Servicios & Admin',
      'color': const Color(0xFF37474F),
      'modules': [
        {'id': 'digitacion', 'name': 'Área de Digitación', 'icon': LucideIcons.printer, 'route': 'digitacion'},
        {'id': 'cafetin', 'name': 'Cafetín', 'icon': LucideIcons.coffee, 'submenu': true},
        {'id': 'forms', 'name': 'Formularios', 'icon': LucideIcons.listTodo},
        {'id': 'master_qr', 'name': 'QR Maestro', 'icon': LucideIcons.qrCode},
        {'id': 'my_profile', 'name': 'Mi Perfil', 'icon': LucideIcons.userCog},
        {'id': 'whatsapp_notif', 'name': 'Notificaciones WA', 'icon': LucideIcons.messageSquare, 'submenu': true},
      ]
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'student';

    // Filtrar categorías y módulos reactivamente
    List<Map<String, dynamic>> filteredCategories = [];

    for (var cat in _categories) {
      final List<Map<String, dynamic>> modules = List<Map<String, dynamic>>.from(cat['modules']);
      final filteredModules = modules.where((mod) {
        final matchesSearch = mod['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesSearch) return false;

        // Filtrar por rol
        final modId = mod['id'];
        if (role == 'student') {
          if (modId == 'curr' || modId == 'diary' || modId == 'eval' || 
              modId == 'quick_sign' || modId == 'attendance_report' || 
              modId == 'dojo_admin' || modId == 'digitacion') {
            return false;
          }
        }
        return true;
      }).toList();

      if (filteredModules.isNotEmpty) {
        filteredCategories.add({
          'name': cat['name'],
          'color': cat['color'],
          'modules': filteredModules,
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Frosted glass background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: const Color(0xFFF5F6F9).withValues(alpha: 0.88),
              ),
            ),
          ),

          // 2. Contenido principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera superior
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PORTAL EXITUS",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            "Servicios de la Institución",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 22, color: Color(0xFF1D2848)),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),

                // Buscador de Módulos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar módulo...",
                      prefixIcon: const Icon(LucideIcons.search, size: 16),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Grilla de Módulos por Categoría
                Expanded(
                  child: filteredCategories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(LucideIcons.compass, size: 36, color: Color(0xFF94A3B8)),
                              SizedBox(height: 8),
                              Text(
                                "No se encontraron módulos",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, catIndex) {
                            final cat = filteredCategories[catIndex];
                            final color = cat['color'] as Color;
                            final modules = cat['modules'] as List<Map<String, dynamic>>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título de la Categoría
                                Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                                  child: Text(
                                    cat['name'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),

                                // Grilla de módulos de esta categoría (3 columnas)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.95,
                                  ),
                                  itemCount: modules.length,
                                  itemBuilder: (context, modIndex) {
                                    final mod = modules[modIndex];
                                    return _buildModuleCard(mod, color);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> mod, Color color) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (mod['route'] != null) {
            widget.onNavigate(mod['route']);
          } else if (mod['submenu'] == true) {
            widget.onSubmenuTap(mod['id']);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Módulo ${mod['name']} abierto.")),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contenedor de Icono coloreado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  mod['icon'] as IconData,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              // Nombre del módulo
              Text(
                mod['name'],
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2848),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
