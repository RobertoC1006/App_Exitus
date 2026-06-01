import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/inner_classroom_drawer.dart';

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
  final List<LinearGradient> _courseGradients = const [
    LinearGradient(
      colors: [Color(0xFFFF7043), Color(0xFFFFA726)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFAB47BC), Color(0xFFEC407A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF9CCC65)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  void _openCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: InnerClassroomDrawer(
            course: course,
            isTeacher: true,
            currentUser: widget.teacherUser,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

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
          // 1. Cabecera Banner
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
                Positioned(
                  top: statusBarHeight + (screenWidth < 380 ? 8 : 12),
                  left: 16,
                  right: 16,
                  child: Row(
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
                          child: Icon(
                            LucideIcons.arrowLeft,
                            color: const Color(0xFF1D2848),
                            size: screenWidth < 380 ? 16 : 18,
                          ),
                        ),
                      ),
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
                      SizedBox(width: screenWidth < 380 ? 32 : 36),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: mascotLeftMargin,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/mascota_cursos2.png',
                        height: mascotHeight,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 0),
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
                                    "¿Qué curso\nquieres gestionar hoy?",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1D2848),
                                      fontSize: speechFontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -6,
                                  top: 10,
                                  child: CustomPaint(
                                    painter: BubbleTrianglePainter2(),
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

          // 2. Lista de Cursos del Docente
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = widget.courses[index];
                  return _buildCourseCard(course, index);
                },
                childCount: widget.courses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final gradient = _courseGradients[index % _courseGradients.length];
    String sectionBadge = "${course['levelNum']} ${course['room'].replaceAll('Aula ', '')} - SEC";
    String areaTag = course['title'].contains('Matemática') || course['title'].contains('Cálculo')
        ? 'CIENCIAS EXACTAS y MATEMÁTICA'
        : 'EDUCACIÓN PARA EL TRABAJO';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openCourseDetails(course),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: gradient,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                sectionBadge.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1D2848),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          course['title'],
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          areaTag,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(
                                  course['room'],
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Ver Aula Virtual",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF1D2848),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.arrowRight,
                                  color: Color(0xFF1D2848),
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BubbleTrianglePainter2 extends CustomPainter {
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
