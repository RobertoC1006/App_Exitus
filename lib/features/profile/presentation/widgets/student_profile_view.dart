import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_exitus/features/profile/presentation/widgets/exitus_pay_modal.dart';

class StudentProfileView extends StatefulWidget {
  final User currentUser;
  final VoidCallback onLogout;

  const StudentProfileView({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> with SingleTickerProviderStateMixin {
  final MockDatabase _db = MockDatabase();

  // Variables para efecto holográfico 3D de la tarjeta
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _glowX = 0.5;
  double _glowY = 0.5;

  late AnimationController _resetController;
  late Animation<double> _animX;
  late Animation<double> _animY;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _resetController.addListener(() {
      setState(() {
        _rotateX = _animX.value;
        _rotateY = _animY.value;
        _glowX = 0.5 + (_rotateY * 1.5);
        _glowY = 0.5 - (_rotateX * 1.5);
      });
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _handleTilt(DragUpdateDetails details, Size cardSize) {
    if (_resetController.isAnimating) _resetController.stop();

    // Calcular posición relativa al centro de la tarjeta (-1.0 a 1.0)
    final localPos = details.localPosition;
    final relX = (localPos.dx / cardSize.width - 0.5) * 2.0;
    final relY = (localPos.dy / cardSize.height - 0.5) * 2.0;

    setState(() {
      // Inclinación máxima de 15 grados en radianes (aprox. 0.25)
      _rotateY = relX * 0.25;
      _rotateX = -relY * 0.25;

      // Centrar el brillo holográfico
      _glowX = localPos.dx / cardSize.width;
      _glowY = localPos.dy / cardSize.height;
    });
  }

  void _resetTilt() {
    _animX = Tween<double>(begin: _rotateX, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _animY = Tween<double>(begin: _rotateY, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _resetController.forward(from: 0.0);
  }

  void _showQRModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDC620), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D2848).withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pase Digital de Ingreso",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2848),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Contenedor QR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEDC620).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${widget.currentUser.id}',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback visual en caso de no tener red
                      return Container(
                        width: 180,
                        height: 180,
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(LucideIcons.qrCode, size: 48, color: Color(0xFF94A3B8)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  widget.currentUser.fullName.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2848),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Código: ${widget.currentUser.username.toUpperCase() == 'mateo123' ? 'EX-20260943' : 'EX-20261125'}",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5A93B),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.check, size: 12, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        "Pase Autorizado • Portería",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _triggerPayment(PensionItem pension) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExitusPayModal(
        userId: widget.currentUser.id,
        pension: pension,
        onPaymentComplete: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gradesAverage = widget.currentUser.username.contains('mateo') ? 17.8 : 19.2;
    final String userCode = widget.currentUser.username.contains('mateo') ? 'EX-20260943' : 'EX-20261125';
    final String userGrade = widget.currentUser.username.contains('mateo') ? '5° de Sec. - Aula A' : '2° de Prim. - Aula B';

    final pensions = _db.getPensionsForUser(widget.currentUser.id);
    const cardSize = Size(320, 180);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tarjeta Holográfica 3D Interactiva
          Center(
            child: GestureDetector(
              onPanUpdate: (details) => _handleTilt(details, cardSize),
              onPanEnd: (_) => _resetTilt(),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspectiva 3D
                  ..rotateX(_rotateX)
                  ..rotateY(_rotateY),
                alignment: FractionalOffset.center,
                child: Container(
                  width: cardSize.width,
                  height: cardSize.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D2848).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Fondo Degradado Frosted White
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFF6F8FB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                        // Capa de Brillo Holográfico Dinámico
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFEDC620).withOpacity(0.12),
                                  const Color(0xFF80DEEA).withOpacity(0.08),
                                  Colors.transparent,
                                ],
                                center: FractionalOffset(_glowX, _glowY),
                                radius: 0.8,
                              ),
                            ),
                          ),
                        ),

                        // Contenido de la Tarjeta
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cabecera de la Tarjeta
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1D2848),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "E",
                                          style: TextStyle(
                                            color: Color(0xFFEDC620),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Colegio Exitus",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D2848),
                                            ),
                                          ),
                                          Text(
                                            "CREDENCIAL DIGITAL",
                                            style: TextStyle(
                                              fontSize: 5.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF9098A7),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDC620).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "ESTUDIANTE",
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD3B121),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Info del Estudiante
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(widget.currentUser.avatarUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.currentUser.fullName,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1D2848),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          userGrade,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          "CÓDIGO: $userCode",
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF9098A7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botón Disparador QR
                                  GestureDetector(
                                    onTap: _showQRModal,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Icon(
                                        LucideIcons.qrCode,
                                        size: 16,
                                        color: Color(0xFF1D2848),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Código de barras simulado inferior
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(24, (index) {
                                      final double width = (index % 3 == 0) ? 3.0 : ((index % 2 == 0) ? 1.0 : 1.5);
                                      return Container(
                                        width: width,
                                        height: 12,
                                        margin: const EdgeInsets.only(right: 1.5),
                                        color: const Color(0xFF1D2848).withOpacity(0.8),
                                      );
                                    }),
                                  ),
                                  const Text(
                                    "VALIDADOR EN PUERTA",
                                    style: TextStyle(
                                      fontSize: 6.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9098A7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Gráfico Académico de Promedio
          const Text(
            "Rendimiento Académico",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Anillo de progreso personalizado con CustomPaint
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CustomPaint(
                      painter: GradesAvgProgressPainter(
                        score: gradesAverage,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gradesAverage.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2848),
                              ),
                            ),
                            const Text(
                              "PROM",
                              style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF9098A7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Excelente Desempeño",
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Te encuentras en el tercio superior de tu aula. Tu constancia y esfuerzo se ven reflejados en tus calificaciones. ¡Continúa así!",
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Finanzas: Pensiones por Pagar
          const Text(
            "Pensiones y Mensualidades",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pensions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pension = pensions[index];
              final isPaid = pension.status == 'paid';
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pension.month,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2848),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPaid ? "Pagado: ${pension.paymentDate}" : "Vence: ${pension.dueDate}",
                            style: TextStyle(
                              fontSize: 10,
                              color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "S/. ${pension.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2848),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isPaid)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "COBRADO",
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => _triggerPayment(pension),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEDC620),
                                foregroundColor: const Color(0xFF1D2848),
                                minimumSize: const Size(64, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "PAGAR",
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. Ajustes / Cerrar Sesión
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.settings, size: 16, color: Color(0xFF1D2848)),
                  ),
                  title: const Text(
                    "Ajustes de la Aplicación",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF64748B)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ajustes generales del portal estudiantil.")),
                    );
                  },
                ),
                const Divider(height: 1, indent: 48),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFD32F2F)),
                  ),
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFFD32F2F)),
                  onTap: widget.onLogout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Pintor del anillo de progreso académico
class GradesAvgProgressPainter extends CustomPainter {
  final double score;

  GradesAvgProgressPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 5.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // Pintar fondo del círculo
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Pintar arco de progreso en base a nota de 0 a 20 (Colegios en Perú)
    final double progressAngle = (score / 20.0) * 2.0 * 3.14159265;

    final progressPaint = Paint()
      ..color = const Color(0xFFEDC620) // Dorado Exitus
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2, // Empezar arriba en -90 grados
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
