import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class InventarioTopicoScreen extends StatefulWidget {
  final User currentUser;

  const InventarioTopicoScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<InventarioTopicoScreen> createState() => _InventarioTopicoScreenState();
}

class _InventarioTopicoScreenState extends State<InventarioTopicoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';

  // Base de datos de inventario simulada y mutable
  final List<Map<String, dynamic>> _inventory = [
    {
      'id': '1',
      'name': 'Paracetamol 500mg',
      'category': 'Analgésicos',
      'stock': 150,
      'unit': 'Tabletas',
      'minStock': 50,
      'expiryDate': '12/2027',
      'status': 'OK',
    },
    {
      'id': '2',
      'name': 'Ibuprofeno 400mg',
      'category': 'Antiinflamatorios',
      'stock': 80,
      'unit': 'Tabletas',
      'minStock': 30,
      'expiryDate': '09/2027',
      'status': 'OK',
    },
    {
      'id': '3',
      'name': 'Viadil Gotas',
      'category': 'Antiespasmódicos',
      'stock': 12,
      'unit': 'Frascos',
      'minStock': 15,
      'expiryDate': '08/2026', // Próximo a vencer
      'status': 'Bajo',
    },
    {
      'id': '4',
      'name': 'Salbutamol Inhalador',
      'category': 'Respiratorio',
      'stock': 3,
      'unit': 'Frascos',
      'minStock': 5,
      'expiryDate': '10/2026',
      'status': 'Bajo',
    },
    {
      'id': '5',
      'name': 'Gasa Estéril 10x10',
      'category': 'Material Curación',
      'stock': 0,
      'unit': 'Sobres',
      'minStock': 25,
      'expiryDate': '01/2030',
      'status': 'Agotado',
    },
    {
      'id': '6',
      'name': 'Cloruro de Sodio 0.9%',
      'category': 'Soluciones',
      'stock': 25,
      'unit': 'Frascos',
      'minStock': 10,
      'expiryDate': '11/2028',
      'status': 'OK',
    },
  ];

  // Historial de movimientos simulados
  final List<Map<String, dynamic>> _movementsHistory = [
    {'date': '09/06/2026', 'type': 'Entrada', 'item': 'Paracetamol 500mg', 'qty': 100, 'responsible': 'Lic. Franco Flores'},
    {'date': '09/06/2026', 'type': 'Salida', 'item': 'Viadil Gotas', 'qty': 1, 'responsible': 'Lic. Franco Flores'},
    {'date': '08/06/2026', 'type': 'Salida', 'item': 'Paracetamol 500mg', 'qty': 2, 'responsible': 'Lic. Franco Flores'},
    {'date': '05/06/2026', 'type': 'Entrada', 'item': 'Ibuprofeno 400mg', 'qty': 50, 'responsible': 'Lic. Sonia Rivas'},
  ];

  // Cálculos dinámicos de métricas
  int get _totalItems => _inventory.length;
  int get _stockOkCount => _inventory.where((item) => item['stock'] >= item['minStock'] && item['stock'] > 0).length;
  int get _stockLowCount => _inventory.where((item) => item['stock'] < item['minStock'] && item['stock'] > 0).length;
  int get _stockEmptyCount => _inventory.where((item) => item['stock'] == 0).length;

  List<Map<String, dynamic>> get _filteredInventory {
    final query = _searchController.text.trim().toLowerCase();
    return _inventory.where((item) {
      if (_selectedCategory != 'Todos' && item['category'] != _selectedCategory) return false;
      if (query.isEmpty) return true;
      return item['name'].toLowerCase().contains(query) || item['category'].toLowerCase().contains(query);
    }).toList();
  }

  void _updateItemStatus(Map<String, dynamic> item) {
    int stock = item['stock'];
    int min = item['minStock'];
    if (stock == 0) {
      item['status'] = 'Agotado';
    } else if (stock < min) {
      item['status'] = 'Bajo';
    } else {
      item['status'] = 'OK';
    }
  }

  // DIÁLOGO: Entrada de Stock
  void _showEntradaStockDialog() {
    final formKey = GlobalKey<FormState>();
    String? selectedItemName;
    int qty = 0;
    String supplier = 'DIFARMA S.A.C.';
    String lotNotes = 'LOTE-2026';
    String responsible = widget.currentUser.fullName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(LucideIcons.packagePlus, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Registrar Entrada de Stock",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Medicamento / Insumo",
                      border: OutlineInputBorder(),
                    ),
                    items: _inventory.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['name'],
                        child: Text(item['name'], style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) => selectedItemName = val,
                    validator: (v) => v == null ? 'Selecciona un ítem' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Cantidad a Ingresar",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final parsed = int.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) return 'Ingrese número válido';
                      return null;
                    },
                    onSaved: (v) => qty = int.parse(v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: responsible,
                    decoration: const InputDecoration(
                      labelText: "Responsable Logística",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => responsible = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: supplier,
                    decoration: const InputDecoration(
                      labelText: "Proveedor",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => supplier = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: lotNotes,
                    decoration: const InputDecoration(
                      labelText: "Observación / Lote",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => lotNotes = v ?? '',
                  ),
                ],
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
                    final target = _inventory.firstWhere((item) => item['name'] == selectedItemName);
                    target['stock'] = target['stock'] + qty;
                    _updateItemStatus(target);
                    
                    _movementsHistory.insert(0, {
                      'date': '10/06/2026',
                      'type': 'Entrada',
                      'item': selectedItemName!,
                      'qty': qty,
                      'responsible': responsible,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Se ingresaron $qty unidades a $selectedItemName."),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Registrar Entrada", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // DIÁLOGO: Nuevo Medicamento / Ítem
  void _showNuevoItemDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String category = 'Analgésicos';
    String unit = 'Tabletas';
    int initialStock = 0;
    int minStock = 10;
    String expiryDate = '12/2028';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(LucideIcons.plusCircle, color: Color(0xFF0EA5E9), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Nuevo Medicamento / Insumo",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Nombre del Ítem",
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                    onSaved: (v) => name = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: "Categoría",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Analgésicos', child: Text('Analgésicos')),
                      DropdownMenuItem(value: 'Antiinflamatorios', child: Text('Antiinflamatorios')),
                      DropdownMenuItem(value: 'Antiespasmódicos', child: Text('Antiespasmódicos')),
                      DropdownMenuItem(value: 'Respiratorio', child: Text('Respiratorio')),
                      DropdownMenuItem(value: 'Material Curación', child: Text('Material de Curación')),
                      DropdownMenuItem(value: 'Soluciones', child: Text('Soluciones')),
                      DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                    ],
                    onChanged: (val) {
                      if (val != null) category = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: unit,
                    decoration: const InputDecoration(
                      labelText: "Unidad de Medida",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Tabletas', child: Text('Tabletas')),
                      DropdownMenuItem(value: 'Frascos', child: Text('Frascos')),
                      DropdownMenuItem(value: 'Sobres', child: Text('Sobres')),
                      DropdownMenuItem(value: 'Tubos', child: Text('Tubos / Pomadas')),
                      DropdownMenuItem(value: 'Unidades', child: Text('Unidades')),
                    ],
                    onChanged: (val) {
                      if (val != null) unit = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Stock Inicial",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: "0",
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Inválido' : null,
                          onSaved: (v) => initialStock = int.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Stock Mín Alerta",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: "10",
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Inválido' : null,
                          onSaved: (v) => minStock = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: expiryDate,
                    decoration: const InputDecoration(
                      labelText: "F. Vencimiento (MM/AAAA)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    onSaved: (v) => expiryDate = v ?? '',
                  ),
                ],
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
                    final newItem = {
                      'id': (int.parse(_inventory.last['id']) + 1).toString(),
                      'name': name,
                      'category': category,
                      'stock': initialStock,
                      'unit': unit,
                      'minStock': minStock,
                      'expiryDate': expiryDate,
                      'status': 'OK',
                    };
                    _updateItemStatus(newItem);
                    _inventory.add(newItem);

                    _movementsHistory.insert(0, {
                      'date': '10/06/2026',
                      'type': 'Entrada',
                      'item': name,
                      'qty': initialStock,
                      'responsible': widget.currentUser.fullName,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Medicamento $name registrado."),
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
  }

  // DIÁLOGO: Registrar Salida Manual
  void _showSalidaStockDialog(Map<String, dynamic> item) {
    final formKey = GlobalKey<FormState>();
    int qty = 0;
    String patientName = 'Consulta Ambulatoria';
    String reason = 'Uso clínico estándar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFEE2E2),
                child: Icon(LucideIcons.packageMinus, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Registrar Salida: ${item['name']}",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Stock actual: ${item['stock']} ${item['unit']}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Cantidad a Retirar",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final parsed = int.tryParse(v ?? '');
                    if (parsed == null || parsed <= 0) return 'Ingrese cantidad válida';
                    if (parsed > (item['stock'] as int)) return 'Excede el stock actual';
                    return null;
                  },
                  onSaved: (v) => qty = int.parse(v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: patientName,
                  decoration: const InputDecoration(
                    labelText: "Paciente / Destinatario",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (v) => patientName = v ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: reason,
                  decoration: const InputDecoration(
                    labelText: "Motivo / Diagnóstico",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (v) => reason = v ?? '',
                ),
              ],
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
                    item['stock'] = item['stock'] - qty;
                    _updateItemStatus(item);
                    
                    _movementsHistory.insert(0, {
                      'date': '10/06/2026',
                      'type': 'Salida',
                      'item': item['name'],
                      'qty': qty,
                      'responsible': widget.currentUser.fullName,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Retirado $qty ${item['unit']} de ${item['name']}."),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Confirmar Salida", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // DIÁLOGO: Historial de Transacciones de un Ítem
  void _showItemHistoryDialog(Map<String, dynamic> item) {
    final history = _movementsHistory.where((m) => m['item'] == item['name']).toList();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(LucideIcons.history, color: Color(0xFF1D2848), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Historial: ${item['name']}",
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
            width: double.maxFinite,
            child: history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No hay movimientos registrados recientemente.",
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final mov = history[idx];
                      final isEntrada = mov['type'] == 'Entrada';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          isEntrada ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                          color: isEntrada ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 16,
                        ),
                        title: Text(
                          "${mov['type']} de ${mov['qty']} ${item['unit']}",
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${mov['date']} • por ${mov['responsible']}",
                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: Color(0xFF1D2848), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredInventory;

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
          "Inventario y Farmacia",
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
          // 1. Resumen de Stock (Tarjetas Métricas)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _buildStockMetricCard("Total Items", "$_totalItems", LucideIcons.boxes, const Color(0xFF1D2848)),
                const SizedBox(width: 8),
                _buildStockMetricCard("Stock OK", "$_stockOkCount", LucideIcons.checkCircle2, const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildStockMetricCard("Bajo Alerta", "$_stockLowCount", LucideIcons.alertTriangle, const Color(0xFFF57C00)),
                const SizedBox(width: 8),
                _buildStockMetricCard("Agotados", "$_stockEmptyCount", LucideIcons.xCircle, const Color(0xFFEF4444)),
              ],
            ),
          ),
          
          // 2. Acciones del Inventario
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showEntradaStockDialog,
                    icon: const Icon(LucideIcons.packagePlus, size: 14, color: Colors.white),
                    label: const Text(
                      "Entrada Stock",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showNuevoItemDialog,
                    icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                    label: const Text(
                      "Nuevo Ítem",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Buscador y Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
                      hintText: "Buscar medicamento...",
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Analgésicos', 'Antiinflamatorios', 'Antiespasmódicos', 'Respiratorio', 'Material Curación', 'Soluciones'].map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFF1D2848),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 4. Tabla de Inventario
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.package, size: 40, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 10),
                        const Text(
                          "No se encontraron medicamentos",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final isLow = item['status'] == 'Bajo';
                      final isOut = item['status'] == 'Agotado';
                      
                      Color statusBg = const Color(0xFFE2E8F0);
                      Color statusFg = const Color(0xFF475569);
                      if (isLow) {
                        statusBg = const Color(0xFFFFF3E0);
                        statusFg = const Color(0xFFE65100);
                      } else if (isOut) {
                        statusBg = const Color(0xFFFEE2E2);
                        statusFg = const Color(0xFFEF4444);
                      } else {
                        statusBg = const Color(0xFFECFDF5);
                        statusFg = const Color(0xFF10B981);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  radius: 18,
                                  child: Icon(
                                    item['category'] == 'Material Curación' ? LucideIcons.bandage : LucideIcons.pill,
                                    size: 16,
                                    color: const Color(0xFF1D2848),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1D2848),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${item['category']} • Venc: ${item['expiryDate']}",
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${item['stock']} ${item['unit']}",
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1D2848),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['status'],
                                        style: TextStyle(
                                          color: statusFg,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showItemHistoryDialog(item),
                                  icon: const Icon(LucideIcons.history, size: 12, color: Color(0xFF64748B)),
                                  label: const Text("Historial", style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: item['stock'] > 0 ? () => _showSalidaStockDialog(item) : null,
                                  icon: const Icon(LucideIcons.minusSquare, size: 12, color: Color(0xFFEF4444)),
                                  label: const Text("Salida", style: TextStyle(fontSize: 9.5, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    disabledForegroundColor: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _inventory.removeWhere((i) => i['id'] == item['id']);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Eliminado ${item['name']} del inventario."),
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                    );
                                  },
                                  icon: const Icon(LucideIcons.trash2, size: 12, color: Color(0xFFEF4444)),
                                  label: const Text("Eliminar", style: TextStyle(fontSize: 9.5, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                ),
                              ],
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

  Widget _buildStockMetricCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 8.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
