import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';
import 'package:app_exitus/core/services/audio_service.dart';

class InnerClassroomDrawer extends StatefulWidget {
  final Map<String, dynamic> course; // Contiene id, title, room, tag, level, levelNum, teacher, avatar

  const InnerClassroomDrawer({
    super.key,
    required this.course,
  });

  @override
  State<InnerClassroomDrawer> createState() => _InnerClassroomDrawerState();
}

class _InnerClassroomDrawerState extends State<InnerClassroomDrawer> with SingleTickerProviderStateMixin {
  final MockDatabase _db = MockDatabase();
  final AudioService _audioService = AudioService();

  late TabController _tabController;
  int _activeTab = 0; // 0: Contenido, 1: Dojo

  // Estados del Acordeón de Trimestres
  final List<bool> _isTrimestreExpanded = [true, false, false];

  // Estados de los filtros de Dojo
  String _dojoDate = "2026-05-27";
  bool _dojoOnlyPresent = false;
  String _dojoSearchQuery = "";
  late List<DojoStudent> _allDojoStudents;

  // Estados del sorteo (roulette)
  bool _isSorteoRunning = false;
  int? _highlightedStudentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _activeTab = _tabController.index;
      });
    });
    _allDojoStudents = _db.getDojoStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final filteredDojo = _getFilteredDojoStudents();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
          const SizedBox(height: 12),

          // Cabecera del Curso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.course['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      Text(
                        "${widget.course['level']} • ${widget.course['levelNum']} • ${widget.course['room']}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Pestañas (Contenido vs Dojo)
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D2848).withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF1D2848),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "CONTENIDO"),
                Tab(text: "DOJO"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contenido de Pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. PESTAÑA CONTENIDO
                _buildContentTab(),

                // 2. PESTAÑA DOJO
                _buildDojoTab(filteredDojo),
              ],
            ),
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
}
