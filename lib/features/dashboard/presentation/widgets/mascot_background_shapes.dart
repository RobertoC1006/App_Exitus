import 'package:flutter/material.dart';

class MascotBackgroundShapes extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const MascotBackgroundShapes({
    super.key,
    required this.color,
    this.width = 120,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Large organic blob in the background
          Positioned(
            right: -width * 0.15,
            bottom: -height * 0.15,
            child: SizedBox(
              width: width * 1.3,
              height: height * 1.3,
              child: CustomPaint(
                painter: _OrganicBlobPainter(
                  color: color,
                  opacityStart: 0.20,
                  opacityEnd: 0.0,
                ),
              ),
            ),
          ),
          
          // 2. Secondary rotated squircle shape for abstract layered depth
          Positioned(
            right: width * 0.15,
            bottom: height * 0.08,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: width * 0.65,
                height: width * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.18),
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.14),
                      color.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 3. Small floating bubbles
          Positioned(
            right: width * 0.75,
            top: height * 0.12,
            child: Container(
              width: width * 0.16,
              height: width * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: width * 0.05,
            top: height * 0.25,
            child: Container(
              width: width * 0.11,
              height: width * 0.11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),

          // 4. Subtle accent dot
          Positioned(
            right: width * 0.6,
            bottom: height * 0.7,
            child: Container(
              width: width * 0.05,
              height: width * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganicBlobPainter extends CustomPainter {
  final Color color;
  final double opacityStart;
  final double opacityEnd;

  _OrganicBlobPainter({
    required this.color,
    required this.opacityStart,
    required this.opacityEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacityStart),
          color.withValues(alpha: opacityStart * 0.5),
          color.withValues(alpha: opacityEnd),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // Smooth custom fluid path
    path.moveTo(size.width * 0.35, size.height * 0.15);
    path.cubicTo(
      size.width * 0.75, size.height * 0.02,
      size.width * 1.05, size.height * 0.28,
      size.width * 0.98, size.height * 0.65,
    );
    path.cubicTo(
      size.width * 0.90, size.height * 0.95,
      size.width * 0.55, size.height * 1.05,
      size.width * 0.25, size.height * 0.88,
    );
    path.cubicTo(
      size.width * -0.05, size.height * 0.70,
      size.width * 0.05, size.height * 0.35,
      size.width * 0.35, size.height * 0.15,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
