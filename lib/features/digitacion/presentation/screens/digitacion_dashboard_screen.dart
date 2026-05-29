import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'digitacion_form_screen.dart';

class DigitacionDashboardScreen extends StatefulWidget {
  const DigitacionDashboardScreen({super.key});

  @override
  State<DigitacionDashboardScreen> createState() => _DigitacionDashboardScreenState();
}

class _DigitacionDashboardScreenState extends State<DigitacionDashboardScreen> {
  final MockDatabase _db = MockDatabase();
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _db.getPrintRequests();

    // Calcular KPIs
    final pendingCount = jobs.where((j) => j.status == 'pending').length;
    final processingCount = jobs.where((j) => j.status == 'processing').length;
    final readyCount = jobs.where((j) => j.status == 'ready').length;
    final completedCount = jobs.where((j) => j.status == 'completed').length;

    // Filtrar jobs
    final filteredJobs = jobs.where((j) {
      final matchesStatus = _selectedStatusFilter == 'all' || j.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          j.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.ticketNumber.contains(_searchQuery) ||
          j.requester.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1D2848)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Centro de Impresiones",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2848),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Cabecera Informativa
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Área de Digitación",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gestiona y monitorea tus solicitudes de exámenes y fichas.",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 2. Grid de KPIs
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.1,
                children: [
                  _buildKpiCard("Pendiente", "$pendingCount", "pending", const Color(0xFF2196F3)),
                  _buildKpiCard("En Proceso", "$processingCount", "processing", const Color(0xFFF59E0B)),
                  _buildKpiCard("Listo", "$readyCount", "ready", const Color(0xFFEC4899)),
                  _buildKpiCard("Completo", "$completedCount", "completed", const Color(0xFF10B981)),
                ],
              ),
            ),

            // 3. Barra de búsqueda y Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                              style: const TextStyle(fontSize: 12.5),
                              decoration: const InputDecoration(
                                hintText: "Buscar ticket o título...",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1D2848), fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text("TODOS")),
                          DropdownMenuItem(value: 'pending', child: Text("PENDIENTE")),
                          DropdownMenuItem(value: 'processing', child: Text("PROCESO")),
                          DropdownMenuItem(value: 'ready', child: Text("LISTO")),
                          DropdownMenuItem(value: 'completed', child: Text("COMPLETO")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStatusFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Lista de Solicitudes
            Expanded(
              child: filteredJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.fileText, size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            "No se encontraron solicitudes.",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        final classroomsText = job.classrooms.map((c) => "${c.name} (${c.copies} ej.)").join(', ');

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "#${job.ticketNumber}",
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D2848),
                                      ),
                                    ),
                                    _buildStatusBadge(job.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2848),
                                  ),
                                ),
                                if (job.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    job.description,
                                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.printer, size: 12, color: Color(0xFF64748B)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "${job.colorMode.toUpperCase()} • ${job.paperSize} • $classroomsText",
                                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Fecha: ${job.date}",
                                      style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.edit2, size: 13),
                                          onPressed: () => _editJob(job),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            foregroundColor: const Color(0xFF1D2848),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2, size: 13),
                                          onPressed: () => _deleteJob(job),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFEBEE),
                                            foregroundColor: const Color(0xFFD32F2F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DigitacionFormScreen(
                  onSaved: _refresh,
                ),
              ),
            );
          },
          icon: const Icon(LucideIcons.plusCircle),
          label: const Text("NUEVA SOLICITUD DE IMPRESIÓN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D2848),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, String status, Color color) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = isSelected ? 'all' : status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'pending':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        text = "PENDIENTE";
        break;
      case 'processing':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        text = "EN PROCESO";
        break;
      case 'ready':
        bg = const Color(0xFFFCE7F3);
        fg = const Color(0xFFDB2777);
        text = "ESPERA ENTREGA";
        break;
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        text = "COMPLETADO";
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _editJob(PrintRequest job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DigitacionFormScreen(
          request: job,
          onSaved: _refresh,
        ),
      ),
    );
  }

  void _deleteJob(PrintRequest job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Solicitud", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          content: Text("¿Está seguro que desea eliminar la solicitud de impresión \"#${job.ticketNumber} - ${job.title}\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                _db.deletePrintRequest(job.id);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solicitud eliminada correctamente")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
              child: const Text("ELIMINAR"),
            ),
          ],
        );
      },
    );
  }
}
