import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/core/theme/app_theme.dart';
import 'package:app_exitus/features/grading/presentation/screens/grading_detail_screen.dart';

class GradingView extends StatefulWidget {
  const GradingView({super.key});

  @override
  State<GradingView> createState() => _GradingViewState();
}

class _GradingViewState extends State<GradingView> {
  final _db = MockDatabase();
  int _selectedFilter = 0; // 0: Pendientes, 1: Calificados

  @override
  Widget build(BuildContext context) {
    // Filtrar entregas
    final allSubmissions = _db.submissions;
    final filteredSubmissions = _selectedFilter == 0
        ? allSubmissions.where((s) => s.status == 'Pendiente').toList()
        : allSubmissions.where((s) => s.status == 'Calificado').toList();

    return Column(
      children: [
        // 1. Selector de Filtro (Pendientes vs Calificados)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.white,
          child: Row(
            children: [
              _buildFilterChip(0, "Pendientes", filteredSubmissions.length),
              const SizedBox(width: 12),
              _buildFilterChip(1, "Calificados", allSubmissions.where((s) => s.status == 'Calificado').length),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // 2. Lista de Entregas de Tareas
        Expanded(
          child: filteredSubmissions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredSubmissions.length,
                  itemBuilder: (context, index) {
                    final sub = filteredSubmissions[index];
                    final isPending = sub.status == 'Pendiente';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Navegar al detalle de calificación
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GradingDetailScreen(
                                submissionId: sub.id,
                                onGraded: () {
                                  setState(() {}); // Recargar lista al volver
                                },
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(sub.studentAvatar),
                                    radius: 18,
                                    backgroundColor: AppTheme.accentGold,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.studentName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF002244),
                                          ),
                                        ),
                                        Text(
                                          sub.date,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Nota o Indicador de Pendiente
                                  if (isPending)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Text(
                                        "Pendiente",
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Nota: ${sub.grade}",
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sub.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF002244),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label, int count) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002244) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF002244),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 0 ? LucideIcons.checkSquare : LucideIcons.folderOpen,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 0
                  ? "¡Excelente! No tienes tareas pendientes por calificar."
                  : "Aún no has calificado ninguna tarea en esta sesión.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
