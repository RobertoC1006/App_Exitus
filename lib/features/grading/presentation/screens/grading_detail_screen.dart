import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/core/theme/app_theme.dart';

class GradingDetailScreen extends StatefulWidget {
  final String submissionId;
  final VoidCallback onGraded;

  const GradingDetailScreen({
    super.key,
    required this.submissionId,
    required this.onGraded,
  });

  @override
  State<GradingDetailScreen> createState() => _GradingDetailScreenState();
}

class _GradingDetailScreenState extends State<GradingDetailScreen> {
  final _db = MockDatabase();
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isSaving = false;

  late HomeworkSubmission _submission;

  @override
  void initState() {
    super.initState();
    _loadSubmission();
  }

  void _loadSubmission() {
    _submission = _db.submissions.firstWhere((element) => element.id == widget.submissionId);
    if (_submission.status == 'Calificado') {
      _gradeController.text = _submission.grade ?? '';
      _feedbackController.text = _submission.feedback ?? '';
    }
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitGrading() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Simular retraso de red
      await Future.delayed(const Duration(milliseconds: 1000));

      // Guardar en base de datos mock
      _db.gradeSubmission(
        _submission.id,
        _gradeController.text.trim().toUpperCase(),
        _feedbackController.text.trim(),
      );

      widget.onGraded();

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.white),
                const SizedBox(width: 8),
                Text('Tarea de ${_submission.studentName} calificada.'),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGraded = _submission.status == 'Calificado';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revisión de Tarea"),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Información del Alumno
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_submission.studentAvatar),
                    radius: 24,
                    backgroundColor: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _submission.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF002244),
                          ),
                        ),
                        Text(
                          "Entregado: ${_submission.date}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isGraded)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Nota: ${_submission.grade}",
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Detalle de la Tarea Asignada
              const Text(
                "Tarea Asignada",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF002244),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _submission.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF002244),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _submission.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Respuesta del Estudiante
              const Text(
                "Respuesta del Alumno",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF002244),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _submission.submittedText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Adjunto simulado (Documento o imagen)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.image, color: Color(0xFFE5A93B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "resolucion_practica.jpg",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF002244),
                                ),
                              ),
                              Text(
                                "Imagen JPG • 2.4 MB",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.download, size: 20, color: Color(0xFF002244)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Archivo descargado (Simulado)."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Formulario de Calificación
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGraded ? "Editar Calificación" : "Ingresar Calificación",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF002244),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de Nota
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: _gradeController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: "0 - 20 / A",
                              counterText: "",
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              labelText: "Nota",
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Sugerencias de Notas Rápidas
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sugerencias:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ['20', '18', '15', 'AD', 'A'].map((n) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _gradeController.text = n;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        n,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campo de Comentarios
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Escribe aquí la retroalimentación para el alumno...",
                        labelText: "Comentarios / Retroalimentación",
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor escribe algún comentario de apoyo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _submitGrading,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002244),
                        disabledBackgroundColor: const Color(0xFF002244).withValues(alpha: 0.6),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.checkSquare, size: 18),
                                const SizedBox(width: 8),
                                Text(isGraded ? "ACTUALIZAR CALIFICACIÓN" : "ENVIAR CALIFICACIÓN"),
                              ],
                            ),
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
}
