import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/features/classroom/presentation/screens/teacher_course_details_screen.dart';

class TeacherCoursesScreen extends ConsumerStatefulWidget {
  final User teacherUser;
  final List<Map<String, dynamic>> courses;

  const TeacherCoursesScreen({
    super.key,
    required this.teacherUser,
    required this.courses,
  });

  @override
  ConsumerState<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends ConsumerState<TeacherCoursesScreen> {
  // Lista exacta de cursos del docente según el mockup
  final List<Map<String, dynamic>> _mockedCourses = [
    {
      'id': 'c_tutoria',
      'title': 'Tutoría',
      'category': 'Tutoría',
      'level': 'Primaria',
      'levelNum': '5° A',
      'iconType': 'tutoria',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'c_chino',
      'title': 'Chino Mandarín',
      'category': 'Idiomas',
      'level': 'Secundaria',
      'levelNum': '1° A',
      'iconType': 'china_flag',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'c_chino',
      'title': 'Chino Mandarín',
      'category': 'Idiomas',
      'level': 'Secundaria',
      'levelNum': '1° B',
      'iconType': 'china_flag',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'c_chino',
      'title': 'Chino Mandarín',
      'category': 'Idiomas',
      'level': 'Secundaria',
      'levelNum': '2° A',
      'iconType': 'china_flag',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'c_chino',
      'title': 'Chino Mandarín',
      'category': 'Idiomas',
      'level': 'Secundaria',
      'levelNum': '3° A',
      'iconType': 'china_flag',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'c_fisica',
      'title': 'Ciencia y Tecnología',
      'category': 'Ciencias',
      'level': 'Secundaria',
      'levelNum': '4° B',
      'iconType': 'ciencia',
      'color': const Color(0xFF10B981),
    },
  ];

  void _openCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherCourseDetailsScreen(
          course: course,
          teacherUser: widget.teacherUser,
        ),
      ),
    ).then((value) {
      if (value != null && mounted) {
        Navigator.pop(context, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Ajuste de altura del banner para acomodar el avatar flotante
    final double headerHeight = screenWidth < 380 ? 170.0 : 190.0;
    
    // Mapear los datos simulados con los parámetros que espera el InnerClassroomDrawer
    final List<Map<String, dynamic>> coursesToUse = _mockedCourses.map((c) {
      return {
        'id': c['id'],
        'title': c['title'],
        'level': c['level'] ?? 'Secundaria',
        'levelNum': c['levelNum'],
        'room': 'Aula ${c['levelNum']}',
        'teacher': widget.teacherUser.fullName,
        'avatar': widget.teacherUser.avatarUrl,
        'iconType': c['iconType'],
        'color': c['color'],
        'category': c['category'],
      };
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Cabecera Banner con botón Atrás, Campana, Título/Subtítulo y Avatar Flotante
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Fondo decorativo suave
                Container(
                  height: headerHeight + statusBarHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
                // Botones superiores: Atrás y Campana de Notificación
                Positioned(
                  top: statusBarHeight + 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Atrás circular con sombra
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
                      // Botón Campana con punto rojo de notificación
                      GestureDetector(
                        onTap: () {},
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
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                LucideIcons.bell,
                                color: Color(0xFF1D2848),
                                size: 18,
                              ),
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Título y Subtítulo a la izquierda
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 150, // Deja espacio para el avatar flotante
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mis Cursos",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1D2848),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Aulas que tienes a tu cargo",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar del profesor flotante en la esquina superior derecha
                Positioned(
                  right: 10,
                  bottom: -15, // Sobresale ligeramente hacia abajo en el grid
                  child: Image.asset(
                    'assets/images/profesor_avatar.png',
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 130,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(Icons.person, size: 70, color: Colors.blueGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Espaciador entre el banner y el grid para compensar el avatar sobresaliente
          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),

          // 2. Grid de Cursos (2 Columnas)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = coursesToUse[index];
                  return _buildCourseCard(course);
                },
                childCount: coursesToUse.length,
              ),
            ),
          ),
          // Espacio extra al final para evitar que el bottom bar oculte tarjetas
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      
      // 3. Barra de navegación inferior que replica el estilo del Dashboard principal
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

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _openCourseDetails(course),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del curso (Tutoría, Bandera China o Beaker de Ciencia)
                _buildCourseIcon(course['iconType']),
                const SizedBox(height: 5),
                
                // Nombre del curso (Negrita)
                Text(
                  course['title'],
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                
                // Categoría/Área
                Text(
                  course['category'],
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                // Grado y Sección (Ej: 1° A • Secundaria)
                Text(
                  "${course['levelNum']} • ${course['level']}",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                
                // Botón "Ver Aula" estilizado
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ver Aula",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1D2848),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        LucideIcons.arrowRight,
                        color: Color(0xFF3B82F6),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseIcon(String type) {
    const double size = 28;
    if (type == 'china_flag') {
      return const ChinaFlagCircle(size: size);
    } else if (type == 'tutoria') {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFFEF3C7),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.users,
          color: Color(0xFFD97706),
          size: 18,
        ),
      );
    } else {
      // Ciencia y tecnología
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFD1FAE5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.flaskConical,
          color: Color(0xFF059669),
          size: 18,
        ),
      );
    }
  }
}

// Widget personalizado de la bandera de China en forma circular
class ChinaFlagCircle extends StatelessWidget {
  final double size;
  const ChinaFlagCircle({super.key, this.size = 36});

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
          // Estrella grande
          Positioned(
            left: size * 0.22,
            top: size * 0.22,
            child: Icon(
              Icons.star,
              color: const Color(0xFFFFDE00),
              size: size * 0.35,
            ),
          ),
          // Estrellitas pequeñas en arco
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
