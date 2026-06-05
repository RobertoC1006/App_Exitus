import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';

class StepDescriptionAI extends StatefulWidget {
  final String description;
  final ValueChanged<String> onDescriptionChanged;
  final String incidentType;

  const StepDescriptionAI({
    super.key,
    required this.description,
    required this.onDescriptionChanged,
    required this.incidentType,
  });

  @override
  State<StepDescriptionAI> createState() => _StepDescriptionAIState();
}

class _StepDescriptionAIState extends State<StepDescriptionAI> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isRecording = false;
  bool _isAILoading = false;
  StreamSubscription<String>? _transcriptionSubscription;

  // Animation controller for pulsing sound wave
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didUpdateWidget(covariant StepDescriptionAI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.description != oldWidget.description && widget.description != _controller.text) {
      _controller.text = widget.description;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _transcriptionSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Detener grabación
      _transcriptionSubscription?.cancel();
      _pulseController.stop();
      setState(() {
        _isRecording = false;
      });
    } else {
      // Iniciar grabación simulada
      setState(() {
        _isRecording = true;
        _controller.clear();
      });
      widget.onDescriptionChanged(""); // Notificar al padre
      _pulseController.repeat(reverse: true);

      // Conectarse al stream del endpoint de voz
      _transcriptionSubscription = BitacoraApi.transcribeVoiceToText().listen(
        (text) {
          if (text.isNotEmpty) {
            setState(() {
              _controller.text = text;
              // Mover cursor al final
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
            widget.onDescriptionChanged(text); // Notificar al padre
          }
        },
        onDone: () {
          _pulseController.stop();
          setState(() {
            _isRecording = false;
          });
        },
      );
    }
  }

  void _improveText() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isAILoading = true;
    });

    try {
      // Llamada al endpoint stub de Gemini AI
      final improved = await BitacoraApi.improveIncidentDescriptionWithAI(
        _controller.text,
        widget.incidentType,
      );

      setState(() {
        _controller.text = improved;
      });
      widget.onDescriptionChanged(improved); // Notificar al padre
    } catch (e) {
      debugPrint("Error al mejorar con IA: $e");
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTallScreen = screenHeight > 800;

    final double topSpacing = isTallScreen ? 32.0 : 16.0;
    final double headerSpacing = isTallScreen ? 28.0 : 20.0;
    final double mascotSpacing = isTallScreen ? 36.0 : 24.0;
    final double mascotSize = isTallScreen ? 70.0 : 50.0;
    final int textFieldMaxLines = isTallScreen ? 12 : 8;

    final charCount = _controller.text.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSpacing),
          Text(
            "Cuéntanos qué pasó",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Describe lo ocurrido de la manera más clara posible.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          SizedBox(height: headerSpacing),

          // Mascot chat bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/mascot_bitacoras.png',
                height: mascotSize,
                width: mascotSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: mascotSize,
                  height: mascotSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE3E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.bot, color: Color(0xFFEF4444)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    "Estoy aquí para ayudarte.\nCuéntame qué sucedió como si me lo contaras.",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D2848),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: mascotSpacing),

          // Text Area with simulated transcription or shimmer loader
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isRecording
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE2E8F0),
                    width: _isRecording ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: textFieldMaxLines,
                      maxLength: 1000,
                      onChanged: (val) {
                        widget.onDescriptionChanged(val);
                      },
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? "Escuchando... hable ahora."
                            : "Durante la clase, los alumnos se lanzaron papeles...",
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                          fontStyle: _isRecording ? FontStyle.italic : FontStyle.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterText: "",
                      ),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1D2848)),
                    ),
                    // Action footer bar inside text field
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Microphone option
                              GestureDetector(
                                onTap: _toggleRecording,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_isRecording)
                                      AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          return Container(
                                            width: 38 + (24 * _pulseController.value),
                                            height: 38 + (24 * _pulseController.value),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.2 * (1 - _pulseController.value)),
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        },
                                      ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isRecording ? LucideIcons.micOff : LucideIcons.mic,
                                        color: _isRecording ? Colors.white : const Color(0xFF1D2848),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // AI Impove button
                              FilledButton.icon(
                                onPressed: _controller.text.isEmpty || _isAILoading ? null : _improveText,
                                icon: _isAILoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(LucideIcons.sparkles, size: 14),
                                label: const Text(
                                  "Mejorar con IA",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D2848),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "$charCount / 1000",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isAILoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Gemini está puliendo el texto...",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2848),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // AI Suggestion bubble
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Detecté una posible incidencia ${widget.incidentType.toLowerCase()} relacionada con la interrupción de clases.",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
