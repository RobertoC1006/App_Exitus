import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/dragon_painter.dart';
import 'package:app_exitus/core/services/audio_service.dart';
import 'package:app_exitus/features/classroom/presentation/widgets/classroom_drawer_tabs.dart';

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
  final String _dojoDate = "2026-05-27";
  late List<DojoStudent> _allDojoStudents;

  // Estados del sorteo (roulette)
  bool _isSorteoRunning = false;
  int? _highlightedStudentId;

  @override
  void initState() {
    super.initState();
    _allDojoStudents = _db.getDojoStudents();
  }

  void _refreshDojo() {
    setState(() {
      _allDojoStudents = _db.getDojoStudents();
    });
  }

  void _addPoint(DojoStudent student) async {
    await _audioService.playBellSound();
    bool evolved = _db.addDojoPoint(student.id);
    _refreshDojo();

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

  void _runSorteo() {
    final filtered = _allDojoStudents.where((s) => s.present).toList();
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
        final winner = filtered[rand.nextInt(filtered.length)];
        setState(() {
          _highlightedStudentId = winner.id;
          _isSorteoRunning = false;
        });

        _showWinnerDialog(winner);
      } else {
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
                    ElevatedButton(
                      onPressed: () {
                        _db.deductDojoPoints(student.id, selectedCategory);
                        Navigator.pop(context);
                        _refreshDojo();

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

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return const ClassroomContentTab();
      case 1:
        return widget.isTeacher
            ? ClassroomDojoTab(
                students: _allDojoStudents,
                date: _dojoDate,
                onHistoryPressed: () {
                  _audioService.playBellSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Historial de puntos: Sin alertas.")),
                  );
                },
                onGroupPressed: () {
                  _audioService.playBellSound();
                  alertGroups();
                },
                onSorteoPressed: _runSorteo,
                onAddPoint: _addPoint,
                onTogglePresence: _togglePresence,
                onDerivar: _openDerivarDrawer,
                highlightedStudentId: _highlightedStudentId,
                isSorteoRunning: _isSorteoRunning,
              )
            : ClassroomStudentDojoTab(
                currentUser: widget.currentUser,
                allDojoStudents: _allDojoStudents,
              );
      case 2:
        return ClassroomRubricasTab(
          rubricas: _db.getRubricas(),
          isTeacher: widget.isTeacher,
          onNewRubricaPressed: _openNewRubricaDialog,
          onEvaluar: _evaluarRubrica,
          onEditar: _editarRubrica,
          onBorrar: _borrarRubrica,
        );
      case 3:
        if (widget.isTeacher) {
          return ClassroomProyectoVidaTab(
            students: _allDojoStudents,
            onRefresh: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Datos actualizados.")));
            },
            onGeneralIAPressed: _showGeneralIADialog,
            onModuloCompletoPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cargando portal psicopedagógico completo...")),
              );
            },
            onViewDossier: (s) {
              final isPending = (s.id == 7);
              final informes = (s.id == 1 || s.id == 11) ? 1 : 0;
              final progreso = isPending ? 0 : 100;
              _openDossierDialog(s, progreso, informes);
            },
            onStudentIAPressed: _showStudentIADialog,
            onDerivar: _openDerivarDrawer,
          );
        }
        return const SizedBox.shrink();
      default:
        return const ClassroomContentTab();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: _buildActiveTabContent(),
          ),
        ],
      ),
    );
  }
}
