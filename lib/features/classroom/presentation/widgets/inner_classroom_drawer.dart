import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';
import 'package:app_exitus/core/services/audio_service.dart';

class InnerClassroomDrawer extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool isTeacher;
  final User? currentUser;

  const InnerClassroomDrawer({
    super.key,
    required this.course,
    required this.isTeacher,
    this.currentUser,
  });

  @override
  State<InnerClassroomDrawer> createState() => _InnerClassroomDrawerState();
}

class _InnerClassroomDrawerState extends State<InnerClassroomDrawer> {
  final MockDatabase _db = MockDatabase();
  final AudioService _audioService = AudioService();

  int _activeTab = 0;

  // Estados del Acordeón de Trimestres
  final List<bool> _isTrimestreExpanded = [true, false, false];

  // Estados de los filtros de Dojo
  final String _dojoDate = "2026-05-27";
  bool _dojoOnlyPresent = false;
  String _dojoSearchQuery = "";
  late List<DojoStudent> _allDojoStudents;

  // Estados del sorteo (roulette)
  bool _isSorteoRunning = false;
  int? _highlightedStudentId;

  @override
  void initState() {
    super.initState();
    _allDojoStudents = _db.getDojoStudents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshDojo() {
    setState(() {
      _allDojoStudents = _db.getDojoStudents();
    });
  }

  void _addPoint(DojoStudent student) async {
    // Tocar sonido
    await _audioService.playBellSound();

    // Incrementar en la BD
    bool evolved = _db.addDojoPoint(student.id);
    _refreshDojo();

    // Feedback visual y toast de evolución si aplica
    if (evolved) {
      String levelStr = "Huevo elemental";
      if (student.points >= 9 && student.points <= 11) levelStr = "Cachorro";
      if (student.points >= 12) levelStr = "Dragón Alado Adulto";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Color(0xFFEDC620)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "¡Evolución! ${student.name.split(' ')[0]} ha evolucionado a $levelStr.",
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1D2848),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _togglePresence(DojoStudent student) {
    _db.toggleDojoPresence(student.id);
    _refreshDojo();
  }

  // Ruleta del sorteo
  void _runSorteo() {
    final filtered = _getFilteredDojoStudents();
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay alumnos válidos para sortear.")),
      );
      return;
    }

    setState(() {
      _isSorteoRunning = true;
    });

    int ticks = 0;
    const maxTicks = 12;
    final rand = Random();

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (ticks >= maxTicks) {
        timer.cancel();
        // Elegir ganador final
        final winner = filtered[rand.nextInt(filtered.length)];
        setState(() {
          _highlightedStudentId = winner.id;
          _isSorteoRunning = false;
        });

        // Mostrar diálogo de felicitación
        _showWinnerDialog(winner);
      } else {
        // Resaltar uno aleatorio temporalmente
        setState(() {
          _highlightedStudentId = filtered[rand.nextInt(filtered.length)].id;
        });
        ticks++;
      }
    });
  }

  void _showWinnerDialog(DojoStudent student) {
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
                  color: const Color(0xFF1D2848).withOpacity(0.12),
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
                    Row(
                      children: const [
                        Icon(LucideIcons.sparkles, color: Color(0xFFEDC620)),
                        SizedBox(width: 8),
                        Text(
                          "Alumno Seleccionado",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2848),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () {
                        setState(() {
                          _highlightedStudentId = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),

                // Avatar del dragón del ganador
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEDC620), width: 1.5),
                  ),
                  child: DragonWidget(
                    dragonType: student.dragonType,
                    points: student.points,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  student.name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Puntaje Dojo: ${student.points} pts",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _highlightedStudentId = null;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("EXCELENTE"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Abrir formulario de derivación
  void _openDerivarDrawer(DojoStudent student) {
    String selectedCategory = 'indisciplina';
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    Text(
                      "REPORTAR / DERIVAR ALUMNO",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Selector de categoría
                    const Text(
                      "Categoría de Reporte",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D2848)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D2848)),
                          items: const [
                            DropdownMenuItem(value: 'indisciplina', child: Text("Indisciplina en Aula (-2 pts)")),
                            DropdownMenuItem(value: 'tareas', child: Text("Incumplimiento de Tarea (-1 pt)")),
                            DropdownMenuItem(value: 'tardanza', child: Text("Tardanza Injustificada (-1 pt)")),
                            DropdownMenuItem(value: 'psicologia', child: Text("Derivar a Psicología (0 pts)")),
                            DropdownMenuItem(value: 'topico', child: Text("Derivar a Tópico / Enfermería (0 pts)")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo de comentarios
                    const Text(
                      "Descripción / Comentarios",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D2848)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: "Describe brevemente la conducta o motivo del reporte...",
                        filled: true,
                        fillColor: const Color(0xFFF5F6F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de Envío
                    ElevatedButton(
                      onPressed: () {
                        // Descontar puntos e informar
                        _db.deductDojoPoints(student.id, selectedCategory);
                        Navigator.pop(context);
                        _refreshDojo();

                        // SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(LucideIcons.checkCircle2, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Reporte enviado con éxito. Puntos de ${student.name.split(' ')[0]} actualizados.",
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("CONFIRMAR REPORTE", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<DojoStudent> _getFilteredDojoStudents() {
    return _allDojoStudents.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_dojoSearchQuery.toLowerCase());
      final matchesPresence = !_dojoOnlyPresent || s.present;
      return matchesSearch && matchesPresence;
    }).toList();
  }

  Widget _buildCustomTabItem(int index, String label) {
    final isSelected = _activeTab == index;
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFECE22), Color(0xFFFFA726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA726).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildActiveTabContent(List<DojoStudent> filteredDojo) {
    switch (_activeTab) {
      case 0:
        return _buildContentTab();
      case 1:
        return widget.isTeacher ? _buildDojoTab(filteredDojo) : _buildStudentDojoTab();
      case 2:
        return _buildRubricasTab();
      case 3:
        if (widget.isTeacher) return _buildProyectoVidaTab();
        return const SizedBox.shrink();
      default:
        return _buildContentTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDojo = _getFilteredDojoStudents();

    // Obtener nombres para la tarjeta del docente
    String teacherName = widget.isTeacher
        ? (widget.currentUser?.fullName ?? "Nicole Sulay")
        : (widget.course['teacher'] ?? "Nicole Sulay");
    
    String teacherAvatar = widget.isTeacher
        ? (widget.currentUser?.avatarUrl ?? "https://images.unsplash.com/photo-1544717305-2782549b5136?w=150")
        : (widget.course['avatar'] ?? "https://images.unsplash.com/photo-1544717305-2782549b5136?w=150");

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tirador superior del drawer
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),

          // Fila 1: Botón Volver y Botón Cerrar (X)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: const [
                        Icon(LucideIcons.arrowLeft, size: 12, color: Color(0xFF1D2848)),
                        SizedBox(width: 4),
                        Text(
                          "VOLVER AL AULA",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2848),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF1D2848)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Fila 2: Plataforma descriptor celeste
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "PLATAFORMA EDUCATIVA EXITUS",
              style: TextStyle(
                color: Color(0xFF00B0FF),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Fila 3: Título de curso y Tarjeta del Docente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.course['level']} • ${widget.course['levelNum']}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tarjeta blanca del Docente
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(teacherAvatar),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DOCENTE",
                            style: TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            teacherName.split(' ')[0],
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              color: const Color(0xFF1D2848),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Botones de acción del Docente (+ NUEVA SESIÓN / MODO EXPERTO)
          if (widget.isTeacher) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Creando nueva sesión...")),
                        );
                      },
                      icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                      label: const Text(
                        "NUEVA SESIÓN",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Activando modo experto...")),
                        );
                      },
                      icon: const Icon(LucideIcons.sliders, size: 14, color: Colors.white),
                      label: const Text(
                        "MODO EXPERTO",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Chips de Pestañas Personalizadas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildCustomTabItem(0, "CONTENIDO"),
                const SizedBox(width: 10),
                _buildCustomTabItem(1, "DOJO"),
                const SizedBox(width: 10),
                _buildCustomTabItem(2, "RÚBRICAS"),
                if (widget.isTeacher) ...[
                  const SizedBox(width: 10),
                  _buildCustomTabItem(3, "PROYECTO"),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Contenido de Pestaña Activa
          Expanded(
            child: _buildActiveTabContent(filteredDojo),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        _buildTrimesterAccordionItem(
          index: 0,
          title: "Trimestre 1",
          dates: "27/04/2026 – 11/06/2026",
          sessions: [
            {"title": "Sesión 1: Bienvenida e Introducción", "status": "completed", "date": "27 May"},
            {"title": "Sesión 2: Normas de Convivencia y Roles", "status": "completed", "date": "20 May"},
          ],
        ),
        const SizedBox(height: 12),
        _buildTrimesterAccordionItem(
          index: 1,
          title: "Trimestre 2",
          dates: "08/06/2026 – 04/09/2026",
          sessions: [
            {"title": "Sesión 3: Trabajo en Equipo y Liderazgo", "status": "pending", "date": "10 Jun"},
          ],
        ),
        const SizedBox(height: 12),
        _buildTrimesterAccordionItem(
          index: 2,
          title: "Trimestre 3",
          dates: "14/09/2026 – 18/12/2026",
          sessions: [],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTrimesterAccordionItem({
    required int index,
    required String title,
    required String dates,
    required List<Map<String, String>> sessions,
  }) {
    final isExpanded = _isTrimestreExpanded[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera del trimestre
          InkWell(
            onTap: () {
              setState(() {
                _isTrimestreExpanded[index] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      const SizedBox(height: 2),
                      Text(
                        dates,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: const Color(0xFF1D2848),
                  ),
                ],
              ),
            ),
          ),

          // Contenido Expandido
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "No hay sesiones planificadas en este trimestre.",
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                separatorBuilder: (context, idx) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, idx) {
                  final session = sessions[idx];
                  final isComp = session['status'] == 'completed';
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isComp ? const Color(0xFFE8F5E9) : const Color(0xFFFFECEB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isComp ? LucideIcons.check : LucideIcons.clock,
                          size: 12,
                          color: isComp ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session['title']!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2848),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isComp ? "Dictada: ${session['date']}" : "Programada: ${session['date']}",
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      if (isComp)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "DICTADA",
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDojoTab(List<DojoStudent> students) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controles superiores Dojo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Fecha", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 4),
                          Text(
                            _dojoDate,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Text(
                          "SOLO PRESENTES",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 6),
                        Switch(
                          value: _dojoOnlyPresent,
                          activeColor: const Color(0xFFEDC620),
                          onChanged: (val) {
                            setState(() {
                              _dojoOnlyPresent = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                // Botones Historial, Agrupar, Sortear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDojoActionButton(LucideIcons.history, "HISTORIAL", () {
                      _audioService.playBellSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Historial de puntos: Sin alertas.")),
                      );
                    }),
                    _buildDojoActionButton(LucideIcons.users, "AGRUPAR", () {
                      _audioService.playBellSound();
                      alertGroups();
                    }),
                    _buildDojoActionButton(LucideIcons.sparkles, "SORTEAR", _runSorteo, isGold: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Buscador Alumnos Dojo
          TextFormField(
            onChanged: (val) {
              setState(() {
                _dojoSearchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Buscar alumno en el tablero...",
              prefixIcon: const Icon(LucideIcons.search, size: 14),
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 12),

          // Grilla Alumnos
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.userX, size: 28, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text(
                          "Ningún alumno coincide con los filtros",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: students.length,
                    itemBuilder: (context, idx) {
                      final student = students[idx];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDojoActionButton(IconData icon, String label, VoidCallback onTap, {bool isGold = false}) {
    return ElevatedButton.icon(
      onPressed: _isSorteoRunning ? null : onTap,
      icon: Icon(icon, size: 10, color: isGold ? const Color(0xFF1D2848) : Colors.white),
      label: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isGold ? const Color(0xFF1D2848) : Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isGold ? const Color(0xFFEDC620) : const Color(0xFF1D2848),
        minimumSize: const Size(80, 28),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStudentCard(DojoStudent s) {
    final isHighlighted = s.id == _highlightedStudentId;
    final isGoldPoints = s.points >= 12;

    String stageName = 'Huevo';
    if (s.points >= 5 && s.points <= 8) stageName = 'Huevo ${s.dragonType}';
    if (s.points >= 9 && s.points <= 11) stageName = 'Cachorro';
    if (s.points >= 12) stageName = 'Dragón Alado';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: s.present ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFEDC620)
                : (s.present ? const Color(0xFFE2E8F0) : const Color(0xFFFFCDD2)),
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [BoxShadow(color: const Color(0xFFEDC620).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vector Dragón
                  Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: s.present ? 1.0 : 0.6,
                        child: s.present
                            ? DragonWidget(
                                dragonType: s.dragonType,
                                points: s.points,
                                size: 55,
                              )
                            : ColorFiltered(
                                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                child: DragonWidget(
                                  dragonType: s.dragonType,
                                  points: s.points,
                                  size: 55,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Nombre e info de evolución
                  Column(
                    children: [
                      Text(
                        s.name,
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D2848),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stageName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          color: s.present ? _getElementalColor(s.dragonType) : const Color(0xFF757575),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Botones de acción del alumno
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Toggle Asistencia
                      GestureDetector(
                        onTap: () => _togglePresence(s),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: s.present ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            s.present ? LucideIcons.check : LucideIcons.userX,
                            size: 10,
                            color: s.present ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                          ),
                        ),
                      ),

                      // Botón +1
                      GestureDetector(
                        onTap: s.present ? () => _addPoint(s) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: s.present ? const Color(0xFFE0F7FA) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.plus, size: 8, color: Color(0xFF00B0FF)),
                              const SizedBox(width: 2),
                              Text(
                                "1",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: s.present ? const Color(0xFF00B0FF) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón Derivar
                      GestureDetector(
                        onTap: s.present ? () => _openDerivarDrawer(s) : null,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: s.present ? const Color(0xFFFFEBEE) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            LucideIcons.shieldAlert,
                            size: 10,
                            color: s.present ? const Color(0xFFD32F2F) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Burbuja de Puntos flotante
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: !s.present
                      ? const Color(0xFF757575)
                      : (isGoldPoints ? const Color(0xFFEDC620) : const Color(0xFF1D2848)),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${s.points}",
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isGoldPoints && s.present ? const Color(0xFF1D2848) : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getElementalColor(String type) {
    if (type == 'glaciar') return const Color(0xFF0288D1);
    if (type == 'lava') return const Color(0xFFE64A19);
    if (type == 'rayo') return const Color(0xFF7B1FA2);
    return const Color(0xFFD84315); // brasa / default
  }

  void alertGroups() {
    final groups = [
      "Equipo Fuego: ACHA ABAD, CAMPOVERDE TEMOCHE, CUEVA MORALES",
      "Equipo Hielo: AREVALO OTERO, COVEÑAS PEDRERA, GOMEZ BECERRA",
      "Equipo Trueno: De la cruz, FIESTAS MORALES, JULCA FACUNDO",
      "Equipo Viento: LOZANO ARCA, LUDEÑA CUBAS, SANDOVAL ROSAS"
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Grupos Generados Aleatoriamente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: groups.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(g, style: const TextStyle(fontSize: 11.5)),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido"),
            ),
          ],
        );
      },
    );
  }

   Widget _buildStudentDojoTab() {
    final user = widget.currentUser;
    if (user == null) {
      return const Center(child: Text("Inicia sesión para ver tu Dojo."));
    }
    
    DojoStudent? student;
    final String queryName = user.fullName.toLowerCase().split(' ')[0]; // 'mateo' o 'sofía'
    try {
      student = _allDojoStudents.firstWhere(
        (s) => s.name.toLowerCase().contains(queryName),
      );
    } catch (_) {
      try {
        student = _allDojoStudents.firstWhere((s) => s.id == 34);
      } catch (_) {}
    }

    if (student == null) {
      return const Center(child: Text("No se encontró registro del Dojo para este alumno."));
    }

    String levelName = 'Huevo';
    if (student.points >= 5 && student.points <= 8) {
      levelName = 'Huevo de ${student.dragonType.toUpperCase()}';
    } else if (student.points >= 9 && student.points <= 11) {
      levelName = 'Cachorro';
    } else if (student.points >= 12) {
      levelName = 'Dragón Alado';
    }

    final double progress = min(1.0, student.points / 12.0);
    final nextLevelPts = student.points < 5 ? 5 : (student.points < 9 ? 9 : 12);
    final remainingPts = max(0, nextLevelPts - student.points);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Billetera Dojo Exitus
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              border: Border.all(color: const Color(0xFFFFF9C4), width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFECE22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.coins, color: Color(0xFF1D2848), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tu Billetera Dojo Exitus",
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          children: [
                            const TextSpan(text: "Tienes "),
                            TextSpan(
                              text: "${student.points}",
                              style: const TextStyle(
                                color: Color(0xFFEF6C00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " puntos acumulados"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de Evolución del Dragón
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Nivel de evolución (capsula cian)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      levelName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display del Dragón
                  Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B0FF).withOpacity(0.04),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B0FF).withOpacity(0.06),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: DragonWidget(
                        dragonType: student.dragonType,
                        points: student.points,
                        size: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progreso de Evolución
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nivel de Evolución",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            "Faltan $remainingPts PX",
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 6,
                          color: const Color(0xFFE2E8F0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFECE22), Color(0xFFFFA726)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Historial de Puntos y Hazañas
          Text(
            "Historial de Puntos y Hazañas",
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 10),
          _buildDojoHistory(student),
        ],
      ),
    );
  }

  Widget _buildDojoHistory(DojoStudent student) {
    if (student.points == 0) {
      return Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(LucideIcons.info, size: 24, color: Color(0xFF94A3B8)),
              SizedBox(height: 8),
              Text(
                "Aún no registras participaciones o puntos en esta clase.",
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> items = [
      {
        'title': 'Participación Activa',
        'desc': 'Hoy en clase',
        'pts': '+1 PX',
        'icon': LucideIcons.thumbsUp,
      },
      {
        'title': 'Trabajo en Equipo',
        'desc': 'Ayer',
        'pts': '+2 PX',
        'icon': LucideIcons.star,
      },
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Icon(item['icon'] as IconData, color: const Color(0xFF2E7D32), size: 16),
            ),
            title: Text(
              item['title'] as String,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            subtitle: Text(
              item['desc'] as String,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
            ),
            trailing: Text(
              item['pts'] as String,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRubricasTab() {
    final rubricas = _db.getRubricas();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        if (widget.isTeacher)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Gestión de Rúbricas",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2848),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Evalúa competencias con precisión administrativa.",
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openNewRubricaDialog(),
                icon: const Icon(LucideIcons.plus, size: 12),
                label: const Text("NUEVA RÚBRICA", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2848),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (rubricas.isEmpty)
          const Center(child: Text("No hay rúbricas registradas."))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rubricas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2848),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLibre
                                  ? const Color(0xFFE0F2FE)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isLibre
                                    ? const Color(0xFF0369A1)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.description,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      if (widget.isTeacher)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _evaluarRubrica(r),
                              icon: const Icon(LucideIcons.checkSquare, size: 10),
                              label: const Text("EVALUAR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8F5E9),
                                foregroundColor: const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isLibre) ...[
                              OutlinedButton.icon(
                                onPressed: () => _editarRubrica(r),
                                icon: const Icon(LucideIcons.edit2, size: 10),
                                label: const Text("EDITAR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1D2848),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => _borrarRubrica(r.id),
                              icon: const Icon(LucideIcons.trash2, size: 10),
                              label: const Text("BORRAR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD32F2F),
                                side: const BorderSide(color: Color(0xFFFFCDD2)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      ],
    );
  }

  void _openNewRubricaDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'Creación Libre';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text("Nueva Rúbrica", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nombre de Rúbrica *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Ej. Exposición de Trigonometría",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Tipo de Rúbrica", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Creación Libre', child: Text("Creación Libre")),
                      DropdownMenuItem(value: 'Sesión Alineada', child: Text("Sesión Alineada")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Criterios a evaluar...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCELAR"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    _db.addRubrica(Rubrica(
                      id: Random().nextInt(10000),
                      title: name,
                      type: selectedType,
                      description: descController.text.trim().isEmpty ? "Sin descripción" : descController.text.trim(),
                      date: "29/05/2026",
                    ));
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2848), foregroundColor: Colors.white),
                  child: const Text("GUARDAR"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _evaluarRubrica(Rubrica r) async {
    await _audioService.playBellSound();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Competencias cargadas para '${r.title}'. Evaluando a los 33 alumnos."),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editarRubrica(Rubrica r) {
    final editController = TextEditingController(text: r.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Rúbrica", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          content: TextField(
            controller: editController,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = editController.text.trim();
                if (txt.isNotEmpty) {
                  _db.editRubrica(r.id, txt);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        );
      },
    );
  }

  void _borrarRubrica(int id) {
    _db.deleteRubrica(id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rúbrica eliminada.")),
    );
  }

  Widget _buildProyectoVidaTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Proyecto de Vida",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2848),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Seguimiento psicopedagógico y tutoría.",
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Datos actualizados.")));
              },
              icon: const Icon(LucideIcons.refreshCw, size: 10),
              label: const Text("ACTUALIZAR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF1D2848),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                elevation: 0,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showGeneralIADialog(),
              icon: const Icon(LucideIcons.sparkles, size: 10),
              label: const Text("INFORME GENERAL IA", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAF5FF),
                foregroundColor: const Color(0xFF7E22CE),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                elevation: 0,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cargando portal psicopedagógico completo...")),
                );
              },
              icon: const Icon(LucideIcons.externalLink, size: 10),
              label: const Text("MODULO COMPLETO", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0FDF4),
                foregroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _allDojoStudents.length,
          itemBuilder: (context, index) {
            final s = _allDojoStudents[index];
            final isPending = (s.id == 7);
            final informes = (s.id == 1 || s.id == 11) ? 1 : 0;
            final progreso = isPending ? 0 : 100;
            final initials = s.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isPending ? const Color(0xFFF1F5F9) : const Color(0xFFF0FDF4),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isPending ? const Color(0xFF64748B) : const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.name.split(' ')[0] + ' ' + (s.name.split(' ').length > 1 ? s.name.split(' ')[1] : ''),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$informes Informes • 0 Evidencias",
                      style: const TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "PROG. EVALUACIÓN $progreso%",
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: isPending ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso / 100,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPending ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.eye, size: 12),
                          onPressed: () => _openDossierDialog(s, progreso, informes),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.sparkles, size: 12),
                          onPressed: () => _showStudentIADialog(s),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFAF5FF), foregroundColor: const Color(0xFF7E22CE)),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.shieldAlert, size: 12),
                          onPressed: () => _openDerivarDrawer(s),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: const Color(0xFFD32F2F)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showGeneralIADialog() {
    showDialog(
      context: context,
      builder: (context) {
        final totalPoints = _allDojoStudents.fold<int>(0, (sum, s) => sum + s.points);
        return AlertDialog(
          title: Row(
            children: const [
              Icon(LucideIcons.sparkles, color: Color(0xFF7E22CE), size: 16),
              SizedBox(width: 8),
              Text("Informe General IA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          content: Text(
            "Informe de Rendimiento Psicopedagógico General (IA):\n\n"
            "1. ASISTENCIA: Promedio del aula en 94.5%, cumpliendo con la meta institucional de Exitus.\n"
            "2. RENDIMIENTO DOJO: Puntuación general altamente positiva (+$totalPoints puntos acumulados).\n"
            "3. ALERTA: 1 alumno pendiente de evaluación psicopedagógica inicial en Proyecto de Vida (De la Cruz Salvador, 0%).\n"
            "4. PLAN DE ACCIÓN: Agendar tutorías complementarias con los estudiantes en alerta conductual.",
            style: const TextStyle(fontSize: 11, height: 1.4),
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

  void _showStudentIADialog(DojoStudent s) {
    showDialog(
      context: context,
      builder: (context) {
        final isPending = (s.id == 7);
        final prediction = isPending
            ? "En base al comportamiento del alumno ${s.name.split(' ')[0]} (Puntaje Dojo: ${s.points} pts, Evaluación: Pendiente):\n\n"
                "• RECOMENDACIÓN: El alumno no presenta bitácoras registradas. Se sugiere agendar sesión psicopedagógica inicial prioritaria.\n"
                "• FACTOR DE RIESGO: Ausencia de evidencias de progreso en Proyecto de Vida (Progreso: 0%)."
            : "En base al comportamiento del alumno ${s.name.split(' ')[0]} (Puntaje Dojo: ${s.points} pts):\n\n"
                "• RECOMENDACIÓN PEDAGÓGICA: Se observa un alto índice de atención. Mantener el refuerzo positivo en actividades grupales.\n"
                "• FACTOR DE RIESGO: Ninguno detectado. Desempeño conductual y académico óptimo.";

        return AlertDialog(
          title: Row(
            children: const [
              Icon(LucideIcons.sparkles, color: Color(0xFF7E22CE), size: 16),
              SizedBox(width: 8),
              Text("Análisis Predictivo de IA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D2848))),
              const SizedBox(height: 10),
              Text(prediction, style: const TextStyle(fontSize: 11, height: 1.4)),
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

  void _openDossierDialog(DojoStudent s, int progreso, int informes) {
    showDialog(
      context: context,
      builder: (context) {
        final initials = s.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: progreso == 0 ? const Color(0xFFF1F5F9) : const Color(0xFFF0FDF4),
                child: Text(initials, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: progreso == 0 ? Colors.grey : Colors.green)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Progreso Evaluación", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  Text("$progreso%", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: progreso == 0 ? Colors.red : Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Bitácoras Psicopedagógicas", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
              const SizedBox(height: 8),
              if (informes > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Ficha Psicopedagógica", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                          Text("EVALUADO", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sesión de tutoría individual realizada. Se observa excelente actitud participativa.",
                        style: TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Fecha: 15/05/2026 • Tutor: Prof. Luis Gonzaga",
                        style: TextStyle(fontSize: 7.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: const [
                      Icon(LucideIcons.fileMinus, size: 24, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text(
                        "No se registran bitácoras para este periodo.",
                        style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CERRAR"),
            ),
          ],
        );
      },
    );
  }
}
