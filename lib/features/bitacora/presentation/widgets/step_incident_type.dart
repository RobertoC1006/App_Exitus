import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StepIncidentType extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onCancel;

  const StepIncidentType({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTallScreen = screenHeight > 800;

    final double topSpacing = isTallScreen ? 32.0 : 16.0;
    final double headerSpacing = isTallScreen ? 36.0 : 24.0;
    final double cardBottomMargin = isTallScreen ? 20.0 : 14.0;
    final double cardVerticalPadding = isTallScreen ? 22.0 : 12.0;
    final double cancelSpacing = isTallScreen ? 40.0 : 16.0;

    final List<Map<String, dynamic>> options = [
      {
        'type': 'Conductual',
        'desc': 'Normas y comportamientos',
        'icon': LucideIcons.fileText,
        'color': const Color(0xFFFFB03B),
        'bgColor': const Color(0xFFFFF7ED),
        'borderColor': const Color(0xFFFFE3E3),
      },
      {
        'type': 'Relacional',
        'desc': 'Relaciones y convivencia',
        'icon': LucideIcons.heart,
        'color': const Color(0xFFEF4444),
        'bgColor': const Color(0xFFFEF2F2),
        'borderColor': const Color(0xFFFEE2E2),
      },
      {
        'type': 'Física',
        'desc': 'Situaciones que involucran contacto físico',
        'icon': LucideIcons.shieldAlert,
        'color': const Color(0xFF3B82F6),
        'bgColor': const Color(0xFFEFF6FF),
        'borderColor': const Color(0xFFDBEAFE),
      },
      {
        'type': 'Digital',
        'desc': 'Uso inadecuado de TIC o dispositivos',
        'icon': LucideIcons.laptop,
        'color': const Color(0xFF10B981),
        'bgColor': const Color(0xFFECFDF5),
        'borderColor': const Color(0xFFD1FAE5),
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSpacing),
          Text(
            "¿Qué tipo de incidencia quieres registrar?",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Selecciona la naturaleza principal de lo ocurrido.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          SizedBox(height: headerSpacing),

          // Cards list
          ...options.map((opt) {
            final isSelected = selectedType == opt['type'];
            return Container(
              margin: EdgeInsets.only(bottom: cardBottomMargin),
              decoration: BoxDecoration(
                color: opt['bgColor'],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? opt['color'] : const Color(0xFFE2E8F0),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (opt['color'] as Color).withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: ListTile(
                onTap: () => onTypeSelected(opt['type']),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: cardVerticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  opt['type'],
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    opt['desc'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    opt['icon'],
                    color: opt['color'],
                    size: 20,
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: cancelSpacing),

          // Cancel text button
          Center(
            child: TextButton(
              onPressed: onCancel,
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
