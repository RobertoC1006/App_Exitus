import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final MockDatabase _db = MockDatabase();

  void _simulateScan() {
    showDialog(
      context: context,
      builder: (context) {
        return const BarcodeScannerSimulationDialog();
      },
    ).then((scannedItemName) {
      if (!mounted) return;
      if (scannedItemName != null && scannedItemName is String) {
        // Increment stock
        setState(() {
          final idx = _db.nurseStockItems.indexWhere((item) => item['name'] == scannedItemName);
          if (idx != -1) {
            final currentQty = _db.nurseStockItems[idx]['qty'] as int;
            final newQty = currentQty + 10;
            _db.nurseStockItems[idx]['qty'] = newQty;
            
            // Recalculate status
            if (newQty > 10) {
              _db.nurseStockItems[idx]['status'] = 'Stock OK';
            } else if (newQty > 3) {
              _db.nurseStockItems[idx]['status'] = 'Stock bajo';
            } else {
              _db.nurseStockItems[idx]['status'] = 'Stock crítico';
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "¡Escaneo Exitoso! Se añadieron +10 unidades a $scannedItemName.",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine overall health status
    final hasCritical = _db.nurseStockItems.any((item) => item['status'] == 'Stock crítico');
    final overallStatus = hasCritical ? 'Stock crítico' : 'Stock saludable';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2848),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Control de Stock",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.scanLine, color: Colors.white),
            tooltip: "Escanear Insumo",
            onPressed: _simulateScan,
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de estado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasCritical ? const Color(0xFFFFFDE7) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hasCritical ? const Color(0xFFFFF59D) : const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasCritical ? const Color(0xFFFFF59D) : const Color(0xFFA5D6A7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasCritical ? LucideIcons.alertTriangle : LucideIcons.briefcase,
                      color: hasCritical ? const Color(0xFFF57F17) : const Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overallStatus,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasCritical ? const Color(0xFFF57F17) : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCritical
                              ? "Hay algunos insumos críticos que requieren reposición inmediata."
                              : "Todos los insumos principales se encuentran disponibles y en buen estado.",
                          style: TextStyle(
                            fontSize: 11,
                            color: hasCritical ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Título sección
            Text(
              "Medicamentos e Insumos en Tópico",
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            // Listado de stock
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _db.nurseStockItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final item = _db.nurseStockItems[index];
                    final name = item['name'] as String;
                    final qty = item['qty'] as int;
                    final status = item['status'] as String;

                    Color badgeBg;
                    Color badgeText;
                    Color progressColor;
                    double percent = (qty / 40.0).clamp(0.0, 1.0);

                    if (status == 'Stock OK') {
                      badgeBg = const Color(0xFFE8F5E9);
                      badgeText = const Color(0xFF2E7D32);
                      progressColor = const Color(0xFF2E7D32);
                    } else if (status == 'Stock bajo') {
                      badgeBg = const Color(0xFFFFF3E0);
                      badgeText = const Color(0xFFE65100);
                      progressColor = const Color(0xFFF57C00);
                    } else {
                      badgeBg = const Color(0xFFFFEBEE);
                      badgeText = const Color(0xFFC62828);
                      progressColor = const Color(0xFFD32F2F);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: badgeText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "$qty u.",
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Enlace
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Accediendo a inventario extendido consolidado (Simulación)")),
                  );
                },
                icon: const Icon(LucideIcons.list, size: 14, color: Color(0xFF1D2848)),
                label: const Text(
                  "Ver inventario completo",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarcodeScannerSimulationDialog extends StatefulWidget {
  const BarcodeScannerSimulationDialog({super.key});

  @override
  State<BarcodeScannerSimulationDialog> createState() => _BarcodeScannerSimulationDialogState();
}

class _BarcodeScannerSimulationDialogState extends State<BarcodeScannerSimulationDialog> {
  double _laserPosition = 0.0;
  late Timer _timer;
  bool _movingDown = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_movingDown) {
          _laserPosition += 4.0;
          if (_laserPosition >= 160) {
            _movingDown = false;
          }
        } else {
          _laserPosition -= 4.0;
          if (_laserPosition <= 0) {
            _movingDown = true;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Simular Escáner de Stock",
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),
            const SizedBox(height: 10),
            
            // Scanner Window
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDC620), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Camera grid visual guide
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.qrCode, color: Colors.white24, size: 48),
                      ),
                    ),
                  ),
                  
                  // Scanning laser line
                  Positioned(
                    top: _laserPosition,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enfoque el código del insumo en el visor para escanear y reabastecer +10 unidades.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            
            // Buttons to select item to scan
            const Text(
              "SELECCIONAR PRODUCTO A ESCANEAR",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, "Alcohol 70%"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2848),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Alcohol 70%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, "Termómetros"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2848),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Termómetros", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
