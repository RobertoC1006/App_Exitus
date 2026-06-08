import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/bitacora_report.dart';

class StepMeasures extends StatefulWidget {
  final List<String> selectedMeasures;
  final ValueChanged<List<String>> onMeasuresChanged;
  final Map<String, String> measureContexts;
  final ValueChanged<Map<String, String>> onContextsChanged;
  final Map<String, String> measureFollowUps;
  final ValueChanged<Map<String, String>> onFollowUpsChanged;

  const StepMeasures({
    super.key,
    required this.selectedMeasures,
    required this.onMeasuresChanged,
    required this.measureContexts,
    required this.onContextsChanged,
    required this.measureFollowUps,
    required this.onFollowUpsChanged,
  });

  @override
  State<StepMeasures> createState() => _StepMeasuresState();
}

class _StepMeasuresState extends State<StepMeasures> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Controla si el campo de seguimiento general está activo
  bool _isFollowUpActive = false;

  late TextEditingController _contextController;
  late TextEditingController _followUpController;

  bool _isRecordingContext = false;
  bool _isAILoadingContext = false;
  StreamSubscription<String>? _transcriptionSubscriptionContext;
  late AnimationController _pulseControllerContext;

  bool _isRecordingFollowUp = false;
  bool _isAILoadingFollowUp = false;
  StreamSubscription<String>? _transcriptionSubscriptionFollowUp;
  late AnimationController _pulseControllerFollowUp;

  final List<Map<String, dynamic>> _measureOptions = [
    {
      'title': 'Conversación con estudiantes',
      'icon': LucideIcons.messageSquare,
      'color': const Color(0xFF3B82F6),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'title': 'Llamado de atención',
      'icon': LucideIcons.megaphone,
      'color': const Color(0xFFFFB03B),
      'bgColor': const Color(0xFFFFF7ED),
    },
    {
      'title': 'Derivación a Convivencia',
      'icon': LucideIcons.shieldAlert,
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFECFDF5),
    },
    {
      'title': 'Derivación a Psicología',
      'icon': LucideIcons.heart,
      'color': const Color(0xFFEC4899),
      'bgColor': const Color(0xFFFEF2F2),
    },
    {
      'title': 'Citación a padres',
      'icon': LucideIcons.users,
      'color': const Color(0xFF6366F1),
      'bgColor': const Color(0xFFEEF2F6),
    },
    {
      'title': 'Otro',
      'icon': LucideIcons.moreHorizontal,
      'color': const Color(0xFF6B7280),
      'bgColor': const Color(0xFFF9FAFB),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar el estado del seguimiento si ya existe texto previo
    _isFollowUpActive = (widget.measureFollowUps['General'] ?? "").trim().isNotEmpty;

    _contextController = TextEditingController(text: widget.measureContexts['General'] ?? "");
    _followUpController = TextEditingController(text: widget.measureFollowUps['General'] ?? "");

    _pulseControllerContext = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseControllerFollowUp = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didUpdateWidget(covariant StepMeasures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.measureContexts['General'] != oldWidget.measureContexts['General'] &&
        widget.measureContexts['General'] != _contextController.text) {
      _contextController.text = widget.measureContexts['General'] ?? "";
    }
    if (widget.measureFollowUps['General'] != oldWidget.measureFollowUps['General'] &&
        widget.measureFollowUps['General'] != _followUpController.text) {
      _followUpController.text = widget.measureFollowUps['General'] ?? "";
    }
  }

  @override
  void dispose() {
    _contextController.dispose();
    _followUpController.dispose();
    _transcriptionSubscriptionContext?.cancel();
    _transcriptionSubscriptionFollowUp?.cancel();
    _pulseControllerContext.dispose();
    _pulseControllerFollowUp.dispose();
    super.dispose();
  }

  void _toggleMeasure(String title) {
    final List<String> list = List.from(widget.selectedMeasures);
    if (list.contains(title)) {
      list.remove(title);
      // Si ya no queda ninguna medida, limpiamos los textos generales
      if (list.isEmpty) {
        _contextController.clear();
        _followUpController.clear();
        widget.onContextsChanged({});
        widget.onFollowUpsChanged({});
        setState(() {
          _isFollowUpActive = false;
        });
      }
    } else {
      list.add(title);
      
      // Auto scroll suave hacia abajo después de que se renderice el nuevo campo
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
    widget.onMeasuresChanged(list);
  }

  void _toggleRecordingContext() {
    if (_isRecordingContext) {
      _transcriptionSubscriptionContext?.cancel();
      _pulseControllerContext.stop();
      setState(() {
        _isRecordingContext = false;
      });
    } else {
      setState(() {
        _isRecordingContext = true;
        _contextController.clear();
      });
      final map = Map<String, String>.from(widget.measureContexts)..['General'] = "";
      widget.onContextsChanged(map);

      _pulseControllerContext.repeat(reverse: true);

      _transcriptionSubscriptionContext = BitacoraApi.transcribeVoiceToText().listen(
        (text) {
          if (text.isNotEmpty) {
            setState(() {
              _contextController.text = text;
              _contextController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contextController.text.length),
              );
            });
            final newMap = Map<String, String>.from(widget.measureContexts)..['General'] = text;
            widget.onContextsChanged(newMap);
          }
        },
        onDone: () {
          _pulseControllerContext.stop();
          setState(() {
            _isRecordingContext = false;
          });
        },
      );
    }
  }

  void _toggleRecordingFollowUp() {
    if (_isRecordingFollowUp) {
      _transcriptionSubscriptionFollowUp?.cancel();
      _pulseControllerFollowUp.stop();
      setState(() {
        _isRecordingFollowUp = false;
      });
    } else {
      setState(() {
        _isRecordingFollowUp = true;
        _followUpController.clear();
      });
      final map = Map<String, String>.from(widget.measureFollowUps)..['General'] = "";
      widget.onFollowUpsChanged(map);

      _pulseControllerFollowUp.repeat(reverse: true);

      _transcriptionSubscriptionFollowUp = BitacoraApi.transcribeVoiceToText().listen(
        (text) {
          if (text.isNotEmpty) {
            setState(() {
              _followUpController.text = text;
              _followUpController.selection = TextSelection.fromPosition(
                TextPosition(offset: _followUpController.text.length),
              );
            });
            final newMap = Map<String, String>.from(widget.measureFollowUps)..['General'] = text;
            widget.onFollowUpsChanged(newMap);
          }
        },
        onDone: () {
          _pulseControllerFollowUp.stop();
          setState(() {
            _isRecordingFollowUp = false;
          });
        },
      );
    }
  }

  void _improveContextText() async {
    if (_contextController.text.trim().isEmpty) return;

    setState(() {
      _isAILoadingContext = true;
    });

    try {
      final improved = await BitacoraApi.improveMeasuresDescriptionWithAI(_contextController.text);
      setState(() {
        _contextController.text = improved;
      });
      final map = Map<String, String>.from(widget.measureContexts)..['General'] = improved;
      widget.onContextsChanged(map);
    } catch (e) {
      debugPrint("Error al mejorar con IA: $e");
    } finally {
      setState(() {
        _isAILoadingContext = false;
      });
    }
  }

  void _improveFollowUpText() async {
    if (_followUpController.text.trim().isEmpty) return;

    setState(() {
      _isAILoadingFollowUp = true;
    });

    try {
      final improved = await BitacoraApi.improveMeasuresDescriptionWithAI(_followUpController.text);
      setState(() {
        _followUpController.text = improved;
      });
      final map = Map<String, String>.from(widget.measureFollowUps)..['General'] = improved;
      widget.onFollowUpsChanged(map);
    } catch (e) {
      debugPrint("Error al mejorar con IA: $e");
    } finally {
      setState(() {
        _isAILoadingFollowUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTallScreen = screenHeight > 800;

    final double topSpacing = isTallScreen ? 32.0 : 16.0;
    final double headerSpacing = isTallScreen ? 32.0 : 24.0;
    final double gridSpacingHorizontal = isTallScreen ? 16.0 : 12.0;
    final double gridSpacingVertical = isTallScreen ? 16.0 : 12.0;
    final double cardAspectRatio = isTallScreen ? 1.15 : 1.25;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSpacing),
          Text(
            "¿Qué medidas adoptaste?",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Selecciona las acciones inmediatas que realizaste.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          SizedBox(height: headerSpacing),

          // Grid of 6 cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _measureOptions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gridSpacingHorizontal,
              mainAxisSpacing: gridSpacingVertical,
              childAspectRatio: cardAspectRatio,
            ),
            itemBuilder: (context, index) {
              final opt = _measureOptions[index];
              final title = opt['title'] as String;
              final isSelected = widget.selectedMeasures.contains(title);

              return GestureDetector(
                onTap: () => _toggleMeasure(title),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? opt['bgColor'] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? opt['color'] as Color : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (opt['color'] as Color).withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : opt['bgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              opt['icon'] as IconData,
                              color: opt['color'] as Color,
                              size: 16,
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) => _toggleMeasure(title),
                            activeColor: opt['color'] as Color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ],
                      ),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Conditional General Details form (appended at bottom on scroll)
          if (widget.selectedMeasures.isNotEmpty) ...[
            const Divider(height: 32, color: Color(0xFFE2E8F0)),
            Text(
              "DETALLES DE MEDIDAS ADOPTADAS",
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Detalles Generales",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Context field 1
                  const Text(
                    "Especificación / Contexto de las medidas (Opcional)",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isRecordingContext ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                            width: _isRecordingContext ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _contextController,
                              maxLines: 4,
                              onChanged: (val) {
                                final map = Map<String, String>.from(widget.measureContexts);
                                map['General'] = val;
                                widget.onContextsChanged(map);
                              },
                              decoration: InputDecoration(
                                hintText: _isRecordingContext
                                    ? "Escuchando... hable ahora."
                                    : "Especifica qué se hizo o da más detalles generales...",
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: _isRecordingContext ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                  fontStyle: _isRecordingContext ? FontStyle.italic : FontStyle.normal,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D2848)),
                            ),
                            // Footer bar
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Mic button
                                      GestureDetector(
                                        onTap: _toggleRecordingContext,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (_isRecordingContext)
                                              AnimatedBuilder(
                                                animation: _pulseControllerContext,
                                                builder: (context, child) {
                                                  return Container(
                                                    width: 32 + (20 * _pulseControllerContext.value),
                                                    height: 32 + (20 * _pulseControllerContext.value),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFEF4444).withValues(alpha: 0.2 * (1 - _pulseControllerContext.value)),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  );
                                                },
                                              ),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _isRecordingContext ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _isRecordingContext ? LucideIcons.micOff : LucideIcons.mic,
                                                color: _isRecordingContext ? Colors.white : const Color(0xFF1D2848),
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // AI Improve button
                                      FilledButton.icon(
                                        onPressed: _contextController.text.isEmpty || _isAILoadingContext ? null : _improveContextText,
                                        icon: _isAILoadingContext
                                            ? const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(LucideIcons.sparkles, size: 12),
                                        label: const Text(
                                          "Mejorar con IA",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF1D2848),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(0, 30),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${_contextController.text.length} caracteres",
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isAILoadingContext)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // "Siguiente" sub-button to activate follow up field
                  if (!_isFollowUpActive)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isFollowUpActive = true;
                          });
                          // Scroll down to reveal the follow up field
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                        icon: const Icon(LucideIcons.arrowDown, size: 14),
                        label: const Text(
                          "Siguiente (Seguimiento)",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),

                  // Follow up field 2 (revealed dynamically)
                  if (_isFollowUpActive) ...[
                    const SizedBox(height: 14),
                    const Text(
                      "Plan de Seguimiento / Acciones posteriores (Opcional)",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isRecordingFollowUp ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                              width: _isRecordingFollowUp ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _followUpController,
                                maxLines: 4,
                                onChanged: (val) {
                                  final map = Map<String, String>.from(widget.measureFollowUps);
                                  map['General'] = val;
                                  widget.onFollowUpsChanged(map);
                                },
                                decoration: InputDecoration(
                                  hintText: _isRecordingFollowUp
                                      ? "Escuchando... hable ahora."
                                      : "¿Qué se hará después de tomar las medidas?",
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: _isRecordingFollowUp ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                    fontStyle: _isRecordingFollowUp ? FontStyle.italic : FontStyle.normal,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D2848)),
                              ),
                              // Footer bar
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Mic button
                                        GestureDetector(
                                          onTap: _toggleRecordingFollowUp,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              if (_isRecordingFollowUp)
                                                AnimatedBuilder(
                                                  animation: _pulseControllerFollowUp,
                                                  builder: (context, child) {
                                                    return Container(
                                                      width: 32 + (20 * _pulseControllerFollowUp.value),
                                                      height: 32 + (20 * _pulseControllerFollowUp.value),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEF4444).withValues(alpha: 0.2 * (1 - _pulseControllerFollowUp.value)),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: _isRecordingFollowUp ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _isRecordingFollowUp ? LucideIcons.micOff : LucideIcons.mic,
                                                  color: _isRecordingFollowUp ? Colors.white : const Color(0xFF1D2848),
                                                  size: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // AI Improve button
                                        FilledButton.icon(
                                          onPressed: _followUpController.text.isEmpty || _isAILoadingFollowUp ? null : _improveFollowUpText,
                                          icon: _isAILoadingFollowUp
                                              ? const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : const Icon(LucideIcons.sparkles, size: 12),
                                          label: const Text(
                                            "Mejorar con IA",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: const Color(0xFF1D2848),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(0, 30),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${_followUpController.text.length} caracteres",
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isAILoadingFollowUp)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D2848)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
