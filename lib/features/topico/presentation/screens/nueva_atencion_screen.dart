import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class NuevaAtencionScreen extends StatefulWidget {
  final User currentUser;
  final String? patientName;
  final String? patientDni;
  final Function(Map<String, dynamic>)? onSave;

  const NuevaAtencionScreen({
    super.key,
    required this.currentUser,
    this.patientName,
    this.patientDni,
    this.onSave,
  });

  @override
  State<NuevaAtencionScreen> createState() => _NuevaAtencionScreenState();
}

class _NuevaAtencionScreenState extends State<NuevaAtencionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selección de Paciente
  late String _selectedPatientName;
  late String _selectedPatientDni;
  
  // Lista de pacientes para seleccionar si no se especifican en constructor
  final List<Map<String, String>> _availablePatients = [
    {'name': 'TANIA CHUYE TAVARA', 'dni': '76277884'},
    {'name': 'XIOMARA LUCERO CHAPA CARRASCO', 'dni': 'A20220095'},
    {'name': 'ANTHONY VELIZ PACHERRES', 'dni': '73829102'},
    {'name': 'DIANA CHUQUIHUANGA RAMIREZ', 'dni': '02847192'},
  ];

  // Motivos de consulta - Chips de un solo toque
  final List<String> _motiveOptions = [
    'Dolor de cabeza',
    'Dolor estomacal',
    'Fiebre / Alza térmica',
    'Golpe / Contusión',
    'Corte / Excoriación',
    'Náuseas / Vómitos',
    'Alergia / Urticaria',
    'Resfriado / Tos',
    'Malestar general',
  ];
  final Set<String> _selectedMotives = {};
  final TextEditingController _customMotiveController = TextEditingController();

  // Signos Vitales con Smart Defaults
  double _temp = 36.5;
  int _fc = 80;
  String _pa = '120/80';
  int _sat = 98;

  // Estado de Telemetría Bluetooth Sim
  bool _isConnectingBluetooth = false;

  // Inventario de medicamentos para receta rápida
  final List<Map<String, dynamic>> _medicationInventory = [
    {'name': 'Paracetamol 500mg', 'unit': 'Tableta(s)'},
    {'name': 'Viadil gotas', 'unit': 'Gota(s)'},
    {'name': 'Ibuprofeno 400mg', 'unit': 'Tableta(s)'},
    {'name': 'Salbutamol Inhalador', 'unit': 'Dosis (Puff)'},
    {'name': 'Furacín Crema', 'unit': 'Aplicación'},
    {'name': 'Alcohol en gel / Cloruro de Sodio', 'unit': 'Curación'},
  ];
  
  String? _selectedMedication;
  int _medicationQty = 1;
  final List<Map<String, dynamic>> _prescribedMedications = [];

  // Evolución, Clasificación y Destino
  String _classification = 'Ambulatoria'; // Ambulatoria, Derivación, Emergencia
  String _destiny = 'Alta (Retorno a aula)';
  final TextEditingController _evolutionController = TextEditingController();
  bool _notifyApoderado = true;

  @override
  void initState() {
    super.initState();
    _selectedPatientName = widget.patientName ?? _availablePatients[0]['name']!;
    _selectedPatientDni = widget.patientDni ?? _availablePatients[0]['dni']!;
  }

  // Simulación de lectura Bluetooth/Wearable
  void _simulateBluetoothReading() {
    setState(() {
      _isConnectingBluetooth = true;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isConnectingBluetooth = false;
          // Valores estables tomados simuladamente
          _temp = 36.7;
          _fc = 76;
          _pa = '118/76';
          _sat = 99;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(LucideIcons.bluetooth, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Signos vitales sincronizados mediante Telemetría Bluetooth."),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    });
  }

  // Clasificación de Colores para Signos Vitales
  Color _getTempColor() {
    if (_temp >= 38.0) return const Color(0xFFEF4444); // Crítico
    if (_temp >= 37.3) return const Color(0xFFF57C00); // Precaución
    return const Color(0xFF10B981); // Estable
  }

  Color _getFcColor() {
    if (_fc >= 100 || _fc <= 55) return const Color(0xFFEF4444);
    if (_fc >= 90 || _fc <= 60) return const Color(0xFFF57C00);
    return const Color(0xFF10B981);
  }

  Color _getPaColor() {
    if (_pa == '140/90') return const Color(0xFFEF4444);
    if (_pa == '130/85') return const Color(0xFFF57C00);
    return const Color(0xFF10B981);
  }

  Color _getSatColor() {
    if (_sat <= 92) return const Color(0xFFEF4444);
    if (_sat <= 94) return const Color(0xFFF57C00);
    return const Color(0xFF10B981);
  }

  void _addMedication() {
    if (_selectedMedication == null) return;
    
    final med = _medicationInventory.firstWhere((element) => element['name'] == _selectedMedication);
    
    setState(() {
      _prescribedMedications.add({
        'name': med['name'],
        'qty': _medicationQty,
        'unit': med['unit'],
      });
      _selectedMedication = null;
      _medicationQty = 1;
    });
  }

  void _saveAttention() {
    if (!_formKey.currentState!.validate()) return;
    
    final motivesList = [..._selectedMotives];
    if (_customMotiveController.text.isNotEmpty) {
      motivesList.add(_customMotiveController.text.trim());
    }

    final motivesStr = motivesList.isEmpty ? 'Consulta General' : motivesList.join(', ');

    final newAttention = {
      'name': _selectedPatientName,
      'dni': 'DNI: $_selectedPatientDni',
      'time': '10/06/2026 12:30', // Hora local actual mockeada
      'type': _classification,
      'status': 'Alta',
      'motive': motivesStr,
    };

    if (widget.onSave != null) {
      widget.onSave!(newAttention);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Atención registrada con éxito para $_selectedPatientName"),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPatientLocked = widget.patientName != null;

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
          "Nueva Atención de Enfermería",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // SECCIÓN 1: Selección de Paciente
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.user, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text(
                              "Paciente a Atender",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        isPatientLocked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.lock, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "$_selectedPatientName (DNI: $_selectedPatientDni)",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1D2848),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                initialValue: _selectedPatientName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: _availablePatients.map((p) {
                                  return DropdownMenuItem<String>(
                                    value: p['name'],
                                    child: Text(
                                      "${p['name']} (DNI: ${p['dni']})",
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final match = _availablePatients.firstWhere((p) => p['name'] == val);
                                    setState(() {
                                      _selectedPatientName = val;
                                      _selectedPatientDni = match['dni']!;
                                    });
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // SECCIÓN 2: Motivos de Consulta (Chips de un solo toque)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Motivo de Consulta (Selección rápida)",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _motiveOptions.map((opt) {
                            final isSelected = _selectedMotives.contains(opt);
                            return FilterChip(
                              label: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0EA5E9),
                              backgroundColor: const Color(0xFFF1F5F9),
                              checkmarkColor: Colors.white,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedMotives.add(opt);
                                  } else {
                                    _selectedMotives.remove(opt);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customMotiveController,
                          decoration: const InputDecoration(
                            labelText: "Otro motivo específico...",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // SECCIÓN 3: Signos Vitales (UX Optimizada)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Signos Vitales y Triaje",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                            
                            // Botón Telemetría Bluetooth
                            InkWell(
                              onTap: _simulateBluetoothReading,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFBAE6FD)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.bluetooth, color: Color(0xFF0284C7), size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Autocompletar Telemetría",
                                      style: GoogleFonts.outfit(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Los campos se precargan con rangos estables. Toque los chips para modificar rápidamente.",
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),

                        // A. Temperatura
                        _buildVitalRow(
                          title: "Temperatura",
                          value: "${_temp.toStringAsFixed(1)} °C",
                          icon: LucideIcons.thermometer,
                          statusColor: _getTempColor(),
                          chips: [36.0, 36.5, 37.0, 37.5, 38.0, 38.5, 39.0].map((t) {
                            return _buildQuickChip("${t.toStringAsFixed(1)}°", _temp == t, () {
                              setState(() => _temp = t);
                            });
                          }).toList(),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // B. Frecuencia Cardíaca
                        _buildVitalRow(
                          title: "Pulso / F. Cardíaca",
                          value: "$_fc BPM",
                          icon: LucideIcons.heart,
                          statusColor: _getFcColor(),
                          chips: [60, 70, 80, 90, 100, 110].map((f) {
                            return _buildQuickChip("$f", _fc == f, () {
                              setState(() => _fc = f);
                            });
                          }).toList(),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // C. Presión Arterial
                        _buildVitalRow(
                          title: "Presión Arterial",
                          value: "$_pa mmHg",
                          icon: LucideIcons.activity,
                          statusColor: _getPaColor(),
                          chips: ['110/70', '120/80', '130/85', '140/90'].map((p) {
                            return _buildQuickChip(p, _pa == p, () {
                              setState(() => _pa = p);
                            });
                          }).toList(),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // D. Saturación O2
                        _buildVitalRow(
                          title: "Saturación O2",
                          value: "$_sat %",
                          icon: LucideIcons.activity,
                          statusColor: _getSatColor(),
                          chips: [92, 94, 96, 98, 100].map((s) {
                            return _buildQuickChip("$s%", _sat == s, () {
                              setState(() => _sat = s);
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // SECCIÓN 4: Medicación Aplicada
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Medicamentos / Insumos Entregados",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedMedication,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: "Medicamento",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: _medicationInventory.map((m) {
                                  return DropdownMenuItem<String>(
                                    value: m['name'],
                                    child: Text(m['name'], style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedMedication = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Cant",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                initialValue: "1",
                                onChanged: (v) {
                                  _medicationQty = int.tryParse(v) ?? 1;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _addMedication,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0EA5E9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        
                        if (_prescribedMedications.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            "Lista de Medicamentos Añadidos:",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _prescribedMedications.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _prescribedMedications[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("${item['qty']} ${item['unit']}", style: const TextStyle(fontSize: 11.5)),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _prescribedMedications.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // SECCIÓN 5: Clasificación y Destino
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Evolución y Destino Paciente",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _classification,
                          decoration: const InputDecoration(
                            labelText: "Clasificación Atención",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Ambulatoria', child: Text('Ambulatoria (Leve)')),
                            DropdownMenuItem(value: 'Derivación', child: Text('Derivación a Domicilio')),
                            DropdownMenuItem(value: 'Emergencia', child: Text('Emergencia Médica (Grave)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _classification = val;
                                if (val == 'Derivación') {
                                  _destiny = 'Derivado a domicilio';
                                } else if (val == 'Emergencia') {
                                  _destiny = 'Traslado a clínica/hospital';
                                } else {
                                  _destiny = 'Alta (Retorno a aula)';
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _destiny,
                          decoration: const InputDecoration(
                            labelText: "Destino Final",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Alta (Retorno a aula)', child: Text('Alta (Retorno a aula)')),
                            DropdownMenuItem(value: 'Reposo temporal en camilla', child: Text('Reposo temporal en camilla')),
                            DropdownMenuItem(value: 'Derivado a domicilio', child: Text('Derivado a domicilio')),
                            DropdownMenuItem(value: 'Traslado a clínica/hospital', child: Text('Traslado a clínica/hospital')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _destiny = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _evolutionController,
                          decoration: const InputDecoration(
                            labelText: "Notas de Evolución y Observaciones",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title: const Text(
                            "Notificar Apoderado automáticamente",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Envía un reporte PDF con el triaje y medicamentos aplicados vía WhatsApp/SMS.",
                            style: TextStyle(fontSize: 9.5),
                          ),
                          value: _notifyApoderado,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: (val) => setState(() => _notifyApoderado = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BOTONES DE CONTROL FINAL
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF64748B)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveAttention,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D2848),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Guardar Registro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Indicador de Conexión Bluetooth Overlay
          if (_isConnectingBluetooth)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Sincronizando...",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Escaneando dispositivos de telemetría médica en el consultorio...",
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget fila de signos vitales
  Widget _buildVitalRow({
    required String title,
    required String value,
    required IconData icon,
    required Color statusColor,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: statusColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
      ],
    );
  }

  // Widget chip de un toque
  Widget _buildQuickChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF0EA5E9),
        backgroundColor: const Color(0xFFF1F5F9),
        onSelected: (selected) {
          if (selected) onTap();
        },
      ),
    );
  }
}
