import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';
import 'package:app_exitus/features/classroom/presentation/screens/student_course_details_screen.dart';

class StudentCoursesScreen extends ConsumerStatefulWidget {
  final User studentUser;
  final List<Map<String, dynamic>> initialCourses;

  const StudentCoursesScreen({
    super.key,
    required this.studentUser,
    required this.initialCourses,
  });

  @override
  ConsumerState<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends ConsumerState<StudentCoursesScreen> {
  bool _isLoading = true;
  late List<Map<String, dynamic>> _courses;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() async {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.coursesList,
      queryParameters: {"student_id": widget.studentUser.id},
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _courses = [
          {
            'id': 'c_algebra',
            'title': 'Álgebra',
            'tag': 'Matemática',
            'teacher': 'Ana Torres',
            'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
            'themeColor': const Color(0xFFFFB300), // Yellow/Orange
            'bgColor': const Color(0xFFFFF9E6),
            'shape': 'hexagon',
            'icon': LucideIcons.compass,
          },
          {
            'id': 'c_ingles',
            'title': 'Inglés',
            'tag': 'Idiomas',
            'teacher': 'Rosa Méndez',
            'avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100',
            'themeColor': const Color(0xFF1E88E5), // Blue
            'bgColor': const Color(0xFFE3F2FD),
            'shape': 'speech_en',
            'icon': LucideIcons.messageSquare,
          },
          {
            'id': 'c_fisica',
            'title': 'Física',
            'tag': 'Ciencia',
            'teacher': 'Luis Ramírez',
            'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
            'themeColor': const Color(0xFF7E57C2), // Purple
            'bgColor': const Color(0xFFEDE7F6),
            'shape': 'circle_flask',
            'icon': LucideIcons.flaskConical,
          },
          {
            'id': 'c_chino',
            'title': 'Chino Mandarín',
            'tag': 'Idiomas',
            'teacher': 'Mei Lin',
            'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
            'themeColor': const Color(0xFFEC407A), // Pink
            'bgColor': const Color(0xFFFCE4EC),
            'shape': 'speech_cn',
            'icon': LucideIcons.languages,
          },
          {
            'id': 'c_literatura',
            'title': 'Literatura',
            'tag': 'Comunicación',
            'teacher': 'María López',
            'avatar': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100',
            'themeColor': const Color(0xFF43A047), // Green
            'bgColor': const Color(0xFFE8F5E9),
            'shape': 'speech_book',
            'icon': LucideIcons.bookOpen,
          },
          {
            'id': 'c_tech',
            'title': 'Tech Savvy',
            'tag': 'Tecnología',
            'teacher': 'Carlos Vega',
            'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
            'themeColor': const Color(0xFF009688), // Teal
            'bgColor': const Color(0xFFE0F2F1),
            'shape': 'hexagon_laptop',
            'icon': LucideIcons.laptop,
          },
          {
            'id': 'c_trigo',
            'title': 'Trigonometría',
            'tag': 'Matemática',
            'teacher': 'Paula Gómez',
            'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
            'themeColor': const Color(0xFFF4511E), // Deep Orange
            'bgColor': const Color(0xFFFBE9E7),
            'shape': 'triangle',
            'icon': LucideIcons.ruler,
          },
          {
            'id': 'c_tutoria',
            'title': 'Tutoría',
            'tag': 'Formación',
            'teacher': 'Javier Salazar',
            'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100',
            'themeColor': const Color(0xFF3F51B5), // Indigo
            'bgColor': const Color(0xFFE8EAF6),
            'shape': 'circle_users',
            'icon': LucideIcons.users,
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _openCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentCourseDetailsScreen(
          studentUser: widget.studentUser,
          course: course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive measurements to prevent overlaps on small devices
    final double headerHeight = screenWidth < 380 ? 160.0 : 175.0;
    final double mascotHeight = screenWidth < 380 ? 110.0 : (screenWidth < 415 ? 125.0 : 145.0);
    final double mascotLeftMargin = screenWidth < 380 ? 40.0 : (screenWidth < 415 ? 60.0 : 80.0);
    final double titleFontSize = screenWidth < 380 ? 20.0 : 23.0;
    final double speechFontSize = screenWidth < 380 ? 10.0 : 11.0;
    final double logoHeight = screenWidth < 380 ? 26.0 : 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Cabecera desplazable (No fija y con elementos perfectamente alineados)
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: headerHeight + statusBarHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/courses_background.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Container(
                  height: headerHeight + statusBarHeight,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.55),
                ),
                // Botón de Volver y Logo Centrado arriba
                Positioned(
                  top: statusBarHeight + (screenWidth < 380 ? 8 : 12),
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Atrás
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
                          child: Icon(
                            LucideIcons.arrowLeft,
                            color: const Color(0xFF1D2848),
                            size: screenWidth < 380 ? 16 : 18,
                          ),
                        ),
                      ),
                      // Logo Éxitus Colegio Centrado
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/school_logo.png',
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "EXITUS",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1D2848),
                                  fontSize: screenWidth < 380 ? 14 : 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                "COLEGIO",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFE5A93B),
                                  fontSize: screenWidth < 380 ? 7 : 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Compensación del botón atrás
                      SizedBox(width: screenWidth < 380 ? 32 : 36),
                    ],
                  ),
                ),
                // Mascota, Título y Globo de Diálogo (Alineación vertical perfecta)
                Positioned(
                  bottom: 4,
                  left: mascotLeftMargin,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Mascota Robot
                      Image.asset(
                        'assets/images/mascota_cursos2.png',
                        height: mascotHeight,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 0),
                      // Título y Globo a la derecha de la mascota
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Mis Cursos",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1D2848),
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Globo de Diálogo con punta a la altura de la cara
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth < 380 ? 10 : 12,
                                    vertical: screenWidth < 380 ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9E6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFF4D2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "¿Qué curso\nquieres revisar hoy?",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1D2848),
                                      fontSize: speechFontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                // Triángulo apuntando a la mascota
                                Positioned(
                                  left: -6,
                                  top: 10, // Alinedo con la cara/pantalla del robot
                                  child: CustomPaint(
                                    painter: BubbleTrianglePainter(),
                                    size: const Size(6, 8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Grid de Cursos
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848)),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.08,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildCourseCard(_courses[index]);
                      },
                      childCount: _courses.length,
                    ),
                  ),
                ),
        ],
      ),
      // 3. Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 16,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, LucideIcons.home, "Inicio"),
              _buildBottomNavItem(1, LucideIcons.megaphone, "Avisos"),
              GestureDetector(
                onTap: () => Navigator.pop(context, 99),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9C824),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
                ),
              ),
              _buildBottomNavItem(2, LucideIcons.briefcase, "Tareas"),
              _buildBottomNavItem(3, LucideIcons.user, "Perfil"),
            ],
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
    final Color themeColor = course['themeColor'];
    final Color bgColor = course['bgColor'];

    return GestureDetector(
      onTap: () => _openCourseDetails(course),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(color: themeColor),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCourseIcon(course['shape'], themeColor, bgColor, course['icon']),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course['title'],
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D2848),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  course['tag'],
                                  style: GoogleFonts.outfit(
                                    color: themeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(course['avatar']),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Docente",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                course['teacher'],
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1D2848),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ver Aula",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1D2848),
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          LucideIcons.arrowRight,
                          color: Color(0xFF1D2848),
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseIcon(String shape, Color themeColor, Color bgColor, IconData iconData) {
    const double size = 36;

    if (shape == 'hexagon' || shape == 'hexagon_laptop') {
      return ClipPath(
        clipper: HexagonClipper(),
        child: Container(
          width: size,
          height: size,
          color: themeColor,
          alignment: Alignment.center,
          child: Icon(
            iconData == LucideIcons.compass ? LucideIcons.ruler : iconData,
            color: Colors.white,
            size: 16,
          ),
        ),
      );
    } else if (shape == 'speech_en') {
      return Container(
        width: size + 2,
        height: size,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          "EN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    } else if (shape == 'speech_cn') {
      return Container(
        width: size + 2,
        height: size,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          "文",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else if (shape == 'speech_book') {
      return Container(
        width: size + 2,
        height: size,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          iconData,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (shape == 'triangle') {
      return ClipPath(
        clipper: TriangleClipper(),
        child: Container(
          width: size,
          height: size,
          color: themeColor,
          alignment: Alignment.center,
          child: const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(
              LucideIcons.ruler,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: themeColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          iconData,
          color: Colors.white,
          size: 16,
        ),
      );
    }
  }
}

class BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF9E6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFF4D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    final borderPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
