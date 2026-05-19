import 'package:flutter/material.dart';

// Wrapper que renderiza o filho dentro de um "frame" de celular (390x844)
// centralizado, com fundo cinza ao redor. Replica o visual usado pelo
// AuthBackground (login/cadastro), permitindo que outras telas mantenham
// a mesma aparência de mockup quando rodando no Chrome / desktop.
class MobileFrame extends StatelessWidget {
  final Widget child;

  static const Color _fundoFora = Color(0xFFC9C4BA);
  static const double _largura = 390;
  static const double _altura = 844;

  const MobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundoFora,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _largura,
            height: _altura,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
