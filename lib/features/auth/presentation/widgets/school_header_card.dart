import 'package:flutter/material.dart';
import 'school_logo.dart';
import 'package:google_fonts/google_fonts.dart';

class SchoolHeaderCard extends StatelessWidget {
  const SchoolHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SchoolLogo(size: 75),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "I.E.P. ",
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              "EXITU'S",
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F2C59),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
