import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';

class TeacherCourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final User teacherUser;

  const TeacherCourseDetailsScreen({
    super.key,
    required this.course,
    required this.teacherUser,
  });

  @override
  State<TeacherCourseDetailsScreen> createState() => _TeacherCourseDetailsScreenState();
}

class _TeacherCourseDetailsScreenState extends State<TeacherCourseDetailsScreen> {
  int _activeTab = 0; // 0: Contenido, 1: Dojo, 2: Rúbricas, 3: Picklers

  // Estructura de datos reactiva para los acordeones de Trimestres y Sesiones
  late Map<String, List<Map<String, dynamic>>> _trimesterSessions;

  // Datos simulados para la pestaña Dojo
  late List<Map<String, dynamic>> _dojoStudentsList;
  int _weeklyPoints = 480;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Carga sesiones iniciales con datos específicos según el curso seleccionado
  void _loadInitialData() {
    final String courseId = widget.course['id'] ?? '';
    final String courseTitle = widget.course['title'] ?? '';

    // Inicializar lista de Dojo con los 4 estudiantes del mockup
    _dojoStudentsList = [
      {
        'id': 1,
        'name': 'Juan Pérez',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        'level': 8,
        'points': 1240,
        'dragonType': 'rayo',
      },
      {
        'id': 2,
        'name': 'María Torres',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        'level': 10,
        'points': 1890,
        'dragonType': 'lava',
      },
      {
        'id': 3,
        'name': 'Carlos Ruiz',
        'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
        'level': 6,
        'points': 850,
        'dragonType': 'glaciar',
      },
      {
        'id': 4,
        'name': 'Sofía López',
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        'level': 7,
        'points': 1050,
        'dragonType': 'brasa',
      },
    ];

    if (courseId == 'c_tutoria' || courseTitle.contains('Tutoría')) {
      _trimesterSessions = {
        'Primer Trimestre': [
          {
            'id': 's_t1_01',
            'title': 'Sesión 01',
            'type': 'Clase',
            'name': 'Charla de Convivencia Escolar',
            'visible': true,
            'resources': [
              {'type': 'Clase', 'title': 'Charla de Convivencia Escolar', 'visible': true},
              {'type': 'Enlace', 'title': 'Video de Reflexión sobre Empatía', 'visible': true},
            ]
          },
          {
            'id': 's_t1_02',
            'title': 'Sesión 02',
            'type': 'Tarea',
            'name': 'Hábitos de Estudio en Casa',
            'visible': false,
            'resources': [
              {'type': 'Tarea', 'title': 'Organizador de Horarios Semanales', 'visible': false},
            ]
          },
        ],
        'Segundo Trimestre': [],
        'Tercer Trimestre': [],
      };
    } else if (courseId == 'c_fisica' || courseTitle.contains('Ciencia')) {
      _trimesterSessions = {
        'Primer Trimestre': [
          {
            'id': 's_c1_01',
            'title': 'Sesión 01',
            'type': 'Clase',
            'name': 'El Método Científico',
            'visible': true,
            'resources': [
              {'type': 'Clase', 'title': 'Diapositivas: Pasos del Método', 'visible': true},
            ]
          },
          {
            'id': 's_c1_02',
            'title': 'Sesión 02',
            'type': 'Actividad',
            'name': 'Experimento de Densidades',
            'visible': true,
            'resources': [
              {'type': 'Actividad', 'title': 'Reporte de Observación del Agua y Aceite', 'visible': true},
            ]
          },
        ],
        'Segundo Trimestre': [],
        'Tercer Trimestre': [],
      };
    } else {
      // Por defecto Chino Mandarín u otros
      _trimesterSessions = {
        'Primer Trimestre': [
          {
            'id': 's_01',
            'title': 'Sesión 01',
            'type': 'Clase',
            'name': 'Introducción al Mandarín',
            'visible': true,
            'resources': [
              {'type': 'Clase', 'title': 'Introducción al Mandarín', 'visible': true},
            ]
          },
          {
            'id': 's_02',
            'title': 'Sesión 02',
            'type': 'Tarea',
            'name': 'Saludos Básicos',
            'visible': false,
            'resources': [
              {'type': 'Tarea', 'title': 'Saludos Básicos', 'visible': false},
            ]
          },
          {
            'id': 's_03',
            'title': 'Sesión 03',
            'type': 'Actividad',
            'name': 'Escribe tu nombre en chino',
            'visible': true,
            'resources': [
              {'type': 'Actividad', 'title': 'Escribe tu nombre en chino', 'visible': true},
            ]
          },
        ],
        'Segundo Trimestre': [],
        'Tercer Trimestre': [],
      };
    }
  }

  // Agrega una nueva sesión a un trimestre específico
  void _addSession(String trimester) {
    setState(() {
      final int nextNum = _trimesterSessions[trimester]!.length + 1;
      final String sessionNum = nextNum < 10 ? '0$nextNum' : '$nextNum';
      
      _trimesterSessions[trimester]!.add({
        'id': 's_${trimester.replaceAll(' ', '_')}_$nextNum',
        'title': 'Sesión $sessionNum',
        'type': 'Clase',
        'name': 'Nueva Sesión de Contenido',
        'visible': true,
        'resources': [],
      });
    });
  }

  // Elimina una sesión del trimestre
  void _deleteSession(String trimester, int index) {
    setState(() {
      _trimesterSessions[trimester]!.removeAt(index);
    });
  }

  // Cambia la visibilidad de una sesión
  void _toggleSessionVisibility(String trimester, int index) {
    setState(() {
      final session = _trimesterSessions[trimester]![index];
      session['visible'] = !session['visible'];
    });
  }

  // Abre el bottom sheet de agregar contenido (Pantalla 3)
  void _openAddContentSheet(String trimester, int sessionIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildAddContentBottomSheet(trimester, sessionIndex);
      },
    );
  }

  // Abre el diálogo para ingresar el título del nuevo recurso
  void _showAddResourceDialog(String trimester, int sessionIndex, String typeName, IconData icon) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(icon, color: const Color(0xFF1D2848), size: 20),
              const SizedBox(width: 8),
              Text(
                "Agregar $typeName",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Título del recurso...",
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEDC620), width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = textController.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _trimesterSessions[trimester]![sessionIndex]['resources'].add({
                      'type': typeName,
                      'title': title,
                      'visible': true,
                    });
                    
                    // También actualiza el nombre primario de la sesión si estaba vacío
                    if (_trimesterSessions[trimester]![sessionIndex]['name'] == 'Nueva Sesión de Contenido') {
                      _trimesterSessions[trimester]![sessionIndex]['name'] = title;
                      _trimesterSessions[trimester]![sessionIndex]['type'] = typeName;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Agregar", style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Cabecera Dinámica y Temática
          _buildDynamicHeader(statusBarHeight),
          
          // 2. Selector de Pestañas (Sub-navegación)
          _buildTabBar(),

          // 3. Contenido de la Pestaña Activa
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildActiveView(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 16,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, LucideIcons.home, "Inicio"),
                _buildBottomNavItem(1, LucideIcons.bell, "Avisos"),
                // Botón central flotante '+' en dorado/ámbar
                GestureDetector(
                  onTap: () => Navigator.pop(context, 99), // Acción de agregar
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDC620),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4DEDC620),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
                  ),
                ),
                _buildBottomNavItem(2, LucideIcons.mail, "Mensajes"),
                _buildBottomNavItem(3, LucideIcons.user, "Mi perfil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    return InkWell(
      onTap: () => Navigator.pop(context, index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Genera la cabecera con fondos y decoraciones dinámicas de acuerdo al curso
  Widget _buildDynamicHeader(double statusBarHeight) {
    final String courseTitle = widget.course['title'] ?? 'Curso';
    final String courseCategory = widget.course['category'] ?? 'General';
    final String level = widget.course['level'] ?? 'Secundaria';
    final String levelNum = widget.course['levelNum'] ?? '';
    final String iconType = widget.course['iconType'] ?? '';

    // Configurar el gradiente y el diseño según la materia
    LinearGradient bgGradient;
    Color primaryColor;
    CustomPainter? decorationPainter;

    if (courseTitle.contains('Chino')) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFF7ED), Color(0xFFFEE2E2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      primaryColor = const Color(0xFFEF4444);
      decorationPainter = PagodaPainter();
    } else if (courseTitle.contains('Tutoría')) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      primaryColor = const Color(0xFFF59E0B);
      decorationPainter = CirclesPainter();
    } else if (courseTitle.contains('Ciencia') || courseTitle.contains('Tecnología')) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      primaryColor = const Color(0xFF10B981);
      decorationPainter = TechPainter();
    } else {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      primaryColor = const Color(0xFF3B82F6);
      decorationPainter = GenericPainter();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: statusBarHeight + 10, bottom: 20),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Pintor decorativo temático a la derecha
          if (decorationPainter != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(painter: decorationPainter),
              ),
            ),
          
          // Contenido principal de la cabecera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Botón Atrás y Botón Tres Puntos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: Color(0xFF1D2848),
                          size: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.moreVertical,
                        color: Color(0xFF1D2848),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Cuerpo de la cabecera: Icono/Bandera y Textos del Curso
                Row(
                  children: [
                    // Icono dinámico según el curso
                    _buildDynamicHeaderIcon(iconType, primaryColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título del curso
                          Text(
                            courseTitle,
                            style: GoogleFonts.outfit(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                          const SizedBox(height: 2),
                          
                          // Categoría/Área
                          Text(
                            courseCategory,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // Badges / Tags de Grado y Nivel
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  level,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    color: const Color(0xFF1D2848),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  levelNum,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    color: const Color(0xFF1D2848),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeaderIcon(String type, Color primaryColor) {
    const double size = 50;
    if (type == 'china_flag') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
        ),
        child: const ChinaFlagCircle2(size: size),
      );
    } else if (type == 'tutoria') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            )
          ]
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.users,
          color: primaryColor,
          size: 24,
        ),
      );
    } else {
      // Ciencias / Ciencia y Tecnología
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            )
          ]
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.flaskConical,
          color: primaryColor,
          size: 24,
        ),
      );
    }
  }

  // Barra de Pestañas Superior
  Widget _buildTabBar() {
    final tabs = ["Contenido", "Dojo", "Rúbricas", "Picklers"];
    final icons = [LucideIcons.bookOpen, LucideIcons.sparkles, LucideIcons.clipboardList, LucideIcons.camera];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSel = _activeTab == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSel ? const Color(0xFF3B82F6) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: isSel ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabs[index],
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Renderiza la vista según la pestaña activa
  Widget _buildActiveView() {
    switch (_activeTab) {
      case 0:
        return _buildContenidoView();
      case 1:
        return _buildDojoView();
      case 2:
        return _buildPlaceholderView("Rúbricas", LucideIcons.clipboardList, "Monitorea la evaluación por competencias de este curso.");
      case 3:
        return _buildPlaceholderView("Picklers", LucideIcons.camera, "Usa la herramienta Picklers para participaciones aleatorias.");
      default:
        return const SizedBox.shrink();
    }
  }

  // VISTA 1: CONTENIDO (Acordeones Anizados de Trimestre y Sesión)
  Widget _buildContenidoView() {
    final trimesters = ['Primer Trimestre', 'Segundo Trimestre', 'Tercer Trimestre'];
    final dateRanges = {
      'Primer Trimestre': '04 Mar - 20 Jun',
      'Segundo Trimestre': '01 Jun - 20 Set',
      'Tercer Trimestre': '21 Set - 15 Dic'
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: trimesters.length,
      itemBuilder: (context, index) {
        final trimester = trimesters[index];
        final dates = dateRanges[trimester]!;
        final sessions = _trimesterSessions[trimester] ?? [];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0, // El primer trimestre abierto por defecto
              title: Text(
                trimester,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
              subtitle: Text(
                dates,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              leading: const Icon(LucideIcons.calendar, color: Color(0xFF3B82F6), size: 18),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                // Fila para crear sesión dentro del Trimestre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sesiones de Aprendizaje",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEDC620).withOpacity(0.12),
                        foregroundColor: const Color(0xFFB45309),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () => _addSession(trimester),
                      icon: const Icon(LucideIcons.plus, size: 13),
                      label: Text(
                        "Crear Sesión",
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                
                // Lista de sesiones del trimestre (Acordeón de nivel 2)
                if (sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No hay sesiones creadas para este trimestre.",
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                else
                  Column(
                    children: List.generate(sessions.length, (sIndex) {
                      final session = sessions[sIndex];
                      return _buildSessionAccordion(trimester, session, sIndex);
                    }),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Acordeón de Nivel 2: Sesión de clase
  Widget _buildSessionAccordion(String trimester, Map<String, dynamic> session, int sIndex) {
    final String title = session['title'] ?? 'Sesión';
    final String topic = session['name'] ?? '';
    final List<Map<String, dynamic>> resources = List<Map<String, dynamic>>.from(session['resources'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.folder, color: Color(0xFF64748B), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    Text(
                      topic,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
          children: [
            const Divider(color: Color(0xFFE2E8F0), height: 16),
            const SizedBox(height: 4),
            
            // Listado de Sub-recursos agregados a esta Sesión (Nivel 3) con diseño Premium
            if (resources.isNotEmpty)
              Column(
                children: List.generate(resources.length, (rIndex) {
                  final res = resources[rIndex];
                  return _buildResourceCard(trimester, sIndex, res, rIndex);
                }),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    "No hay contenidos en esta sesión.",
                    style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF94A3B8)),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Botón "+" para agregar contenido a esta sesión en particular
            GestureDetector(
              onTap: () => _openAddContentSheet(trimester, sIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.plus, color: Color(0xFF3B82F6), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Agregar contenido",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta premium de recurso
  Widget _buildResourceCard(String trimester, int sessionIndex, Map<String, dynamic> res, int resIndex) {
    final String type = res['type'] ?? 'Clase';
    final String title = res['title'] ?? '';
    final bool visible = res['visible'] ?? true;

    IconData typeIcon = LucideIcons.bookOpen;
    Color themeColor = const Color(0xFF3B82F6);
    Color bgColor = const Color(0xFFEFF6FF);

    if (type == 'Tarea') {
      typeIcon = LucideIcons.fileText;
      themeColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFFFBEB);
    } else if (type == 'Actividad') {
      typeIcon = LucideIcons.target;
      themeColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFECFDF5);
    } else if (type == 'Desafío') {
      typeIcon = LucideIcons.trophy;
      themeColor = const Color(0xFF8B5CF6);
      bgColor = const Color(0xFFF5F3FF);
    } else if (type == 'Evaluación') {
      typeIcon = LucideIcons.clipboardCheck;
      themeColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEF2F2);
    } else if (type == 'Encuesta') {
      typeIcon = LucideIcons.barChart2;
      themeColor = const Color(0xFF06B6D4);
      bgColor = const Color(0xFFECFEFF);
    } else if (type == 'Foro') {
      typeIcon = LucideIcons.messageSquare;
      themeColor = const Color(0xFFEC4899);
      bgColor = const Color(0xFFFDF2F8);
    } else if (type == 'Enlace') {
      typeIcon = LucideIcons.link;
      themeColor = const Color(0xFF6B7280);
      bgColor = const Color(0xFFF9FAFB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono en cuadrado redondeado
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(typeIcon, color: themeColor, size: 22),
          ),
          const SizedBox(width: 12),
          
          // Información central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  type,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Indicador de Visibilidad (Interactivo)
                GestureDetector(
                  onTap: () => _toggleResourceVisibility(trimester, sessionIndex, resIndex),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        visible ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: visible ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        visible ? "Visible para estudiantes" : "Oculta para estudiantes",
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: visible ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Acciones en la derecha (Tres puntos arriba, Editar/Borrar abajo)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Icono tres puntos
              const Icon(
                LucideIcons.moreVertical,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              
              // Botones de acción en cajas bordeadas
              Row(
                children: [
                  // Editar
                  GestureDetector(
                    onTap: () => _editResource(trimester, sessionIndex, resIndex),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        LucideIcons.pencil,
                        color: Color(0xFF64748B),
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Eliminar
                  GestureDetector(
                    onTap: () => _deleteResource(trimester, sessionIndex, resIndex),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: Color(0xFFEF4444),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Métodos interactivos de Recursos
  void _editResource(String trimester, int sessionIndex, int resourceIndex) {
    final resource = _trimesterSessions[trimester]![sessionIndex]['resources'][resourceIndex];
    final textController = TextEditingController(text: resource['title']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Editar Recurso", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDC620), width: 1.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = textController.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    resource['title'] = newTitle;
                    // Actualiza el tema primario de la sesión si es el único recurso
                    if (_trimesterSessions[trimester]![sessionIndex]['resources'].length == 1) {
                      _trimesterSessions[trimester]![sessionIndex]['name'] = newTitle;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2848)),
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteResource(String trimester, int sessionIndex, int resourceIndex) {
    setState(() {
      _trimesterSessions[trimester]![sessionIndex]['resources'].removeAt(resourceIndex);
    });
  }

  void _toggleResourceVisibility(String trimester, int sessionIndex, int resourceIndex) {
    setState(() {
      final res = _trimesterSessions[trimester]![sessionIndex]['resources'][resourceIndex];
      res['visible'] = !res['visible'];
    });
  }

  // BOTTOM SHEET DE AGREGAR CONTENIDO (Pantalla 3)
  Widget _buildAddContentBottomSheet(String trimester, int sessionIndex) {
    // Opciones del Bottom Sheet con sus respectivos iconos y colores
    final List<Map<String, dynamic>> options = [
      {'name': 'Nueva Clase', 'icon': LucideIcons.bookOpen, 'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF)},
      {'name': 'Nueva Tarea', 'icon': LucideIcons.fileText, 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFFFBEB)},
      {'name': 'Nueva Actividad', 'icon': LucideIcons.target, 'color': const Color(0xFF10B981), 'bg': const Color(0xFFECFDF5)},
      {'name': 'Nuevo Desafío', 'icon': LucideIcons.trophy, 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFFF5F3FF)},
      {'name': 'Nueva Evaluación', 'icon': LucideIcons.clipboardCheck, 'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFEF2F2)},
      {'name': 'Nueva Encuesta', 'icon': LucideIcons.barChart2, 'color': const Color(0xFF06B6D4), 'bg': const Color(0xFFECFEFF)},
      {'name': 'Nuevo Foro', 'icon': LucideIcons.messageSquare, 'color': const Color(0xFFEC4899), 'bg': const Color(0xFFFDF2F8)},
      {'name': 'Nuevo Enlace', 'icon': LucideIcons.link, 'color': const Color(0xFF6B7280), 'bg': const Color(0xFFF9FAFB)},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de Arrastre
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
          
          // Encabezado del Bottom Sheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Agregar contenido",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Listado de Opciones
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context); // Cerrar bottom sheet
                  // Remover el prefijo "Nueva " o "Nuevo " para simplificar el nombre del tipo
                  final typeName = opt['name'].replaceAll('Nueva ', '').replaceAll('Nuevo ', '');
                  _showAddResourceDialog(trimester, sessionIndex, typeName, opt['icon']);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: opt['bg'],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(opt['icon'], color: opt['color'], size: 18),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        opt['name'],
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Placeholder para pestañas en desarrollo
  Widget _buildPlaceholderView(String title, IconData icon, String desc) {
    return Center(
      key: ValueKey(title),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2848).withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Diseño en Simulación",
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PESTAÑA DOJO (Pantalla 4)
  Widget _buildDojoView() {
    final filteredStudents = _dojoStudentsList
        .where((s) => s['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 1. Tarjeta de Puntos Otorgados
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFEFF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Puntos otorgados",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Esta semana",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.star, color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "+$_weeklyPoints",
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dragón de Dojo (Glaciar - Azul)
                const DragonWidget(
                  dragonType: 'glaciar',
                  points: 15,
                  size: 85,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Buscador de Estudiante
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.search, color: Color(0xFF94A3B8), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Buscar estudiante...",
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: const Icon(LucideIcons.x, color: Color(0xFF64748B), size: 16),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. Lista de Estudiantes
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      "No se encontraron estudiantes.",
                      style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final int points = student['points'];
                      
                      // Formatear el puntaje con comas
                      final String pointsFormatted = points.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // Avatar del Estudiante
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(student['avatar']),
                              backgroundColor: const Color(0xFFF1F5F9),
                            ),
                            const SizedBox(width: 12),
                            
                            // Nombre y Nivel
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'],
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1D2848),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    "Nivel ${student['level']}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Puntos y Controles (+10 / -10)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Puntos
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.star, color: Colors.white, size: 8),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$pointsFormatted puntos",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                // Botones +10 / -10
                                Row(
                                  children: [
                                    // Botón -10
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (student['points'] >= 10) {
                                            student['points'] -= 10;
                                            _weeklyPoints -= 10;
                                            if (_weeklyPoints < 0) _weeklyPoints = 0;
                                            
                                            // Recalcular nivel
                                            final calculatedLevel = (student['points'] / 150).floor() + 1;
                                            student['level'] = calculatedLevel.clamp(1, 99);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFFCA5A5)),
                                        ),
                                        child: Text(
                                          "-10",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFEF4444),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    
                                    // Botón +10
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          student['points'] += 10;
                                          _weeklyPoints += 10;
                                          
                                          // Recalcular nivel
                                          final calculatedLevel = (student['points'] / 150).floor() + 1;
                                          student['level'] = calculatedLevel.clamp(1, 99);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFA7F3D0)),
                                        ),
                                        child: Text(
                                          "+10",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF10B981),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Pintores personalizados temáticos para las esquinas traseras de la cabecera
class PagodaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFCA5A5).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Dibujar un boceto estilo Pagoda
    path.moveTo(w * 0.5, h * 0.1);
    path.lineTo(w * 0.5, h * 0.2);
    // Eaves 1
    path.moveTo(w * 0.2, h * 0.35);
    path.quadraticBezierTo(w * 0.5, h * 0.25, w * 0.8, h * 0.35);
    path.lineTo(w * 0.75, h * 0.45);
    path.quadraticBezierTo(w * 0.5, h * 0.4, w * 0.25, h * 0.45);
    path.close();
    // Eaves 2
    path.moveTo(w * 0.1, h * 0.6);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w * 0.9, h * 0.6);
    path.lineTo(w * 0.85, h * 0.75);
    path.quadraticBezierTo(w * 0.5, h * 0.68, w * 0.15, h * 0.75);
    path.close();
    // Base columns
    path.moveTo(w * 0.3, h * 0.75);
    path.lineTo(w * 0.3, h * 0.95);
    path.moveTo(w * 0.7, h * 0.75);
    path.lineTo(w * 0.7, h * 0.95);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFDE68A).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.6), 35, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.75), 15, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TechPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA7F3D0).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    // Dibujar forma de átomo o anillos de tecnología
    path.addOval(Rect.fromCenter(center: Offset(w * 0.6, h * 0.5), width: 60, height: 25));
    canvas.drawPath(path, paint);
    
    final path2 = Path();
    path2.addOval(Rect.fromCenter(center: Offset(w * 0.6, h * 0.5), width: 25, height: 60));
    canvas.drawPath(path2, paint);
    
    canvas.drawCircle(Offset(w * 0.6, h * 0.5), 6, Paint()..color = const Color(0xFFA7F3D0).withOpacity(0.6));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GenericPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBAE6FD).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    
    // Lineas geometricas abstractas
    path.moveTo(w * 0.2, h * 0.2);
    path.lineTo(w * 0.8, h * 0.8);
    path.moveTo(w * 0.4, h * 0.1);
    path.lineTo(w * 0.9, h * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ChinaFlagCircle2 extends StatelessWidget {
  final double size;
  const ChinaFlagCircle2({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDE2910),
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.22,
            top: size * 0.22,
            child: Icon(
              Icons.star,
              color: const Color(0xFFFFDE00),
              size: size * 0.35,
            ),
          ),
          Positioned(
            left: size * 0.56,
            top: size * 0.12,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.star,
                color: const Color(0xFFFFDE00),
                size: size * 0.10,
              ),
            ),
          ),
          Positioned(
            left: size * 0.68,
            top: size * 0.24,
            child: Transform.rotate(
              angle: 0.8,
              child: Icon(
                Icons.star,
                color: const Color(0xFFFFDE00),
                size: size * 0.10,
              ),
            ),
          ),
          Positioned(
            left: size * 0.68,
            top: size * 0.42,
            child: Transform.rotate(
              angle: 0.0,
              child: Icon(
                Icons.star,
                color: const Color(0xFFFFDE00),
                size: size * 0.10,
              ),
            ),
          ),
          Positioned(
            left: size * 0.56,
            top: size * 0.54,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.star,
                color: const Color(0xFFFFDE00),
                size: size * 0.10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
