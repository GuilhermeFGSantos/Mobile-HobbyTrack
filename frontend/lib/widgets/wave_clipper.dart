import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.50);

    // Primeira curva: creme sobe (hump) no centro-esquerda
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.12,
      size.width * 0.50,
      size.height * 0.55,
    );

    // Segunda curva: creme desce suavemente até a direita
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.92,
      size.width,
      size.height * 0.50,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
