import 'package:flutter/material.dart';

class SchoolLogo extends StatelessWidget {
  final double size;

  const SchoolLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/school_logo.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}
