import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';
import 'package:app_exitus/features/classroom/presentation/screens/student_dojo_store_screen.dart';

class StudentCourseDetailsScreen extends StatefulWidget {
  final User studentUser;
  final Map<String, dynamic> course;

  const StudentCourseDetailsScreen({
    super.key,
    required this.studentUser,
    required this.course,
  });

  @override
  State<StudentCourseDetailsScreen> createState() => _StudentCourseDetailsScreenState();
}

class _StudentCourseDetailsScreenState extends State<StudentCourseDetailsScreen> with SingleTickerProviderStateMixin {
  final _db = MockDatabase();
  late TabController _tabController;
  
  bool _isLoadingContent = true;
  bool _isLoadingDojo = true;
  bool _isLoadingRubricas = true;

  late List<Map<String, dynamic>> _courseContent;
  late List<Rubrica> _courseRubricas;
  late List<DojoStudent> _allDojoStudents;
  DojoStudent? _currentDojoStudent;

  // Track expanded/collapsed states of trimesters (0 = Primer Trimestre, etc.)
  final List<bool> _trimesterExpanded = [true, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  void _loadAllData() async {
    final String courseId = widget.course['id'];
    
    // 1. Fetch content
    _courseContent = _db.getCourseContent(courseId);
    
    // 2. Fetch rubrics
    _courseRubricas = _db.getRubricasForCourse(courseId);

    // 3. Fetch Dojo board
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.courseDojo.replaceAll("{courseId}", courseId),
    );
    _allDojoStudents = _db.getDojoStudents();
    final String queryName = widget.studentUser.fullName.toLowerCase().split(' ')[0];
    try {
      _currentDojoStudent = _allDojoStudents.firstWhere(
        (s) => s.name.toLowerCase().contains(queryName),
      );
    } catch (_) {
      try {
        _currentDojoStudent = _allDojoStudents.firstWhere((s) => s.id == 34); // Default to Mateo
      } catch (_) {}
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoadingContent = false;
        _isLoadingDojo = false;
        _isLoadingRubricas = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getMascotSpeech(String courseId) {
    switch (courseId) {
      case 'c_chino':
        return "你好!\n(nǐ hǎo!)";
      case 'c_ingles':
        return "Hello!\n(həˈləʊ)";
      case 'c_algebra':
      case 'c_trigo':
        return "¡A resolver!\n(x² + y² = z²)";
      case 'c_fisica':
        return "¡E = mc²!\n(Física)";
      case 'c_literatura':
        return "¡A leer!\n(Érase una vez...)";
      case 'c_tech':
        return "println(\n\"Hello World\");";
      case 'c_tutoria':
        return "¡Hola amigo!\n¿Cómo estás?";
      default:
        return "¡Hola!\n¿Listo para aprender?";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;

    final Color themeColor = widget.course['themeColor'];
    final Color bgColor = widget.course['bgColor'];
    final String courseId = widget.course['id'];

    // Header dimensions and spacings
    final double headerHeight = screenWidth < 380 ? 150.0 : 165.0;
    final double mascotHeight = screenWidth < 380 ? 70.0 : 80.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. HEADER WITH DYNAMIC BACKGROUND
          Container(
            height: headerHeight + statusBarHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Subject themed CustomPainter
                Positioned.fill(
                  child: CustomPaint(
                    painter: CourseBackgroundPainter(
                      courseId: courseId,
                      themeColor: themeColor,
                    ),
                  ),
                ),
                
                // Back Button
                Positioned(
                  top: statusBarHeight + 10,
                  left: 16,
                  child: GestureDetector(
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
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Course Info, Mascot, and Speech Bubble (Aligned in one Row)
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Vertically align all items
                    children: [
                      // Course details & Teacher
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Course Icon representation (Bubble style matching the image)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: themeColor.withOpacity(0.2), width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: _buildHeaderIconWidget(courseId, themeColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.course['title'],
                                        style: GoogleFonts.outfit(
                                          fontSize: screenWidth < 380 ? 18.0 : 21.0,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1D2848),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: themeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          widget.course['tag'],
                                          style: GoogleFonts.outfit(
                                            color: themeColor,
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Teacher Details row
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(widget.course['avatar']),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Docente",
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        widget.course['teacher'],
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF1D2848),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dialogue bubble + Mascot Fox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Speech bubble
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFF4D2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getMascotSpeech(courseId),
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF1D2848),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Triangle pointing to the fox (Right)
                              Positioned(
                                right: -6,
                                top: 10,
                                child: CustomPaint(
                                  painter: RightBubbleTrianglePainter(),
                                  size: const Size(6, 8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          // Mascot Fox
                          Image.asset(
                            'assets/images/mascot_horario.png',
                            height: mascotHeight,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. TAB BAR (Softly divided with bottom shadow and transparent divider)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent, // Remove standard thick divider line
              indicatorColor: const Color(0xFFF9C824),
              indicatorWeight: 3.0,
              labelColor: const Color(0xFF1D2848),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13.5),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bookOpen, size: 16),
                      SizedBox(width: 6),
                      Text("Contenido"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.cat, size: 16),
                      SizedBox(width: 6),
                      Text("Dojo"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.clipboardList, size: 16),
                      SizedBox(width: 6),
                      Text("Rúbrica"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContenidoTab(),
                _buildDojoTab(),
                _buildRubricaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconWidget(String courseId, Color themeColor) {
    if (courseId == 'c_chino') {
      return Text(
        "文",
        style: GoogleFonts.outfit(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (courseId == 'c_ingles') {
      return Text(
        "EN",
        style: GoogleFonts.outfit(color: themeColor, fontSize: 16, fontWeight: FontWeight.w900),
      );
    } else if (courseId == 'c_algebra' || courseId == 'c_trigo') {
      return Text(
        "∑",
        style: GoogleFonts.outfit(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (courseId == 'c_fisica') {
      return Icon(LucideIcons.flaskConical, color: themeColor, size: 20);
    } else if (courseId == 'c_literatura') {
      return Icon(LucideIcons.feather, color: themeColor, size: 20);
    } else if (courseId == 'c_tech') {
      return Icon(LucideIcons.code2, color: themeColor, size: 20);
    } else {
      return Icon(LucideIcons.heart, color: themeColor, size: 20);
    }
  }

  // --- TAB 1: CONTENIDO ---
  Widget _buildContenidoTab() {
    if (_isLoadingContent) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: _courseContent.length,
      itemBuilder: (context, index) {
        final trimester = _courseContent[index];
        final bool isExpanded = _trimesterExpanded[index];
        final bool isCurrent = trimester['status'] == 'En curso';

        return Column(
          children: [
            // Trimester Header Card
            GestureDetector(
              onTap: () {
                if (isCurrent) {
                  setState(() {
                    _trimesterExpanded[index] = !_trimesterExpanded[index];
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("El ${trimester['title']} estará disponible a partir del ${trimester['date'].split(' - ')[0]}."),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isExpanded && isCurrent ? widget.course['themeColor'].withOpacity(0.3) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Expand/Collapse Icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? (isExpanded ? widget.course['themeColor'].withOpacity(0.12) : const Color(0xFFF1F5F9))
                            : const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrent 
                            ? (isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight)
                            : LucideIcons.chevronRight,
                        color: isCurrent ? widget.course['themeColor'] : const Color(0xFF94A3B8),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and date range
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trimester['title'],
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: isCurrent ? const Color(0xFF1D2848) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 10, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                trimester['date'],
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFFFCE4EC) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trimester['status'],
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFEC407A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expandable List of Lessons
            if (isExpanded && isCurrent)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trimester['items'].length,
                    separatorBuilder: (context, idx) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, lessonIdx) {
                      final item = trimester['items'][lessonIdx];
                      return ListTile(
                        onTap: () => _openLessonItem(item),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: _buildLessonIcon(item['type']),
                        title: Text(
                          item['title'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getLessonTypeColor(item['type']).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['type'].toString().toUpperCase(),
                                  style: TextStyle(
                                    color: _getLessonTypeColor(item['type']),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['info'],
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF1E88E5)),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _getLessonTypeColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFEC407A); // Red/Pink
      case 'docx':
        return const Color(0xFF43A047); // Green
      case 'video':
        return const Color(0xFFE53935); // Play Red
      case 'link':
      default:
        return const Color(0xFFFFB300); // Yellow/Orange
    }
  }

  Widget _buildLessonIcon(String type) {
    final Color color = _getLessonTypeColor(type);
    
    if (type == 'pdf' || type == 'docx') {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileText, color: color, size: 14),
            Text(
              type.toUpperCase(),
              style: TextStyle(color: color, fontSize: 6.5, fontWeight: FontWeight.w900, height: 1.1),
            ),
          ],
        ),
      );
    } else if (type == 'video') {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.playCircle, color: color, size: 18),
      );
    } else {
      // link
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.globe, color: color, size: 16),
      );
    }
  }

  void _openLessonItem(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              item['type'] == 'video' ? LucideIcons.youtube : LucideIcons.externalLink,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Abriendo ${item['title']} (${item['info']})...",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- TAB 2: DOJO ---
  Widget _buildDojoTab() {
    if (_isLoadingDojo || _currentDojoStudent == null) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848))),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Upper row section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Card: Tu Dragoncito
            Expanded(
              flex: 6,
              child: Container(
                height: 275, // fixed height to align with the column on the right
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCE4EC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Color(0xFFEC407A),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Tu Dragoncito",
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Name
                    Text(
                      "Longbao",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // CustomPaint Dragon (Lava, puppy)
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: DragonWidget(
                          dragonType: 'lava',
                          points: 9,
                          size: 90,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nivel 8",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 13,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 6,
                        color: const Color(0xFFECEFF1),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 1240.0 / 1800.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFBC02D), Color(0xFFF57F17)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "1,240 / 1,800 XP",
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "¡Sigue así, vas por buen camino!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Column: Billetera Dojo & Racha actual
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 275, // same height
                child: Column(
                  children: [
                    // Top: Billetera Dojo
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF8E1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.stars,
                                    color: Color(0xFFFFB300),
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Billetera Dojo",
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1D2848),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Balance
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "4,850",
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1D2848),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.stars,
                                  color: Color(0xFFFFB300),
                                  size: 18,
                                ),
                              ],
                            ),
                            Text(
                              "puntos disponibles",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            // Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDojoStoreScreen(
                                      studentUser: widget.studentUser,
                                      currentPoints: 4850,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBE7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFFECB3), width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Color(0xFFD84315),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Ir a Tienda Dojo",
                                        style: GoogleFonts.outfit(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFD84315),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFFD84315),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom: Racha actual
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.whatshot,
                                        color: Color(0xFFEC407A),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "Racha actual",
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFEC407A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "7 días",
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFEC407A),
                                    ),
                                  ),
                                  Text(
                                    "¡Increíble!",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Calendar Checkmark Widget
                            Container(
                              width: 42,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF8BBD0), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF8BBD0).withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8BBD0),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Color(0xFFEC407A),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Historial de puntos Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: Color(0xFFEC407A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Historial de puntos",
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mostrando historial completo..."),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      "Ver todo",
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildHistoryItem(
                icon: Icons.people_outline,
                iconColor: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFE8F5E9),
                title: "Participación en clase",
                subtitle: "Participaste activamente en la discusión",
                points: "+50",
                date: "08 May",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildHistoryItem(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF7B1FA2),
                bgColor: const Color(0xFFF3E5F5),
                title: "Entrega de tarea",
                subtitle: "Entrega: Ejercicios de pinyin",
                points: "+100",
                date: "07 May",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildHistoryItem(
                icon: Icons.star_outline,
                iconColor: const Color(0xFFF57F17),
                bgColor: const Color(0xFFFFF8E1),
                title: "Trabajo destacado",
                subtitle: "Excelente trabajo en pronunciación",
                points: "+150",
                date: "06 May",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildHistoryItem(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF1565C0),
                bgColor: const Color(0xFFE3F2FD),
                title: "Trabajo en equipo",
                subtitle: "Actividad grupal: Diálogos",
                points: "+80",
                date: "05 May",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildHistoryItem(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF00796B),
                bgColor: const Color(0xFFE0F2F1),
                title: "Asistencia",
                subtitle: "Asistencia perfecta",
                points: "+20",
                date: "05 May",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String points,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  fontSize: 9.5,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDojoStoreDialog(BuildContext context) {
    int currentWalletPoints = 4850;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tienda Dojo Exitus",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),
                    // Points balance indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDE7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFF59D)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tus puntos disponibles:",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D2848)),
                          ),
                          Row(
                            children: [
                              Text(
                                "$currentWalletPoints",
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFEF6C00)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.stars, color: Color(0xFFFBC02D), size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Store Items List (Scrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildStoreItem(
                              name: "Estuchera Exitus",
                              description: "Estuchera oficial de tela con logo",
                              points: 1500,
                              icon: Icons.edit_note,
                              iconColor: const Color(0xFFE57373),
                              bgColor: const Color(0xFFFFEBEE),
                              currentPoints: currentWalletPoints,
                              onRedeem: () {
                                setDialogState(() {
                                  currentWalletPoints -= 1500;
                                });
                                _showRedeemSuccess(context, "Estuchera Exitus");
                              },
                            ),
                            _buildStoreItem(
                              name: "Lapicero Metálico",
                              description: "Lapicero premium grabado con tu nombre",
                              points: 500,
                              icon: Icons.border_color,
                              iconColor: const Color(0xFF64B5F6),
                              bgColor: const Color(0xFFE3F2FD),
                              currentPoints: currentWalletPoints,
                              onRedeem: () {
                                setDialogState(() {
                                  currentWalletPoints -= 500;
                                });
                                _showRedeemSuccess(context, "Lapicero Metálico");
                              },
                            ),
                            _buildStoreItem(
                              name: "Skin Dragón Dorado",
                              description: "Aspecto especial dorado para tu dragón",
                              points: 3000,
                              icon: Icons.auto_awesome,
                              iconColor: const Color(0xFFFFD54F),
                              bgColor: const Color(0xFFFFF8E1),
                              currentPoints: currentWalletPoints,
                              onRedeem: () {
                                setDialogState(() {
                                  currentWalletPoints -= 3000;
                                });
                                _showRedeemSuccess(context, "Skin Dragón Dorado");
                              },
                            ),
                            _buildStoreItem(
                              name: "Cuaderno Exitus Deluxe",
                              description: "Cuaderno de apuntes anillado A4",
                              points: 2000,
                              icon: Icons.book,
                              iconColor: const Color(0xFF81C784),
                              bgColor: const Color(0xFFE8F5E9),
                              currentPoints: currentWalletPoints,
                              onRedeem: () {
                                setDialogState(() {
                                  currentWalletPoints -= 2000;
                                });
                                _showRedeemSuccess(context, "Cuaderno Exitus Deluxe");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStoreItem({
    required String name,
    required String description,
    required int points,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required int currentPoints,
    required VoidCallback onRedeem,
  }) {
    final bool canAfford = currentPoints >= points;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "$points",
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF6C00)),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.stars, color: Color(0xFFFBC02D), size: 12),
                      const SizedBox(width: 4),
                      Text("puntos", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: canAfford ? onRedeem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 0,
              ),
              child: Text(
                "Canjear",
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemSuccess(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                "¡Canje Exitoso!",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
              ),
              const SizedBox(height: 8),
              Text(
                "Has canjeado el producto '$itemName'. Acércate a la oficina de Dojo con tu código QR para recogerlo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2848),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: Text(
                  "Aceptar",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: RÚBRICA ---
  Widget _buildRubricaTab() {
    if (_isLoadingRubricas) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848))),
      );
    }

    if (_courseRubricas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.fileQuestion, size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              "No hay rúbricas registradas para este curso.",
              style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _courseRubricas.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _courseRubricas[index];
        final bool isLibre = r.type == "Creación Libre";

        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            onTap: () => _showRubricDetailsDialog(r),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                            fontSize: 13.5,
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
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isLibre ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.description,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 10, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            "Creado el: ${r.date}",
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text("Ver detalles", style: TextStyle(fontSize: 10.5, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                          SizedBox(width: 2),
                          Icon(LucideIcons.chevronRight, size: 12, color: Color(0xFF1E88E5)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRubricDetailsDialog(Rubrica r) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(LucideIcons.fileSpreadsheet, color: widget.course['themeColor'], size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Evaluación por Competencias",
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: widget.course['themeColor']),
              ),
              const SizedBox(height: 12),
              const Text(
                "Criterios de Evaluación:",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
              ),
              const SizedBox(height: 8),
              _buildCriteriaRow("Competencia 1: Capacidad Técnica / Teórica", "LOGRADO (A)", Colors.green),
              const SizedBox(height: 6),
              _buildCriteriaRow("Competencia 2: Fluidez y Claridad", "DESTACADO (AD)", Colors.blue),
              const SizedBox(height: 6),
              _buildCriteriaRow("Competencia 3: Presentación / Tareas", "LOGRADO (A)", Colors.green),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Estado de Calificación:", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("PROCESADO", style: TextStyle(fontSize: 8.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ENTENDIDO"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCriteriaRow(String name, String grade, Color gradeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            grade,
            style: GoogleFonts.outfit(fontSize: 10, color: gradeColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Background custom painter to draw specific subject pattern shapes
class CourseBackgroundPainter extends CustomPainter {
  final String courseId;
  final Color themeColor;

  CourseBackgroundPainter({required this.courseId, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = themeColor.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    if (courseId == 'c_chino') {
      // Soft hills
      final path = Path()
        ..moveTo(0, size.height * 0.85)
        ..cubicTo(size.width * 0.3, size.height * 0.65, size.width * 0.7, size.height * 0.95, size.width, size.height * 0.8)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, fillPaint);
      
      // Sun
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 28, Paint()..color = themeColor.withOpacity(0.08)..style = PaintingStyle.fill);

      // Cherry blossoms branches
      final branch = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width * 0.75, size.height * 0.25);
      canvas.drawPath(branch, paint..strokeWidth = 1.5);
      
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 4, Paint()..color = const Color(0xFFEC407A).withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width * 0.79, size.height * 0.18), 3, Paint()..color = const Color(0xFFEC407A).withOpacity(0.3)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.14), 5, Paint()..color = const Color(0xFFEC407A).withOpacity(0.35)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.08), 4, Paint()..color = const Color(0xFFEC407A).withOpacity(0.45)..style = PaintingStyle.fill);

    } else if (courseId == 'c_ingles') {
      // Landmarks & clock outlines
      final skyline = Path()
        ..moveTo(0, size.height)
        ..lineTo(0, size.height * 0.75)
        ..lineTo(15, size.height * 0.75)
        ..lineTo(15, size.height * 0.55)
        ..lineTo(25, size.height * 0.45)
        ..lineTo(35, size.height * 0.55)
        ..lineTo(35, size.height * 0.75)
        ..lineTo(55, size.height * 0.75)
        ..lineTo(55, size.height * 0.9);
      canvas.drawPath(skyline, paint..strokeWidth = 1.2);
      
      // London Eye
      final Offset wheelCenter = Offset(size.width * 0.78, size.height * 0.55);
      canvas.drawCircle(wheelCenter, 22, Paint()..color = themeColor.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawCircle(wheelCenter, 2, Paint()..color = themeColor.withOpacity(0.12)..style = PaintingStyle.fill);
      
      for (int i = 0; i < 8; i++) {
        final double angle = (i * math.pi) / 4;
        canvas.drawLine(
          wheelCenter,
          Offset(wheelCenter.dx + 22 * math.cos(angle), wheelCenter.dy + 22 * math.sin(angle)),
          Paint()..color = themeColor.withOpacity(0.04)..strokeWidth = 1
        );
      }

    } else if (courseId == 'c_algebra' || courseId == 'c_trigo') {
      // Grid paper + sine wave
      const double spacing = 14.0;
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = themeColor.withOpacity(0.045)..strokeWidth = 0.5);
      }
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()..color = themeColor.withOpacity(0.045)..strokeWidth = 0.5);
      }
      
      // Axes
      canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), Paint()..color = themeColor.withOpacity(0.15)..strokeWidth = 1.5);
      canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), Paint()..color = themeColor.withOpacity(0.15)..strokeWidth = 1.5);

      // Sine Wave
      final wavePath = Path();
      for (double x = 0; x < size.width; x++) {
        final double y = size.height * 0.75 + 20 * math.sin((x - size.width * 0.3) * 0.035);
        if (x == 0) {
          wavePath.moveTo(x, y);
        } else {
          wavePath.lineTo(x, y);
        }
      }
      canvas.drawPath(wavePath, Paint()..color = themeColor.withOpacity(0.22)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    } else if (courseId == 'c_fisica') {
      // Atom orbits
      final Offset center = Offset(size.width * 0.8, size.height * 0.5);
      canvas.drawCircle(center, 5, Paint()..color = themeColor.withOpacity(0.22)..style = PaintingStyle.fill);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      
      final orbitPaint = Paint()
        ..color = themeColor.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      for (int i = 0; i < 3; i++) {
        canvas.save();
        canvas.rotate((i * math.pi) / 3);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 55, height: 16), orbitPaint);
        canvas.drawCircle(const Offset(27, 0), 2.5, Paint()..color = themeColor.withOpacity(0.3)..style = PaintingStyle.fill);
        canvas.restore();
      }
      canvas.restore();
      
      // Particle/Flask float
      canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.35), 12, Paint()..color = themeColor.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.35), 2, Paint()..color = themeColor.withOpacity(0.08)..style = PaintingStyle.fill);

    } else if (courseId == 'c_literatura') {
      // Opened book silhouette
      final Offset bookCenter = Offset(size.width * 0.8, size.height * 0.55);
      final bookPath = Path()
        ..moveTo(bookCenter.dx, bookCenter.dy + 12)
        ..quadraticBezierTo(bookCenter.dx - 12, bookCenter.dy - 4, bookCenter.dx - 25, bookCenter.dy)
        ..lineTo(bookCenter.dx - 25, bookCenter.dy - 12)
        ..quadraticBezierTo(bookCenter.dx - 12, bookCenter.dy - 16, bookCenter.dx, bookCenter.dy - 4)
        ..quadraticBezierTo(bookCenter.dx + 12, bookCenter.dy - 16, bookCenter.dx + 25, bookCenter.dy - 12)
        ..lineTo(bookCenter.dx + 25, bookCenter.dy)
        ..quadraticBezierTo(bookCenter.dx + 12, bookCenter.dy - 4, bookCenter.dx, bookCenter.dy + 12)
        ..close();
      canvas.drawPath(bookPath, fillPaint);
      canvas.drawPath(bookPath, paint..strokeWidth = 1.0);
      
      canvas.drawLine(Offset(bookCenter.dx, bookCenter.dy - 4), Offset(bookCenter.dx, bookCenter.dy + 12), Paint()..color = themeColor.withOpacity(0.18)..strokeWidth = 1.5);

      final quill = Path()
        ..moveTo(bookCenter.dx + 4, bookCenter.dy - 8)
        ..quadraticBezierTo(bookCenter.dx + 20, bookCenter.dy - 30, bookCenter.dx + 28, bookCenter.dy - 42);
      canvas.drawPath(quill, paint..strokeWidth = 1.2);

    } else if (courseId == 'c_tech') {
      // Circuit links
      final trace = Path()
        ..moveTo(0, size.height * 0.45)
        ..lineTo(size.width * 0.28, size.height * 0.45)
        ..lineTo(size.width * 0.42, size.height * 0.72)
        ..lineTo(size.width * 0.78, size.height * 0.72);
      
      canvas.drawPath(trace, paint..strokeWidth = 1.2);
      canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.72), 3.5, Paint()..color = themeColor.withOpacity(0.2)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.72), 4.5, Paint()..color = themeColor.withOpacity(0.35)..style = PaintingStyle.fill);

    } else {
      // c_tutoria / generic: Hearts
      final heartPath = Path()
        ..moveTo(size.width * 0.78, size.height * 0.5)
        ..cubicTo(size.width * 0.75, size.height * 0.4, size.width * 0.68, size.height * 0.43, size.width * 0.68, size.height * 0.52)
        ..cubicTo(size.width * 0.68, size.height * 0.62, size.width * 0.78, size.height * 0.71, size.width * 0.78, size.height * 0.73)
        ..cubicTo(size.width * 0.78, size.height * 0.73, size.width * 0.88, size.height * 0.62, size.width * 0.88, size.height * 0.52)
        ..cubicTo(size.width * 0.88, size.height * 0.43, size.width * 0.81, size.height * 0.4, size.width * 0.78, size.height * 0.5)
        ..close();
      canvas.drawPath(heartPath, fillPaint);
      canvas.drawPath(heartPath, paint..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RightBubbleTrianglePainter extends CustomPainter {
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
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
    
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(0, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
