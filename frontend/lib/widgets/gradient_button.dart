import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.width,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? AppColors.orangeGradient;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: g.colors.last.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
