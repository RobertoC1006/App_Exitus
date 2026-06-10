import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class StaffRoleDashboard extends StatelessWidget {
  final String role;
  final User user;

  const StaffRoleDashboard({
    super.key,
    required this.role,
    required this.user,
  });

  String _getRoleDisplayName(String r) {
    switch (r) {
      case 'biblioteca':
        return 'Biblioteca';
      case 'topico':
        return 'Enfermería / Tópico';
      case 'tesoreria':
        return 'Tesorería';
      case 'eventos':
        return 'Eventos';
      case 'convivencia':
        return 'Convivencia';
      default:
        return r[0].toUpperCase() + r.substring(1);
    }
  }

  Color _getRoleColor(String r) {
    switch (r) {
      case 'biblioteca':
        return const Color(0xFF3F51B5); // Indigo
      case 'topico':
        return const Color(0xFFEF4444); // Red
      case 'tesoreria':
        return const Color(0xFF10B981); // Emerald Green
      case 'eventos':
        return const Color(0xFF9C27B0); // Purple
      case 'convivencia':
        return const Color(0xFFF57C00); // Orange
      default:
        return const Color(0xFF1D2848);
    }
  }

  List<Map<String, dynamic>> _getMetrics(String r) {
    switch (r) {
      case 'biblioteca':
        return [
          {'title': 'Prestados hoy', 'value': '12', 'icon': LucideIcons.bookUp, 'desc': '+3 que ayer'},
          {'title': 'Devoluciones', 'value': '5', 'icon': LucideIcons.bookDown, 'desc': 'Pendientes: 2'},
          {'title': 'Nuevos libros', 'value': '8', 'icon': LucideIcons.plusCircle, 'desc': 'Esta semana'},
        ];
      case 'topico':
        return [
          {'title': 'Atenciones hoy', 'value': '2', 'icon': LucideIcons.heartPulse, 'desc': 'Leves: 2'},
          {'title': 'Med. entregados', 'value': '15', 'icon': LucideIcons.pill, 'desc': 'Autorizados'},
          {'title': 'Derivados', 'value': '1', 'icon': LucideIcons.ambulance, 'desc': 'Psicología'},
        ];
      case 'tesoreria':
        return [
          {'title': 'Cobrado hoy', 'value': 'S/. 1,200', 'icon': LucideIcons.banknote, 'desc': '3 transacciones'},
          {'title': 'Por cobrar', 'value': '14', 'icon': LucideIcons.clock, 'desc': 'Alumnos mayo'},
          {'title': 'Boletas emitidas', 'value': '12', 'icon': LucideIcons.receipt, 'desc': 'Hoy'},
        ];
      case 'eventos':
        return [
          {'title': 'Próximos eventos', 'value': '3', 'icon': LucideIcons.calendarDays, 'desc': 'Esta semana'},
          {'title': 'Confirmados', 'value': '45', 'icon': LucideIcons.checkSquare, 'desc': 'Padres e Hijos'},
          {'title': 'Aforo total', 'value': '200', 'icon': LucideIcons.users, 'desc': 'Auditorio Principal'},
        ];
      case 'convivencia':
        return [
          {'title': 'Casos activos', 'value': '4', 'icon': LucideIcons.folderOpen, 'desc': 'En seguimiento'},
          {'title': 'Reportes hoy', 'value': '1', 'icon': LucideIcons.alertTriangle, 'desc': 'Nivel medio'},
          {'title': 'Citaciones', 'value': '2', 'icon': LucideIcons.users, 'desc': 'Para mañana'},
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getActions(String r) {
    switch (r) {
      case 'biblioteca':
        return [
          {'label': 'Préstamo Rápido', 'icon': LucideIcons.plusCircle},
          {'label': 'Devolución de Libro', 'icon': LucideIcons.undo2},
          {'label': 'Buscador de Textos', 'icon': LucideIcons.search},
          {'label': 'Control de Stock', 'icon': LucideIcons.bookOpen},
        ];
      case 'topico':
        return [
          {'label': 'Registrar Incidente', 'icon': LucideIcons.filePlus2},
          {'label': 'Ficha Médica', 'icon': LucideIcons.contact},
          {'label': 'Historial Derivaciones', 'icon': LucideIcons.history},
          {'label': 'Medicamentos Autorizados', 'icon': LucideIcons.pill},
        ];
      case 'tesoreria':
        return [
          {'label': 'Registrar Cobro', 'icon': LucideIcons.wallet},
          {'label': 'Pensiones Pendientes', 'icon': LucideIcons.landmark},
          {'label': 'Historial de Boletas', 'icon': LucideIcons.fileSpreadsheet},
          {'label': 'Reporte Diario', 'icon': LucideIcons.barChart3},
        ];
      case 'eventos':
        return [
          {'label': 'Crear Nuevo Evento', 'icon': LucideIcons.calendarPlus},
          {'label': 'Calendario Actividades', 'icon': LucideIcons.calendarRange},
          {'label': 'Control de Asistencia', 'icon': LucideIcons.checkSquare},
          {'label': 'Gestión de Ambientes', 'icon': LucideIcons.map},
        ];
      case 'convivencia':
        return [
          {'label': 'Registrar Incidente', 'icon': LucideIcons.messageSquarePlus},
          {'label': 'Casos de Bitácora', 'icon': LucideIcons.folderHeart},
          {'label': 'Citación Apoderados', 'icon': LucideIcons.users},
          {'label': 'Plan Convivencia', 'icon': LucideIcons.notebook},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String roleName = _getRoleDisplayName(role);
    final Color roleColor = _getRoleColor(role);
    final metrics = _getMetrics(role);
    final actions = _getActions(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          roleName,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D2848),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF1D2848), size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Datos actualizados")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de Bienvenida con Mascota
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [roleColor.withOpacity(0.08), roleColor.withOpacity(0.02)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: roleColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mascot_digitacion.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(LucideIcons.user, size: 48, color: roleColor);
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "¡Hola ${user.fullName}!",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Estás operando en la vista de: $roleName",
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Métricas
            Text(
              "Resumen del Día",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(metrics.length, (index) {
                final metric = metrics[index];
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index > 0 ? 8 : 0,
                      right: index < metrics.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(metric['icon'], size: 16, color: roleColor),
                        const SizedBox(height: 8),
                        Text(
                          metric['value'],
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metric['title'],
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric['desc'],
                          style: TextStyle(
                            fontSize: 8,
                            color: roleColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Acciones Rápidas
            Text(
              "Operaciones Rápidas",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: List.generate(actions.length, (index) {
                final action = actions[index];
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Ejecutando: ${action['label']}"),
                        backgroundColor: roleColor,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(action['icon'], size: 18, color: roleColor),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          action['label'],
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
