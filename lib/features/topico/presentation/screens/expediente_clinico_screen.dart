import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpedienteClinicoScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ExpedienteClinicoScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ExpedienteClinicoScreen> createState() => _ExpedienteClinicoScreenState();
}

class _ExpedienteClinicoScreenState extends State<ExpedienteClinicoScreen> {
  String _selectedCategory = 'Todas';

  // Historial de atenciones médicas simuladas
  final List<Map<String, dynamic>> _allHistory = [
    {
      'patientName': 'TANIA CHUYE TAVARA',
      'date': '08/06/2026',
      'time': '10:15 AM',
      'nurse': 'Lic. Franco Flores',
      'motive': 'Dolor abdominal y náuseas leves',
      'vitals': {
        'temp': '37.8 °C',
        'fc': '88 BPM',
        'pa': '110/70 mmHg',
        'sat': '98%',
      },
      'vitalsStatus': 'Alerta', // Estable, Alerta, Crítico
      'diagnosis': 'Espasmo intestinal leve. Deshidratación leve.',
      'treatment': 'Viadil gotas (20 gotas) + Reposo de 30 min en camilla.',
      'destiny': 'Retorno a clase',
      'category': 'Dolor',
    },
    {
      'patientName': 'TANIA CHUYE TAVARA',
      'date': '02/06/2026',
      'time': '08:30 AM',
      'nurse': 'Lic. Franco Flores',
      'motive': 'Dificultad respiratoria leve y sibilancias',
      'vitals': {
        'temp': '36.5 °C',
        'fc': '92 BPM',
        'pa': '115/75 mmHg',
        'sat': '94%', // Bajo
      },
      'vitalsStatus': 'Alerta',
      'diagnosis': 'Crisis asmática leve desencadenada por frío.',
      'treatment': 'Salbutamol inhalador (2 puff) con aerocámara. Monitoreo por 20 min.',
      'destiny': 'Retorno a clase - Alerta a Tutor',
      'category': 'Respiratorio',
    },
    {
      'patientName': 'TANIA CHUYE TAVARA',
      'date': '15/05/2026',
      'time': '11:45 AM',
      'nurse': 'Lic. Sonia Rivas',
      'motive': 'Cefalea leve',
      'vitals': {
        'temp': '36.8 °C',
        'fc': '78 BPM',
        'pa': '105/65 mmHg',
        'sat': '99%',
      },
      'vitalsStatus': 'Estable',
      'diagnosis': 'Fatiga visual o cefalea tensional.',
      'treatment': 'Paracetamol 500mg (1 tableta) con agua. Reposo de 15 min.',
      'destiny': 'Retorno a clase',
      'category': 'Dolor',
    },
    {
      'patientName': 'XIOMARA LUCERO CHAPA CARRASCO',
      'date': '05/06/2026',
      'time': '02:10 PM',
      'nurse': 'Lic. Franco Flores',
      'motive': 'Traumatismo en tobillo derecho',
      'vitals': {
        'temp': '36.7 °C',
        'fc': '84 BPM',
        'pa': '120/80 mmHg',
        'sat': '98%',
      },
      'vitalsStatus': 'Estable',
      'diagnosis': 'Esguince leve de tobillo derecho por caída en Educación Física.',
      'treatment': 'Aplicación de compresa fría, vendaje elástico compresivo e Ibuprofeno 400mg.',
      'destiny': 'Derivado a domicilio / Apoderado recoge',
      'category': 'Trauma',
    },
    {
      'patientName': 'ANTHONY VELIZ PACHERRES',
      'date': '09/06/2026',
      'time': '11:00 AM',
      'nurse': 'Lic. Franco Flores',
      'motive': 'Excoriaciones en rodilla izquierda',
      'vitals': {
        'temp': '36.4 °C',
        'fc': '80 BPM',
        'pa': '118/78 mmHg',
        'sat': '99%',
      },
      'vitalsStatus': 'Estable',
      'diagnosis': 'Herida superficial dermoabrasiva.',
      'treatment': 'Limpieza y asepsia con cloruro de sodio, curación con gasa estéril y Furacín.',
      'destiny': 'Retorno a clase',
      'category': 'Curación',
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    final patientName = widget.patient['name'];
    return _allHistory.where((record) {
      if (record['patientName'] != patientName) return false;
      if (_selectedCategory == 'Todas') return true;
      return record['category'] == _selectedCategory;
    }).toList();
  }

  Color _getVitalsColor(String status) {
    switch (status) {
      case 'Crítico':
        return const Color(0xFFEF4444);
      case 'Alerta':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = _filteredHistory;
    final patient = widget.patient;
    final hasAllergies = patient['allergies'] != 'Ninguna';
    final hasAntecedents = patient['antecedents'] != 'Ninguno';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1D2848)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Expediente Clínico Digital",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ficha del Paciente (Card Superior)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: patient['role'] == 'Alumno' ? const Color(0xFFE0F2FE) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          patient['role'] == 'Alumno' ? LucideIcons.graduationCap : LucideIcons.briefcase,
                          color: patient['role'] == 'Alumno' ? const Color(0xFF0EA5E9) : const Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${patient['role']} • ${patient['grade']}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Grupo Sanguíneo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Grupo",
                            style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              patient['bloodType'],
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  
                  // Fila de datos informativos rápidos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn("DNI", patient['dni']),
                      _buildInfoColumn("F. Nacimiento", patient['birthDate']),
                      _buildInfoColumn("Seguro", patient['insurance']),
                      _buildInfoColumn("Apoderado", patient['phone']),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Alertas Médicas (Alergias e Antecedentes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (hasAllergies)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ALERGIAS CONOCIDAS",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC53030)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient['allergies'],
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF9B2C2C), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (hasAntecedents)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.activity, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ANTECEDENTES / ENFERMEDADES CRÓNICAS",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient['antecedents'],
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Sección Historial Clínico
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historial de Consultas",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2848),
                    ),
                  ),
                  // Contador
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${history.length} visitas",
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),

            // Filtro por Categoría de Visitas
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Todas', 'Dolor', 'Respiratorio', 'Trauma', 'Curación'].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0EA5E9),
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Línea de Tiempo (Timeline)
            history.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.fileText, size: 36, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 10),
                        const Text(
                          "No hay registros clínicos para esta categoría.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final vitals = item['vitals'] as Map<String, String>;
                      final vitColor = _getVitalsColor(item['vitalsStatus']);

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Indicador de Timeline
                            Column(
                              children: [
                                Container(
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    color: vitColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: vitColor.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: index == history.length - 1 ? Colors.transparent : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            
                            // Tarjeta de Consulta
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fila Superior: Fecha y Atendido Por
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${item['date']} • ${item['time']}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0EA5E9),
                                          ),
                                        ),
                                        Text(
                                          item['nurse'],
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Motivo
                                    Text(
                                      "Motivo: ${item['motive']}",
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1D2848),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    // Signos Vitales (Triaje rápido)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildVitalBadge("Temp", vitals['temp']!, LucideIcons.thermometer, vitColor),
                                          _buildVitalBadge("Pulso", vitals['fc']!, LucideIcons.heart, vitColor),
                                          _buildVitalBadge("P. Art", vitals['pa']!, LucideIcons.activity, vitColor),
                                          _buildVitalBadge("O2 Sat", vitals['sat']!, LucideIcons.activity, vitColor),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    // Diagnóstico
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF1D2848), height: 1.3),
                                        children: [
                                          const TextSpan(text: "Diagnóstico: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: item['diagnosis']),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    
                                    // Tratamiento
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF1D2848), height: 1.3),
                                        children: [
                                          const TextSpan(text: "Tratamiento: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                                          TextSpan(text: item['treatment']),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 10),
                                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    const SizedBox(height: 8),
                                    
                                    // Destino final
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.checkSquare, size: 12, color: Color(0xFF10B981)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Destino: ${item['destiny']}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalBadge(String title, String val, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 8, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
            Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
