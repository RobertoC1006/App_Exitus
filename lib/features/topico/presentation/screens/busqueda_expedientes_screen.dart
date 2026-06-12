import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'nueva_atencion_screen.dart';
import 'expediente_clinico_screen.dart';

class BusquedaExpedientesScreen extends StatefulWidget {
  final User currentUser;

  const BusquedaExpedientesScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<BusquedaExpedientesScreen> createState() => _BusquedaExpedientesScreenState();
}

class _BusquedaExpedientesScreenState extends State<BusquedaExpedientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todos'; // 'Todos', 'Alumnos', 'Personal'
  
  // Lista de pacientes simulados inicial
  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'TANIA CHUYE TAVARA',
      'role': 'Alumno',
      'grade': '4to de Primaria',
      'dni': '76277884',
      'birthDate': '12/04/2016',
      'phone': '987654321',
      'insurance': 'SIS',
      'allergies': 'Penicilina, Asma inducida por ejercicio',
      'bloodType': 'O+',
      'antecedents': 'Rinitis alérgica estacional',
      'attentionsCount': 5,
    },
    {
      'name': 'XIOMARA LUCERO CHAPA CARRASCO',
      'role': 'Alumno',
      'grade': '5to de Secundaria',
      'dni': 'A20220095',
      'birthDate': '03/08/2009',
      'phone': '954123876',
      'insurance': 'Rímac EPS',
      'allergies': 'Ninguna',
      'bloodType': 'A+',
      'antecedents': 'Ninguno',
      'attentionsCount': 2,
    },
    {
      'name': 'ANTHONY VELIZ PACHERRES',
      'role': 'Alumno',
      'grade': '3ro de Secundaria',
      'dni': '73829102',
      'birthDate': '22/11/2010',
      'phone': '941827364',
      'insurance': 'Pacífico Seguro',
      'allergies': 'Sulfas, Ibuprofeno',
      'bloodType': 'B+',
      'antecedents': 'Fractura de radio izquierdo (2024)',
      'attentionsCount': 1,
    },
    {
      'name': 'DIANA CHUQUIHUANGA RAMIREZ',
      'role': 'Docente',
      'grade': 'Primaria - Comunicaciones',
      'dni': '02847192',
      'birthDate': '15/09/1988',
      'phone': '912837465',
      'insurance': 'EsSalud',
      'allergies': 'Polvo, Polen',
      'bloodType': 'O+',
      'antecedents': 'Hipertensión controlada',
      'attentionsCount': 3,
    },
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.trim().toLowerCase();
    return _patients.where((patient) {
      // Filtro de rol/tipo
      if (_selectedFilter == 'Alumnos' && patient['role'] != 'Alumno') return false;
      if (_selectedFilter == 'Personal' && patient['role'] != 'Docente') return false;

      // Filtro de búsqueda
      if (query.isEmpty) return true;
      return patient['name'].toLowerCase().contains(query) ||
          patient['dni'].contains(query) ||
          patient['phone'].contains(query);
    }).toList();
  }

  void _showRegisterPatientDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String role = 'Alumno';
    String grade = '';
    String dni = '';
    String birthDate = '';
    String phone = '';
    String insurance = 'SIS';
    String allergies = '';
    String bloodType = 'O+';
    String antecedents = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(LucideIcons.userPlus, color: Color(0xFF0EA5E9), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Registrar Nuevo Paciente",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: role,
                          decoration: const InputDecoration(
                            labelText: "Tipo de Usuario",
                            prefixIcon: Icon(LucideIcons.userCheck, size: 18),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Alumno', child: Text('Alumno')),
                            DropdownMenuItem(value: 'Docente', child: Text('Docente / Personal')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                role = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Nombres y Apellidos Completos",
                            prefixIcon: Icon(LucideIcons.user, size: 18),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          onSaved: (v) => name = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "DNI",
                                  prefixIcon: Icon(LucideIcons.creditCard, size: 18),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.length < 8 ? '8 dígitos' : null,
                                onSaved: (v) => dni = v ?? '',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: role == 'Alumno' ? "Grado / Sección" : "Área / Cargo",
                                  prefixIcon: const Icon(LucideIcons.graduationCap, size: 18),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => grade = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "F. Nac (DD/MM/AAAA)",
                                  prefixIcon: Icon(LucideIcons.calendar, size: 18),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => birthDate = v ?? '',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Celular Contacto",
                                  prefixIcon: Icon(LucideIcons.phone, size: 18),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => phone = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: bloodType,
                                decoration: const InputDecoration(
                                  labelText: "Grupo Sanguíneo",
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                                ],
                                onChanged: (val) {
                                  if (val != null) bloodType = val;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Seguro Médico",
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: insurance,
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => insurance = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Alergias Conocidas",
                            prefixIcon: Icon(LucideIcons.alertTriangle, size: 18, color: Colors.orange),
                            border: OutlineInputBorder(),
                            helperText: "Separadas por comas. Ej: Penicilina, Nueces",
                          ),
                          onSaved: (v) => allergies = v ?? 'Ninguna',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Enfermedades Crónicas o Antecedentes",
                            prefixIcon: Icon(LucideIcons.activity, size: 18),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          onSaved: (v) => antecedents = v ?? 'Ninguno',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      setState(() {
                        _patients.insert(0, {
                          'name': name.toUpperCase(),
                          'role': role,
                          'grade': grade,
                          'dni': dni,
                          'birthDate': birthDate,
                          'phone': phone,
                          'insurance': insurance,
                          'allergies': allergies.isEmpty ? 'Ninguna' : allergies,
                          'bloodType': bloodType,
                          'antecedents': antecedents.isEmpty ? 'Ninguno' : antecedents,
                          'attentionsCount': 0,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Paciente $name registrado exitosamente."),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2848),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Guardar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditClinicalDataDialog(Map<String, dynamic> patient) {
    final formKey = GlobalKey<FormState>();
    String allergies = patient['allergies'];
    String bloodType = patient['bloodType'];
    String antecedents = patient['antecedents'];
    String insurance = patient['insurance'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(LucideIcons.edit3, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Datos Clínicos: ${patient['name']}",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: bloodType,
                      decoration: const InputDecoration(
                        labelText: "Grupo Sanguíneo",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'O+', child: Text('O+')),
                        DropdownMenuItem(value: 'O-', child: Text('O-')),
                        DropdownMenuItem(value: 'A+', child: Text('A+')),
                        DropdownMenuItem(value: 'A-', child: Text('A-')),
                        DropdownMenuItem(value: 'B+', child: Text('B+')),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      ],
                      onChanged: (val) {
                        if (val != null) bloodType = val;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: insurance,
                      decoration: const InputDecoration(
                        labelText: "Seguro Médico",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => insurance = v ?? '',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: allergies,
                      decoration: const InputDecoration(
                        labelText: "Alergias Conocidas",
                        prefixIcon: Icon(LucideIcons.alertTriangle, size: 18, color: Colors.orange),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => allergies = v ?? 'Ninguna',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: antecedents,
                      decoration: const InputDecoration(
                        labelText: "Enfermedades Crónicas / Antecedentes",
                        prefixIcon: Icon(LucideIcons.activity, size: 18),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (v) => antecedents = v ?? 'Ninguno',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  setState(() {
                    patient['allergies'] = allergies;
                    patient['bloodType'] = bloodType;
                    patient['antecedents'] = antecedents;
                    patient['insurance'] = insurance;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Expediente clínico actualizado."),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Actualizar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredPatients;

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
          "Búsqueda y Expedientes",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra superior de Búsqueda y Botón
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
                            hintText: "Buscar por Nombre, DNI o Teléfono...",
                            hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showRegisterPatientDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips de Filtro
                Row(
                  children: ['Todos', 'Alumnos', 'Personal'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1D2848),
                        backgroundColor: const Color(0xFFF1F5F9),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Listado de Pacientes
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.users, size: 48, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          "No se encontraron expedientes",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Verifica los términos de búsqueda o registra un nuevo paciente.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final patient = results[index];
                      final isAlert = patient['allergies'] != 'Ninguna';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cabecera de la Tarjeta del Paciente
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: patient['role'] == 'Alumno'
                                        ? const Color(0xFFE0F2FE)
                                        : const Color(0xFFECFDF5),
                                    radius: 20,
                                    child: Icon(
                                      patient['role'] == 'Alumno' ? LucideIcons.graduationCap : LucideIcons.briefcase,
                                      color: patient['role'] == 'Alumno' ? const Color(0xFF0EA5E9) : const Color(0xFF10B981),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient['name'],
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1D2848),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${patient['role']} • ${patient['grade']} • DNI: ${patient['dni']}",
                                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Contacto: ${patient['phone']} • Seg: ${patient['insurance']}",
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                        ),
                                        if (isAlert) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFFFE0B2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(LucideIcons.alertTriangle, size: 10, color: Color(0xFFE65100)),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    "Alergias: ${patient['allergies']}",
                                                    style: const TextStyle(
                                                      color: Color(0xFFE65100),
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Badge de Grupo Sanguíneo
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      patient['bloodType'],
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),

                            // Acciones de la Tarjeta del Paciente
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NuevaAtencionScreen(
                                            currentUser: widget.currentUser,
                                            patientName: patient['name'],
                                            patientDni: patient['dni'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(LucideIcons.activity, size: 13, color: Color(0xFF0EA5E9)),
                                    label: const Text(
                                      "Atención",
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                  Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExpedienteClinicoScreen(
                                            patient: patient,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(LucideIcons.folderHeart, size: 13, color: Color(0xFF1D2848)),
                                    label: const Text(
                                      "Expediente",
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                  Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                                  TextButton.icon(
                                    onPressed: () => _showEditClinicalDataDialog(patient),
                                    icon: const Icon(LucideIcons.edit3, size: 13, color: Color(0xFF64748B)),
                                    label: const Text(
                                      "Ficha Médica",
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
