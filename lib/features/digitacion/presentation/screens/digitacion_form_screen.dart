import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitacionFormScreen extends StatefulWidget {
  final PrintRequest? request;
  final VoidCallback onSaved;

  const DigitacionFormScreen({super.key, this.request, required this.onSaved});

  @override
  State<DigitacionFormScreen> createState() => _DigitacionFormScreenState();
}

class _DigitacionFormScreenState extends State<DigitacionFormScreen> {
  final MockDatabase _db = MockDatabase();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _limitDateController;
  late TextEditingController _instController;

  String _colorMode = 'b/n';
  String _paperSize = 'A4';
  String _uploadedFileName = '';
  double _uploadedFileSizeMB = 0.0;

  // Lista de aulas de destino y copias
  final List<Map<String, dynamic>> _targets = [];

  final List<String> _classroomOptions = ['4 B', '2 A', '5 A', '5 B'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.request?.title ?? '');
    _descController = TextEditingController(text: widget.request?.description ?? '');
    _limitDateController = TextEditingController(text: widget.request?.limitDate ?? '2026-05-29');
    _instController = TextEditingController(text: widget.request?.instructions ?? '');

    if (widget.request != null) {
      _colorMode = widget.request!.colorMode;
      _paperSize = widget.request!.paperSize;
      _uploadedFileName = widget.request!.file;
      _uploadedFileSizeMB = 1.8;

      for (var target in widget.request!.classrooms) {
        _targets.add({'classroom': target.name, 'copies': target.copies});
      }
    } else {
      _targets.add({'classroom': '', 'copies': 1});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _limitDateController.dispose();
    _instController.dispose();
    super.dispose();
  }

  void _addTargetRow() {
    setState(() {
      _targets.add({'classroom': '', 'copies': 1});
    });
  }

  void _removeTargetRow(int index) {
    if (_targets.length > 1) {
      setState(() {
        _targets.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe mantener al menos un aula de destino.")),
      );
    }
  }

  void _pickMockFile() {
    setState(() {
      _uploadedFileName = "Examen_Álgebra_${_targets.first['classroom'].toString().replaceAll(' ', '')}.pdf";
      if (_uploadedFileName.contains('null') || _uploadedFileName.contains('')) {
        _uploadedFileName = "Examen_Parcial_Matematicas.pdf";
      }
      _uploadedFileSizeMB = Random().nextDouble() * 4 + 1.2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Archivo seleccionado: $_uploadedFileName")),
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validar aulas de destino
    bool targetsValid = true;
    for (var target in _targets) {
      if (target['classroom'] == '' || target['copies'] <= 0) {
        targetsValid = false;
        break;
      }
    }

    if (!targetsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, seleccione un aula válida y cantidad de ejemplares."),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final limitDate = _limitDateController.text.trim();
    final instructions = _instController.text.trim();

    final classroomTargets = _targets.map((t) {
      return PrintClassroomTarget(
        name: t['classroom'],
        copies: t['copies'],
      );
    }).toList();

    final file = _uploadedFileName.isEmpty ? "documento.pdf" : _uploadedFileName;

    if (widget.request != null) {
      // Editar
      final updated = PrintRequest(
        id: widget.request!.id,
        ticketNumber: widget.request!.ticketNumber,
        title: title,
        description: description,
        requester: widget.request!.requester,
        date: widget.request!.date,
        colorMode: _colorMode,
        paperSize: _paperSize,
        status: widget.request!.status,
        classrooms: classroomTargets,
        file: file,
        limitDate: limitDate,
        instructions: instructions,
      );
      _db.updatePrintRequest(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Solicitud #${widget.request!.ticketNumber} editada con éxito"),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else {
      // Crear
      final nextId = _db.getPrintRequests().isEmpty
          ? 1
          : _db.getPrintRequests().map((j) => j.id).reduce(max) + 1;
      final ticketNum = nextId.toString().padLeft(5, '0');

      final newReq = PrintRequest(
        id: nextId,
        ticketNumber: ticketNum,
        title: title,
        description: description,
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "29/05/2026",
        colorMode: _colorMode,
        paperSize: _paperSize,
        status: "pending",
        classrooms: classroomTargets,
        file: file,
        limitDate: limitDate,
        instructions: instructions,
      );

      _db.addPrintRequest(newReq);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Solicitud #$ticketNum creada con éxito"),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );

      // Simulación de Luis Gonzaga: 6 segundos de delay
      final classroomsText = classroomTargets.map((c) => "${c.name} - ${c.copies} ej.").join(', ');
      Timer(const Duration(seconds: 6), () {
        final newMsgId = 'msg_lg_${Random().nextInt(10000)}';
        
        final mockMsg = InboxMessage(
          id: newMsgId,
          sender: "Luis Gonzaga",
          subject: "[Impresiones] Solicitud #$ticketNum Recibida",
          date: "Hoy",
          snippet: "Confirmación de recepción de ticket #$ticketNum para \"$title\"...",
          content: "Hola Nicole,\n\nHemos recibido su solicitud de impresión #$ticketNum para \"$title\" ($classroomsText). Ha sido registrada en el sistema de producción con estado PENDIENTE.\n\nAtentamente,\nLuis Gonzaga - Centro de Producción.",
          unread: true,
          urgent: false,
        );

        _db.adminMessages.insert(0, mockMsg); // Tránsito a la bandeja de entrada del docente

        // Notificación flotante (si la app sigue abierta)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.mail, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Nuevo mensaje de Luis Gonzaga sobre Ticket #$ticketNum",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1D2848),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: "VER",
                textColor: const Color(0xFFEDC620),
                onPressed: () {
                  // Acción de ver
                },
              ),
            ),
          );
        }
      });
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1D2848)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.request != null ? "Editar Solicitud" : "Nueva Impresión",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Título del Documento
              const Text(
                "Título del Documento *",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.trim().isEmpty ? "Ingrese un título" : null,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Ej. Examen de Álgebra - Trimestre II",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Aulas de destino dinámicas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Destino y Ejemplares *",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                  ),
                  TextButton.icon(
                    onPressed: _addTargetRow,
                    icon: const Icon(LucideIcons.plusCircle, size: 14),
                    label: const Text("AGREGAR AULA", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF1D2848)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _targets.length,
                itemBuilder: (context, index) {
                  final target = _targets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Dropdown Aula
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Aula", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: target['classroom'] == '' ? null : target['classroom'],
                                hint: const Text("Seleccionar"),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                                items: _classroomOptions.map((room) {
                                  return DropdownMenuItem(value: room, child: Text("Aula $room"));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _targets[index]['classroom'] = val;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cantidad Ejemplares
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Copias", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: target['copies'].toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 0;
                                  _targets[index]['copies'] = num;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Eliminar fila
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFD32F2F)),
                          onPressed: () => _removeTargetRow(index),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Formato e Impresión (Color y Tamaño)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Modo Color", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _colorMode,
                          style: const TextStyle(fontSize: 12.5, color: Colors.black),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'b/n', child: Text("Blanco y Negro")),
                            DropdownMenuItem(value: 'color', child: Text("Color")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _colorMode = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tamaño Papel", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _paperSize,
                          style: const TextStyle(fontSize: 12.5, color: Colors.black),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'A4', child: Text("A4")),
                            DropdownMenuItem(value: 'A3', child: Text("A3")),
                            DropdownMenuItem(value: 'Letter', child: Text("Carta")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _paperSize = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Archivo adjunto (Mock drag-and-drop box)
              const Text("Documento a Imprimir (Max 10MB) *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickMockFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF7B1FA2).withValues(alpha: _uploadedFileName.isNotEmpty ? 0.3 : 0.1),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.uploadCloud, size: 28, color: Color(0xFF7B1FA2)),
                      const SizedBox(height: 8),
                      Text(
                        _uploadedFileName.isNotEmpty
                            ? "Archivo: $_uploadedFileName (${_uploadedFileSizeMB.toStringAsFixed(2)} MB)"
                            : "Haz clic para seleccionar o subir documento",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _uploadedFileName.isNotEmpty ? const Color(0xFF7B1FA2) : const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Formatos soportados: PDF, Word, Excel, PPT, Imágenes",
                        style: TextStyle(fontSize: 8.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Fecha límite e Instrucciones
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Fecha Límite *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _limitDateController,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: "AAAA-MM-DD",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Instrucciones Especiales", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D2848))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _instController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Ej. Engrapar por grupos de 2 hojas, recortar la mitad inferior...",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 28),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D2848),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("GUARDAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
