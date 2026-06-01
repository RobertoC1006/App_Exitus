import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DragonWidget extends StatelessWidget {
  final String dragonType; // 'glaciar', 'lava', 'rayo', 'brasa'
  final int points;
  final double size;
  final String? spriteSheetUrl;

  const DragonWidget({
    super.key,
    required this.dragonType,
    required this.points,
    this.size = 80,
    this.spriteSheetUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = (spriteSheetUrl != null && spriteSheetUrl!.isNotEmpty)
        ? NetworkImage(spriteSheetUrl!)
        : const AssetImage('assets/images/dragon_spritesheet.png') as ImageProvider;

    return DragonSpriteWidget(
      dragonType: dragonType,
      points: points,
      size: size,
      imageProvider: imageProvider,
    );
  }
}

class DragonSpriteWidget extends StatefulWidget {
  final String dragonType;
  final int points;
  final double size;
  final ImageProvider imageProvider;
  final int rows;
  final int columns;
  final Duration frameDuration;

  const DragonSpriteWidget({
    super.key,
    required this.dragonType,
    required this.points,
    required this.imageProvider,
    this.size = 80,
    this.rows = 4,
    this.columns = 4,
    this.frameDuration = const Duration(milliseconds: 100),
  });

  @override
  State<DragonSpriteWidget> createState() => _DragonSpriteWidgetState();
}

class _DragonSpriteWidgetState extends State<DragonSpriteWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  ui.Image? _image;
  bool _hasError = false;
  bool _isLoading = true;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.frameDuration.inMilliseconds * widget.rows * widget.columns),
    )..repeat();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant DragonSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _loadImage();
    }
  }

  void _loadImage() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }

    _imageStream = widget.imageProvider.resolve(ImageConfiguration.empty);
    _listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (mounted) {
          setState(() {
            _image = info.image;
            _isLoading = false;
          });
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      },
    );
    _imageStream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _isLoading || _image == null) {
      // Fallback: draw with Vector DragonPainter
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: DragonPainter(
            dragonType: widget.dragonType,
            points: widget.points,
          ),
        ),
      );
    }

    // Otherwise, draw the animated sprite sheet
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          final int totalFrames = widget.rows * widget.columns;
          final int currentFrame = (_controller!.value * totalFrames).floor().clamp(0, totalFrames - 1);
          return CustomPaint(
            painter: DragonSpritePainter(
              image: _image!,
              rows: widget.rows,
              columns: widget.columns,
              frameIndex: currentFrame,
            ),
          );
        },
      ),
    );
  }
}

class DragonSpritePainter extends CustomPainter {
  final ui.Image image;
  final int rows;
  final int columns;
  final int frameIndex;

  DragonSpritePainter({
    required this.image,
    required this.rows,
    required this.columns,
    required this.frameIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = image.width / columns;
    final double cellHeight = image.height / rows;

    final int col = frameIndex % columns;
    final int row = (frameIndex / columns).floor();

    final Rect srcRect = Rect.fromLTWH(
      col * cellWidth,
      row * cellHeight,
      cellWidth,
      cellHeight,
    );

    final Rect destRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Paint paint = Paint()
      ..filterQuality = FilterQuality.medium;

    canvas.drawImageRect(image, srcRect, destRect, paint);
  }

  @override
  bool shouldRepaint(covariant DragonSpritePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.frameIndex != frameIndex;
  }
}

class DragonPainter extends CustomPainter {
  final String dragonType;
  final int points;

  DragonPainter({required this.dragonType, required this.points});

  String get stage {
    if (points >= 0 && points <= 4) return 'egg';
    if (points >= 5 && points <= 8) return 'egg_elemental';
    if (points >= 9 && points <= 11) return 'puppy';
    return 'adult';
  }

  // Gradientes de color según el tipo de dragón
  LinearGradient getGradient() {
    switch (dragonType) {
      case 'glaciar':
        return const LinearGradient(
          colors: [Color(0xFF80DEEA), Color(0xFF00ACC1), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'lava':
        return const LinearGradient(
          colors: [Color(0xFFFFAB91), Color(0xFFF4511E), Color(0xFFBF360C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rayo':
        return const LinearGradient(
          colors: [Color(0xFFE040FB), Color(0xFF7B1FA2), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'brasa':
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color get shadowColor {
    switch (dragonType) {
      case 'glaciar':
        return const Color(0xFF00ACC1);
      case 'lava':
        return const Color(0xFFF4511E);
      case 'rayo':
        return const Color(0xFF7B1FA2);
      case 'brasa':
      default:
        return const Color(0xFFFFB300);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Escalar la matriz de transformación para dibujar sobre una cuadrícula virtual de 100x100
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    final rect = const Rect.fromLTWH(0, 0, 100, 100);
    final currentStage = stage;

    if (currentStage == 'egg') {
      // Huevo Básico (Azul marino del colegio)
      final eggGrad = const LinearGradient(
        colors: [Color(0xFF9FA8DA), Color(0xFF3F51B5), Color(0xFF1A237E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

      final paint = Paint()
        ..shader = eggGrad
        ..style = PaintingStyle.fill;

      // Dibujar Huevo
      final eggPath = Path()
        ..moveTo(50, 15)
        ..cubicTo(25, 15, 15, 45, 15, 65)
        ..cubicTo(15, 80, 30, 85, 50, 85)
        ..cubicTo(70, 85, 85, 80, 85, 65)
        ..cubicTo(85, 45, 75, 15, 50, 15)
        ..close();

      canvas.drawPath(eggPath, paint);

      // Dibujar lunares dorados
      final spotPaint = Paint()
        ..color = const Color(0xFFEDC620).withOpacity(0.85)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(const Offset(40, 45), 4.5, spotPaint);
      canvas.drawCircle(const Offset(62, 52), 5.5, spotPaint);
      canvas.drawCircle(const Offset(32, 65), 3.8, spotPaint);
      canvas.drawCircle(const Offset(55, 72), 4.8, spotPaint);

    } else if (currentStage == 'egg_elemental') {
      // Huevo Elemental
      final elemGrad = getGradient().createShader(rect);
      final paint = Paint()
        ..shader = elemGrad
        ..style = PaintingStyle.fill;

      final eggPath = Path()
        ..moveTo(50, 15)
        ..cubicTo(25, 15, 15, 45, 15, 65)
        ..cubicTo(15, 80, 30, 85, 50, 85)
        ..cubicTo(70, 85, 85, 80, 85, 65)
        ..cubicTo(85, 45, 75, 15, 50, 15)
        ..close();

      canvas.drawPath(eggPath, paint);

      // Dibujar patrones según elemento
      final patternPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      if (dragonType == 'glaciar') {
        // Cristales de hielo
        final p1 = Path()..moveTo(50, 20)..lineTo(40, 35)..lineTo(48, 32)..close();
        final p2 = Path()..moveTo(30, 45)..lineTo(20, 55)..lineTo(35, 58)..close();
        final p3 = Path()..moveTo(70, 40)..lineTo(80, 50)..lineTo(65, 55)..close();
        final p4 = Path()..moveTo(45, 60)..lineTo(35, 75)..lineTo(55, 70)..close();
        canvas.drawPath(p1, patternPaint);
        canvas.drawPath(p2, patternPaint);
        canvas.drawPath(p3, patternPaint);
        canvas.drawPath(p4, patternPaint);

      } else if (dragonType == 'lava') {
        // Grietas de lava
        final linePaint = Paint()
          ..color = const Color(0xFFEDC620)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final path1 = Path()..moveTo(50, 15)..quadraticBezierTo(45, 35, 55, 50)..quadraticBezierTo(60, 65, 50, 85);
        final path2 = Path()..moveTo(55, 50)..quadraticBezierTo(30, 55, 25, 65);
        final path3 = Path()..moveTo(45, 35)..quadraticBezierTo(70, 40, 75, 55);

        canvas.drawPath(path1, linePaint);
        canvas.drawPath(path2, linePaint..strokeWidth = 2.0);
        canvas.drawPath(path3, linePaint);

      } else if (dragonType == 'rayo') {
        // Rayo
        final lightningPaint = Paint()
          ..color = const Color(0xFFEDC620)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;

        final path = Path()
          ..moveTo(50, 20)
          ..lineTo(45, 40)
          ..lineTo(58, 40)
          ..lineTo(42, 65)
          ..lineTo(55, 65)
          ..lineTo(45, 82);

        canvas.drawPath(path, lightningPaint);

      } else {
        // Brasa (llama dorada interna)
        final flamePaint = Paint()
          ..color = const Color(0xFFEDC620).withOpacity(0.2)
          ..style = PaintingStyle.fill;

        final path = Path()
          ..moveTo(50, 85)
          ..cubicTo(30, 85, 20, 70, 20, 60)
          ..cubicTo(20, 45, 50, 30, 50, 15)
          ..cubicTo(50, 30, 80, 45, 80, 60)
          ..cubicTo(80, 70, 70, 85, 50, 85)
          ..close();

        canvas.drawPath(path, flamePaint);
      }

    } else if (currentStage == 'puppy') {
      // Cachorro
      final elemGrad = getGradient().createShader(rect);
      final shellGrad = const LinearGradient(
        colors: [Color(0xFFEEEEEE), Color(0xFFCCCCCC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      final dragonPaint = Paint()
        ..shader = elemGrad
        ..style = PaintingStyle.fill;

      final shellPaint = Paint()
        ..shader = shellGrad
        ..style = PaintingStyle.fill;

      final shellLinePaint = Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // 1. Cascarón Trasero
      final backShell = Path()
        ..moveTo(20, 60)
        ..cubicTo(20, 75, 35, 85, 50, 85)
        ..cubicTo(65, 85, 80, 75, 80, 60)
        ..lineTo(75, 55)
        ..lineTo(65, 62)
        ..lineTo(50, 50)
        ..lineTo(35, 62)
        ..lineTo(25, 55)
        ..close();
      canvas.drawPath(backShell, shellPaint);
      canvas.drawPath(backShell, shellLinePaint);

      // 2. Alitas
      final wingPaint = Paint()
        ..shader = elemGrad
        ..style = PaintingStyle.fill;

      final leftWing = Path()
        ..moveTo(23, 50)
        ..cubicTo(14, 44, 11, 34, 11, 34)
        ..quadraticBezierTo(19, 39, 27, 48)
        ..close();

      final rightWing = Path()
        ..moveTo(77, 50)
        ..cubicTo(86, 44, 89, 34, 89, 34)
        ..quadraticBezierTo(81, 39, 73, 48)
        ..close();

      canvas.drawPath(leftWing, wingPaint..color = wingPaint.color.withOpacity(0.8));
      canvas.drawPath(rightWing, wingPaint);

      // 3. Cabeza y cuello
      final neck = Path()
        ..moveTo(40, 65)
        ..lineTo(60, 65)
        ..lineTo(58, 50)
        ..lineTo(42, 50)
        ..close();
      canvas.drawPath(neck, dragonPaint);
      canvas.drawCircle(const Offset(50, 42), 17, dragonPaint);

      // Hocico
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 48), width: 18, height: 14), dragonPaint..color = dragonPaint.color.withOpacity(0.9));
      final nosePaint = Paint()..color = const Color(0xFF1D2848)..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(47, 47), 1.0, nosePaint);
      canvas.drawCircle(const Offset(53, 47), 1.0, nosePaint);

      // Ojos Grandes
      final eyeWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;
      final eyePupil = Paint()..color = const Color(0xFF1D2848)..style = PaintingStyle.fill;
      final eyeReflect = Paint()..color = Colors.white..style = PaintingStyle.fill;

      canvas.drawCircle(const Offset(43, 38), 4.2, eyeWhite);
      canvas.drawCircle(const Offset(43, 38), 2.5, eyePupil);
      canvas.drawCircle(const Offset(44.2, 36.8), 0.9, eyeReflect);

      canvas.drawCircle(const Offset(57, 38), 4.2, eyeWhite);
      canvas.drawCircle(const Offset(57, 38), 2.5, eyePupil);
      canvas.drawCircle(const Offset(58.2, 36.8), 0.9, eyeReflect);

      // Cuernos
      final hornPaint = Paint()..color = const Color(0xFFEDC620)..style = PaintingStyle.fill;
      final leftHorn = Path()
        ..moveTo(39, 29)
        ..quadraticBezierTo(36, 20, 33, 20)
        ..quadraticBezierTo(35, 24, 39, 28)
        ..close();
      final rightHorn = Path()
        ..moveTo(61, 29)
        ..quadraticBezierTo(64, 20, 67, 20)
        ..quadraticBezierTo(65, 24, 61, 28)
        ..close();

      canvas.drawPath(leftHorn, hornPaint);
      canvas.drawPath(rightHorn, hornPaint);

      // 4. Cascarón Delantero
      final frontShell = Path()
        ..moveTo(20, 60)
        ..lineTo(30, 62)
        ..lineTo(40, 58)
        ..lineTo(50, 68)
        ..lineTo(60, 58)
        ..lineTo(70, 62)
        ..lineTo(80, 60)
        ..cubicTo(80, 75, 65, 85, 50, 85)
        ..cubicTo(35, 85, 20, 75, 20, 60)
        ..close();
      canvas.drawPath(frontShell, shellPaint);
      canvas.drawPath(frontShell, shellLinePaint..strokeWidth = 1.2);

    } else {
      // Adulto
      final elemGrad = getGradient().createShader(rect);
      final dragonPaint = Paint()
        ..shader = elemGrad
        ..style = PaintingStyle.fill;

      // 1. Alas Desplegadas
      final leftWing = Path()
        ..moveTo(45, 45)
        ..cubicTo(23, 23, 8, 23, 3, 33)
        ..cubicTo(0, 40, 10, 48, 28, 53)
        ..quadraticBezierTo(38, 55, 45, 53)
        ..close();

      final rightWing = Path()
        ..moveTo(55, 45)
        ..cubicTo(77, 23, 92, 23, 97, 33)
        ..cubicTo(100, 40, 90, 48, 72, 53)
        ..quadraticBezierTo(62, 55, 55, 53)
        ..close();

      canvas.drawPath(leftWing, dragonPaint..color = dragonPaint.color.withOpacity(0.95));
      canvas.drawPath(rightWing, dragonPaint);

      // Borde de alas dorado
      final goldLine = Paint()
        ..color = const Color(0xFFEDC620)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(leftWing, goldLine);
      canvas.drawPath(rightWing, goldLine);

      // 2. Cola
      final tail = Path()
        ..moveTo(50, 73)
        ..quadraticBezierTo(51, 90, 66, 88)
        ..quadraticBezierTo(70, 86, 62, 80)
        ..quadraticBezierTo(52, 80, 50, 73)
        ..close();
      canvas.drawPath(tail, dragonPaint);

      // 3. Cuerpo
      final body = Path()
        ..moveTo(42, 42)
        ..quadraticBezierTo(50, 38, 58, 42)
        ..quadraticBezierTo(62, 56, 56, 74)
        ..quadraticBezierTo(50, 80, 44, 74)
        ..quadraticBezierTo(38, 56, 42, 42)
        ..close();
      canvas.drawPath(body, dragonPaint);

      // 4. Pecho Dorado
      final chest = Path()
        ..moveTo(46, 45)
        ..quadraticBezierTo(50, 43, 54, 45)
        ..quadraticBezierTo(56, 54, 52, 66)
        ..quadraticBezierTo(50, 68, 48, 66)
        ..quadraticBezierTo(44, 54, 46, 45)
        ..close();
      canvas.drawPath(chest, Paint()..color = const Color(0xFFEDC620)..style = PaintingStyle.fill);

      // 5. Cabeza Fiera
      final head = Path()
        ..moveTo(50, 15)
        ..lineTo(36, 28)
        ..lineTo(50, 38)
        ..lineTo(64, 28)
        ..close();
      canvas.drawPath(head, dragonPaint);

      // Ojos Amarillos Brillantes
      final eyePaint = Paint()..color = const Color(0xFFFFFF00)..style = PaintingStyle.fill;
      final leftEye = Path()..moveTo(44, 26)..lineTo(48, 27)..lineTo(46, 29)..close();
      final rightEye = Path()..moveTo(56, 26)..lineTo(52, 27)..lineTo(54, 29)..close();
      canvas.drawPath(leftEye, eyePaint);
      canvas.drawPath(rightEye, eyePaint);

      // Cuernos Grandes
      final hornPaint = Paint()..color = const Color(0xFFEDC620)..style = PaintingStyle.fill;
      final leftHorn = Path()
        ..moveTo(44, 18)
        ..quadraticBezierTo(37, 4, 33, 4)
        ..quadraticBezierTo(37, 9, 44, 16)
        ..close();
      final rightHorn = Path()
        ..moveTo(56, 18)
        ..quadraticBezierTo(63, 4, 67, 4)
        ..quadraticBezierTo(63, 9, 56, 16)
        ..close();
      canvas.drawPath(leftHorn, hornPaint);
      canvas.drawPath(rightHorn, hornPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
