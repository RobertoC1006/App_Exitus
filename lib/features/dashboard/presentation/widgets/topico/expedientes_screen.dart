import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpedientesScreen extends StatefulWidget {
  const ExpedientesScreen({super.key});

  @override
  State<ExpedientesScreen> createState() => _ExpedientesScreenState();
}

class _ExpedientesScreenState extends State<ExpedientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _records = [
    {
      'name': 'Juan Pérez Romero',
      'grade': '4° A Secundaria',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      'lastAttention': 'Hoy, 10:32 a. m.',
      'bloodType': 'O Rh+',
      'allergies': 'Ninguna',
      'vaccines': 'COVID-19 (3 dosis), Influenza, Tétanos',
      'history': [
        {'date': '05/06/2026', 'reason': 'Dolor estomacal severo', 'treatment': '15 min de reposo, infusión de manzanilla'},
        {'date': '12/04/2026', 'reason': 'Fiebre 38.5 °C', 'treatment': 'Derivación a casa, Paracetamol 500mg'}
      ]
    },
    {
      'name': 'Ana Torres Medina',
      'grade': '4° B Secundaria',
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      'lastAttention': 'Ayer, 03:15 p. m.',
      'bloodType': 'A Rh+',
      'allergies': 'Penicilina (Severa)',
      'vaccines': 'Completa',
      'history': [
        {'date': '04/06/2026', 'reason': 'Dolor de cabeza leve', 'treatment': 'Compresas frías, reposo de 20 min'},
        {'date': '20/03/2026', 'reason': 'Corte superficial en dedo', 'treatment': 'Limpieza con suero, alcohol y vendaje'}
      ]
    },
    {
      'name': 'Diego Ramos León',
      'grade': '3° C Secundaria',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100',
      'lastAttention': '02/06/2026',
      'bloodType': 'B Rh+',
      'allergies': 'Polvo, Ácaros',
      'vaccines': 'Completa',
      'history': [
        {'date': '02/06/2026', 'reason': 'Golpe en rodilla (recreo)', 'treatment': 'Hielo local, crema antiinflamatoria'},
      ]
    },
    {
      'name': 'Sofia Vargas Díaz',
      'grade': '5° A Secundaria',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      'lastAttention': '30/05/2026',
      'bloodType': 'O Rh-',
      'allergies': 'Ninguna',
      'vaccines': 'COVID-19 (4 dosis), Influenza',
      'history': [
        {'date': '30/05/2026', 'reason': 'Mareos y fatiga', 'treatment': 'Monitoreo de presión (95/60), rehidratación oral'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((rec) {
      final query = _searchQuery.toLowerCase().trim();
      return rec['name'].toString().toLowerCase().contains(query) ||
          rec['grade'].toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2848),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Expedientes Clínicos",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Buscador
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar alumno...",
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.slidersHorizontal, size: 18, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Listado
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      "No se encontraron expedientes coincidentes.",
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final record = filtered[index];
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(record['avatar']),
                          ),
                          title: Text(
                            record['name'],
                            style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                record['grade'],
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Última atención: ${record['lastAttention']}",
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                          trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Color(0xFF94A3B8)),
                          onTap: () => _showRecordDetailsModal(record),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetailsModal(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
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
                  
                  // Ficha de cabecera
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(record['avatar']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['name'],
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record['grade'],
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2848).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Grupo: ${record['bloodType']}",
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Información Clínica Estática
                        _buildSectionHeader("Información Clínica Básica"),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildDetailItem(LucideIcons.alertTriangle, "Alergias Conocidas", record['allergies'], const Color(0xFFEF4444)),
                                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                _buildDetailItem(LucideIcons.shieldAlert, "Calendario de Vacunas", record['vaccines'], const Color(0xFF10B981)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Historial de visitas
                        _buildSectionHeader("Historial de Consultas Médicas"),
                        const SizedBox(height: 8),
                        ...((record['history'] as List<Map<String, String>>).map((visit) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 6),
                                        Text(
                                          visit['date']!,
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "FINALIZADO",
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  visit['reason']!,
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Tratamiento: ${visit['treatment']!}",
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
