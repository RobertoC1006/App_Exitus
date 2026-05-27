import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/home_view.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/attendance_view.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/grading_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  // Lista de vistas para cada pestaña
  final List<Widget> _views = const [
    HomeView(),
    AttendanceView(),
    GradingView(),
  ];

  // Títulos para la barra superior (AppBar) según la pestaña
  final List<String> _titles = const [
    "Portal Docente",
    "Registro de Asistencia",
    "Evaluación de Tareas",
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.logOut, color: Color(0xFFC0392B)),
            SizedBox(width: 8),
            Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("¿Estás seguro de que deseas salir del portal docente?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.white),
            tooltip: "Cerrar Sesión",
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF002244),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            activeIcon: Icon(LucideIcons.home, color: Color(0xFF002244)),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            activeIcon: Icon(LucideIcons.users, color: Color(0xFF002244)),
            label: "Asistencia",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.graduationCap),
            activeIcon: Icon(LucideIcons.graduationCap, color: Color(0xFF002244)),
            label: "Calificar",
          ),
        ],
      ),
    );
  }
}
