import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';

class ExitusPayModal extends StatefulWidget {
  final String userId;
  final PensionItem pension;
  final VoidCallback onPaymentComplete;

  const ExitusPayModal({
    super.key,
    required this.userId,
    required this.pension,
    required this.onPaymentComplete,
  });

  @override
  State<ExitusPayModal> createState() => _ExitusPayModalState();
}

class _ExitusPayModalState extends State<ExitusPayModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;
  bool _isCompleted = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _cvvController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });
      _shimmerController.repeat();

      // Simular retraso de procesamiento del banco
      await Future.delayed(const Duration(milliseconds: 1600));

      // Guardar el estado de pagado en la base de datos simulada
      MockDatabase().payPension(widget.userId, widget.pension.id);

      if (mounted) {
        _shimmerController.stop();
        setState(() {
          _isProcessing = false;
          _isCompleted = true;
        });
      }

      // Simular éxito visual y cerrar
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        widget.onPaymentComplete();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
        child: _isCompleted
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 20),
                  Icon(
                    LucideIcons.checkCircle,
                    color: Color(0xFF2E7D32),
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "¡Pago Procesado Exitosamente!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2848),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tu recibo digital ha sido generado. La pensión se ha marcado como pagada.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.landmark,
                                color: Color(0xFF2E7D32),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "ExitusPay",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2848),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: _isProcessing ? null : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),

                    // Detalle del Concepto
                    const Text(
                      "Concepto de Pago",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pensión Escolar — ${widget.pension.month}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monto a Pagar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total a debitar:",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "S/. ${widget.pension.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2848),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta Simulada
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1D2848).withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF283A63), Color(0xFF1D2848)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "EXITUS PREMIUM CARD",
                                        style: TextStyle(
                                          color: Color(0xFFEDC620),
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Icon(LucideIcons.lock, color: Color(0xBFFFFFFF), size: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "••••  ••••  ••••  9430",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "MATEO GUERRERO C.",
                                        style: TextStyle(
                                          color: Color(0xBFFFFFFF),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "EXP: 12/29",
                                        style: TextStyle(
                                          color: Color(0xBFFFFFFF),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_isProcessing)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _shimmerController,
                                  builder: (context, child) {
                                    return FractionallySizedBox(
                                      widthFactor: 0.25,
                                      alignment: Alignment(-2.0 + (_shimmerController.value * 4.0), 0.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.25),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Entrada CVV
                    const Text(
                      "Código de Seguridad (CVV)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      obscureText: true,
                      maxLength: 3,
                      enabled: !_isProcessing,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "•••",
                        counterText: "",
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFEDC620), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Requerido";
                        }
                        if (value.length < 3) {
                          return "Inválido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón de Envío
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDC620),
                        foregroundColor: const Color(0xFF1D2848),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1D2848),
                              ),
                            )
                          : const Text(
                              "AUTORIZAR CARGO SEGURO",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.lock, size: 10, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Text(
                          "Transacción encriptada SSL de 256 bits",
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
