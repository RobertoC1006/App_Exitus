import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

// ==========================================
// PESTAÑA: CONTENIDO (ClassroomContentTab)
// ==========================================
class ClassroomContentTab extends StatefulWidget {
  const ClassroomContentTab({super.key});

  @override
  State<ClassroomContentTab> createState() => _ClassroomContentTabState();
}

class _ClassroomContentTabState extends State<ClassroomContentTab> {
  final List<bool> _isTrimestreExpanded = [true, false, false];

  @override
  Widget build(BuildContext context) {
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
}

// ==========================================
// PESTAÑA: DOJO DOCENTE (ClassroomDojoTab)
// ==========================================
class ClassroomDojoTab extends StatefulWidget {
  final List<DojoStudent> students;
  final String date;
  final VoidCallback onHistoryPressed;
  final VoidCallback onGroupPressed;
  final VoidCallback onSorteoPressed;
  final Function(DojoStudent) onAddPoint;
  final Function(DojoStudent) onTogglePresence;
  final Function(DojoStudent) onDerivar;
  final int? highlightedStudentId;
  final bool isSorteoRunning;

  const ClassroomDojoTab({
    super.key,
    required this.students,
    required this.date,
    required this.onHistoryPressed,
    required this.onGroupPressed,
    required this.onSorteoPressed,
    required this.onAddPoint,
    required this.onTogglePresence,
    required this.onDerivar,
    this.highlightedStudentId,
    required this.isSorteoRunning,
  });

  @override
  State<ClassroomDojoTab> createState() => _ClassroomDojoTabState();
}

class _ClassroomDojoTabState extends State<ClassroomDojoTab> {
  bool _dojoOnlyPresent = false;
  String _dojoSearchQuery = "";

  List<DojoStudent> _getFilteredDojoStudents() {
    return widget.students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_dojoSearchQuery.toLowerCase());
      final matchesPresence = !_dojoOnlyPresent || s.present;
      return matchesSearch && matchesPresence;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredDojoStudents();

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
                            widget.date,
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
                    _buildDojoActionButton(LucideIcons.history, "HISTORIAL", widget.onHistoryPressed),
                    _buildDojoActionButton(LucideIcons.users, "AGRUPAR", widget.onGroupPressed),
                    _buildDojoActionButton(LucideIcons.sparkles, "SORTEAR", widget.onSorteoPressed, isGold: true),
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
            child: filtered.isEmpty
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
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final student = filtered[idx];
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
      onPressed: widget.isSorteoRunning ? null : onTap,
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
    final isHighlighted = s.id == widget.highlightedStudentId;
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onTogglePresence(s),
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
                      GestureDetector(
                        onTap: s.present ? () => widget.onAddPoint(s) : null,
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
                      GestureDetector(
                        onTap: s.present ? () => widget.onDerivar(s) : null,
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
    return const Color(0xFFD84315);
  }
}

// ==========================================
// PESTAÑA: DOJO ESTUDIANTE (ClassroomStudentDojoTab)
// ==========================================
class ClassroomStudentDojoTab extends StatelessWidget {
  final User? currentUser;
  final List<DojoStudent> allDojoStudents;

  const ClassroomStudentDojoTab({
    super.key,
    required this.currentUser,
    required this.allDojoStudents,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Inicia sesión para ver tu Dojo."));
    }

    DojoStudent? student;
    final String queryName = currentUser!.fullName.toLowerCase().split(' ')[0];
    try {
      student = allDojoStudents.firstWhere(
        (s) => s.name.toLowerCase().contains(queryName),
      );
    } catch (_) {
      try {
        student = allDojoStudents.firstWhere((s) => s.id == 34);
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
}

// ==========================================
// PESTAÑA: RÚBRICAS (ClassroomRubricasTab)
// ==========================================
class ClassroomRubricasTab extends StatelessWidget {
  final List<Rubrica> rubricas;
  final bool isTeacher;
  final VoidCallback onNewRubricaPressed;
  final Function(Rubrica) onEvaluar;
  final Function(Rubrica) onEditar;
  final Function(int) onBorrar;

  const ClassroomRubricasTab({
    super.key,
    required this.rubricas,
    required this.isTeacher,
    required this.onNewRubricaPressed,
    required this.onEvaluar,
    required this.onEditar,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        if (isTeacher)
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
                onPressed: onNewRubricaPressed,
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
                      if (isTeacher)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => onEvaluar(r),
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
                                  onPressed: () => onEditar(r),
                                  icon: const Icon(LucideIcons.edit2, size: 10),
                                  label: const Text("EDITAR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1D2848),
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  )),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => onBorrar(r.id),
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
}

// ==========================================
// PESTAÑA: PROYECTO DE VIDA (ClassroomProyectoVidaTab)
// ==========================================
class ClassroomProyectoVidaTab extends StatelessWidget {
  final List<DojoStudent> students;
  final VoidCallback onRefresh;
  final VoidCallback onGeneralIAPressed;
  final VoidCallback onModuloCompletoPressed;
  final Function(DojoStudent) onViewDossier;
  final Function(DojoStudent) onStudentIAPressed;
  final Function(DojoStudent) onDerivar;

  const ClassroomProyectoVidaTab({
    super.key,
    required this.students,
    required this.onRefresh,
    required this.onGeneralIAPressed,
    required this.onModuloCompletoPressed,
    required this.onViewDossier,
    required this.onStudentIAPressed,
    required this.onDerivar,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRefresh,
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
              onPressed: onGeneralIAPressed,
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
              onPressed: onModuloCompletoPressed,
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
          itemCount: students.length,
          itemBuilder: (context, index) {
            final s = students[index];
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
                          onPressed: () => onViewDossier(s),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.sparkles, size: 12),
                          onPressed: () => onStudentIAPressed(s),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFAF5FF), foregroundColor: const Color(0xFF7E22CE)),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.shieldAlert, size: 12),
                          onPressed: () => onDerivar(s),
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
}
