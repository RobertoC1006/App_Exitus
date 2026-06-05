import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
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

  final _db = MockDatabase();
  late List<DojoStudent> _allDojoStudents;
  int _weeklyPoints = 480;
  final _searchController = TextEditingController();
  String _searchQuery = "";

  String _selectedTrimester = "Primer Trimestre";

  final Map<String, List<Map<String, dynamic>>> _trimesterRubrics = {
    'Primer Trimestre': [
      {
        'title': 'Participación en clase',
        'criterio': 'Participación',
        'progress': 0.90,
        'status': 'Excelente',
        'icon': LucideIcons.users,
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFF5F3FF),
      },
      {
        'title': 'Responsabilidad',
        'criterio': 'Responsabilidad',
        'progress': 0.70,
        'status': 'Bueno',
        'icon': LucideIcons.clipboardList,
        'color': const Color(0xFF3B82F6),
        'bgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Trabajo en equipo',
        'criterio': 'Colaboración',
        'progress': 0.80,
        'status': 'Muy bueno',
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF10B981),
        'bgColor': const Color(0xFFECFDF5),
      },
    ],
    'Segundo Trimestre': [
      {
        'title': 'Exposición Oral',
        'criterio': 'Comunicación',
        'progress': 0.85,
        'status': 'Muy bueno',
        'icon': LucideIcons.mic,
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
      },
      {
        'title': 'Proyecto de Investigación',
        'criterio': 'Creatividad',
        'progress': 0.95,
        'status': 'Excelente',
        'icon': LucideIcons.presentation,
        'color': const Color(0xFFEC4899),
        'bgColor': const Color(0xFFFDF2F8),
      },
    ],
    'Tercer Trimestre': [
      {
        'title': 'Examen Final de Periodo',
        'criterio': 'Conocimiento',
        'progress': 0.60,
        'status': 'Regular',
        'icon': LucideIcons.fileText,
        'color': const Color(0xFFEF4444),
        'bgColor': const Color(0xFFFEF2F2),
      },
    ],
  };

  // Estructura de datos reactiva para los acordeones de Trimestres y Sesiones
  late Map<String, List<Map<String, dynamic>>> _trimesterSessions;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initDojoList();
  }

  // Carga sesiones iniciales con datos específicos según el curso seleccionado
  void _loadInitialData() {
    final String courseId = widget.course['id'] ?? '';
    final String courseTitle = widget.course['title'] ?? '';

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
                              color: Colors.black.withValues(alpha: 0.04),
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
                            color: Colors.black.withValues(alpha: 0.04),
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
                                      color: Colors.black.withValues(alpha: 0.02),
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
                                      color: Colors.black.withValues(alpha: 0.02),
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
              color: Colors.black.withValues(alpha: 0.08),
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
              color: Colors.black.withValues(alpha: 0.04),
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
              color: Colors.black.withValues(alpha: 0.04),
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
    final icons = [LucideIcons.bookOpenText, LucideIcons.sparkles, LucideIcons.clipboardList, LucideIcons.camera];
    
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
        return _buildRubricasView();
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
                color: Colors.black.withValues(alpha: 0.02),
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
                        backgroundColor: const Color(0xFFEDC620).withValues(alpha: 0.12),
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
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), style: BorderStyle.solid),
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

    IconData typeIcon = LucideIcons.bookOpenText;
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
            color: Colors.black.withValues(alpha: 0.015),
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
                      Flexible(
                        child: Text(
                          visible ? "Visible para estudiantes" : "Oculta para estudiantes",
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: visible ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
      {'name': 'Nueva Clase', 'icon': LucideIcons.bookOpenText, 'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF)},
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
                color: const Color(0xFF1D2848).withValues(alpha: 0.06),
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
  void _initDojoList() {
    final dbStudents = _db.getDojoStudents();
    
    // Scale DB points to UI points (x100) if they are in the database format (e.g. < 100)
    for (var s in dbStudents) {
      if (s.points < 100) {
        s.points = s.points * 100;
      }
    }
    
    // Check if mockup students are already in the list
    bool hasMockup = dbStudents.any((s) => s.name == 'Juan Pérez');
    if (!hasMockup) {
      // Create mockup students matching the mockup screen
      final mockStudents = [
        DojoStudent(id: 101, name: 'Juan Pérez', points: 1240, present: true, dragonType: 'brasa'),
        DojoStudent(id: 102, name: 'María Torres', points: 850, present: true, dragonType: 'glaciar'),
        DojoStudent(id: 103, name: 'Carlos Ruiz', points: 510, present: true, dragonType: 'lava'),
        DojoStudent(id: 104, name: 'Sofía López', points: 320, present: true, dragonType: 'rayo'),
      ];
      
      // Let's insert them into the DB so they are present in the list returned by getDojoStudents()
      for (var s in mockStudents.reversed) {
        dbStudents.insert(0, s);
      }
    }
    
    _allDojoStudents = dbStudents;
  }

  // VISTA 2: DOJO
  Widget _buildDojoView() {
    final filteredList = _allDojoStudents.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // 1. Tarjeta Resumen de Puntos Otorgados Semanal (Sin dragones)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Puntos otorgados",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Esta semana",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "+${_formatNumber(_weeklyPoints)}",
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildGoldCoin(),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Buscador de Alumnos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1D2848)),
              decoration: InputDecoration(
                hintText: "Buscar estudiante...",
                hintStyle: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF94A3B8)),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // 3. Lista de Estudiantes
        Expanded(
          child: filteredList.isEmpty
              ? _buildDojoEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = filteredList[index];
                    return _buildDojoStudentCard(student);
                  },
                ),
        ),
      ],
    );
  }

  // Widget para el estado vacío
  Widget _buildDojoEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.userX, size: 36, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            Text(
              "Sin resultados",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No se encontraron alumnos que coincidan con '$_searchQuery'",
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Moneda Dorada Animada/Estilizada
  Widget _buildGoldCoin() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFDE047), Color(0xFFEAB308), Color(0xFFCA8A04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFEF08A), width: 1.5),
      ),
      child: const Center(
        child: Icon(
          LucideIcons.coins,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // Tarjeta de Alumno de Dojo
  Widget _buildDojoStudentCard(DojoStudent s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del alumno
          _buildStudentAvatar(s),
          const SizedBox(width: 14),

          // Columna Central: Nombre, nivel, dragón y fase
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    // Badge del nivel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Nivel ${s.points ~/ 100}",
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Dragon inline widget
                    DragonWidget(
                      dragonType: s.dragonType,
                      points: s.points ~/ 100,
                      size: 24,
                    ),
                    const SizedBox(width: 6),

                    // Fase del Dragón
                    Text(
                      _getDragonStage(s.points ~/ 100).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: _getElementalColor(s.dragonType),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Columna Derecha: Puntos y botones +10/-10
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_formatNumber(s.points)} pts",
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildAdjustButton("-10", () => _adjustPoints(s, -10), isSubtract: true),
                  const SizedBox(width: 6),
                  _buildAdjustButton("+10", () => _adjustPoints(s, 10), isSubtract: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Avatar con iniciales y color aleatorio agradable
  Widget _buildStudentAvatar(DojoStudent s) {
    final initials = s.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();

    final colorIndex = s.name.length % 5;
    final List<Color> bgColors = [
      const Color(0xFFEFF6FF),
      const Color(0xFFECFDF5),
      const Color(0xFFFFF7ED),
      const Color(0xFFFDF2F8),
      const Color(0xFFFAF5FF),
    ];
    final List<Color> textColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF97316),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColors[colorIndex],
        shape: BoxShape.circle,
        border: Border.all(color: textColors[colorIndex].withValues(alpha: 0.15), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColors[colorIndex],
          ),
        ),
      ),
    );
  }

  // Botón +10 / -10
  Widget _buildAdjustButton(String label, VoidCallback onTap, {required bool isSubtract}) {
    final bgColor = isSubtract ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final textColor = isSubtract ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // Lógica para sumar/restar puntos y evolucionar dragón
  void _adjustPoints(DojoStudent student, int amount) {
    final oldLevel = student.points ~/ 100;
    final oldStage = _getDragonStage(oldLevel);

    setState(() {
      student.points = (student.points + amount).clamp(0, 9999);
      _weeklyPoints = (_weeklyPoints + amount).clamp(0, 99999);
    });

    final newLevel = student.points ~/ 100;
    final newStage = _getDragonStage(newLevel);

    if (newStage != oldStage) {
      _showEvolutionSnackBar(student, newStage);
    }
  }

  // Obtener nombre de la fase en base a los puntos escalados
  String _getDragonStage(int pts) {
    if (pts >= 0 && pts <= 4) return 'Huevo';
    if (pts >= 5 && pts <= 8) return 'Huevo Elemental';
    if (pts >= 9 && pts <= 11) return 'Cachorro';
    return 'Dragón Alado';
  }

  // Obtener color elemental
  Color _getElementalColor(String type) {
    if (type == 'glaciar') return const Color(0xFF0288D1);
    if (type == 'lava') return const Color(0xFFE64A19);
    if (type == 'rayo') return const Color(0xFF7B1FA2);
    return const Color(0xFFD84315); // brasa / default
  }

  // Formateador de números (1240 -> 1,240)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Alerta festiva de evolución
  void _showEvolutionSnackBar(DojoStudent student, String stage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: Color(0xFFEDC620), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "¡Evolución! El dragón de ${student.name.split(' ')[0]} ahora es un $stage. 🐲✨",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D2848),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // VISTA 3: RÚBRICAS
  Widget _buildRubricasView() {
    final rubrics = _trimesterRubrics[_selectedTrimester] ?? [];

    return Column(
      children: [
        // Dropdown Trimestre
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: InkWell(
            onTap: _showTrimesterSelector,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTrimester,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                    ),
                  ),
                  const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),

        // Lista de Rúbricas
        Expanded(
          child: rubrics.isEmpty
              ? _buildRubricsEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: rubrics.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rub = rubrics[index];
                    return _buildRubricCard(rub);
                  },
                ),
        ),

        // Botón inferior "Ver todas las rúbricas"
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
          child: InkWell(
            onTap: _showAllRubricsBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Ver todas las rúbricas",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF1D2848)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Estado vacío para rúbricas
  Widget _buildRubricsEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.clipboardList, size: 36, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            Text(
              "Sin rúbricas",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No hay rúbricas registradas para el $_selectedTrimester.",
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de Rúbrica
  Widget _buildRubricCard(Map<String, dynamic> rub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: rub['bgColor'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  rub['icon'],
                  color: rub['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rub['title'],
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Criterio: ${rub['criterio']}",
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra e indicador numérico
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: rub['progress'],
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(rub['color']),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(rub['progress'] * 100).toInt()}%",
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Estado de la rúbrica
          Text(
            rub['status'],
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: rub['color'],
            ),
          ),
        ],
      ),
    );
  }

  // Selector inferior de Trimestres
  void _showTrimesterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Seleccionar Trimestre",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
              const SizedBox(height: 8),
              ...['Primer Trimestre', 'Segundo Trimestre', 'Tercer Trimestre'].map((t) {
                final isSelected = t == _selectedTrimester;
                return ListTile(
                  title: Text(
                    t,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1D2848),
                    ),
                  ),
                  trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF3B82F6), size: 18) : null,
                  onTap: () {
                    setState(() {
                      _selectedTrimester = t;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Bottom Sheet de gestión de Rúbricas reales (Mock DB)
  void _showAllRubricsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final rubricas = _db.getRubricas();
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Todas las Rúbricas",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openNewRubricaDialogFromModal(setModalState),
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: Text(
                          "Nueva Rúbrica",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D2848),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: rubricas.isEmpty
                        ? Center(
                            child: Text(
                              "No hay rúbricas registradas.",
                              style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: rubricas.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final r = rubricas[index];
                              final isLibre = r.type == "Creación Libre";
                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              r.title,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1D2848),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isLibre ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              r.type.toUpperCase(),
                                              style: GoogleFonts.outfit(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.bold,
                                                color: isLibre ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        r.description,
                                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => _evaluarRubrica(r),
                                            icon: const Icon(LucideIcons.checkSquare, size: 12),
                                            label: Text("EVALUAR", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFE8F5E9),
                                              foregroundColor: const Color(0xFF2E7D32),
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isLibre) ...[
                                            OutlinedButton.icon(
                                              onPressed: () => _editarRubricaFromModal(r, setModalState),
                                              icon: const Icon(LucideIcons.edit2, size: 12),
                                              label: Text("EDITAR", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold)),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF1D2848),
                                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                minimumSize: Size.zero,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _db.deleteRubrica(r.id);
                                              setModalState(() {});
                                              setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Rúbrica eliminada.")),
                                              );
                                            },
                                            icon: const Icon(LucideIcons.trash2, size: 12),
                                            label: Text("BORRAR", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFD32F2F),
                                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Nueva Rúbrica desde panel inferior
  void _openNewRubricaDialogFromModal(StateSetter setModalState) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'Creación Libre';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Nueva Rúbrica", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nombre de Rúbrica *", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Ej. Exposición de Trigonometría",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Tipo de Rúbrica", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Creación Libre', child: Text("Creación Libre")),
                      DropdownMenuItem(value: 'Sesión Alineada', child: Text("Sesión Alineada")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text("Descripción", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Criterios a evaluar...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("CANCELAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    _db.addRubrica(Rubrica(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: name,
                      type: selectedType,
                      description: descController.text.trim().isEmpty ? "Sin descripción" : descController.text.trim(),
                      date: "01/06/2026",
                    ));
                    Navigator.pop(context);
                    setModalState(() {});
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2848), foregroundColor: Colors.white),
                  child: Text("GUARDAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Editar Rúbrica desde panel inferior
  void _editarRubricaFromModal(Rubrica r, StateSetter setModalState) {
    final editController = TextEditingController(text: r.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Editar Rúbrica", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
          content: TextField(
            controller: editController,
            style: GoogleFonts.outfit(fontSize: 13),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCELAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = editController.text.trim();
                if (txt.isNotEmpty) {
                  _db.editRubrica(r.id, txt);
                  Navigator.pop(context);
                  setModalState(() {});
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2848), foregroundColor: Colors.white),
              child: Text("GUARDAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Evaluar Rúbrica
  void _evaluarRubrica(Rubrica r) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Competencias cargadas para '${r.title}'. Evaluando al aula."),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Pintores personalizados temáticos para las esquinas traseras de la cabecera
class PagodaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFCA5A5).withValues(alpha: 0.6)
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
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.8)
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
      ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.8)
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
    
    canvas.drawCircle(Offset(w * 0.6, h * 0.5), 6, Paint()..color = const Color(0xFFA7F3D0).withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GenericPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.8)
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
              LucideIcons.star,
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
                LucideIcons.star,
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
                LucideIcons.star,
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
                LucideIcons.star,
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
                LucideIcons.star,
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
