import 'package:flutter/material.dart';

// Wrapper que renderiza o filho dentro de um "frame" de celular (390x844)
// centralizado, com fundo cinza ao redor. Usa as MESMAS medidas e o mesmo
// comportamento do HomeBackground (TelaCategorias): um Container de tamanho
// fixo, sem FittedBox, para que a largura fique idêntica à das demais telas
// (o FittedBox anterior escalava o quadro para caber na altura, encolhendo
// a largura junto e deixando a tela mais estreita que a de Categorias).
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
        child: Container(
          width: _largura,
          height: _altura,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}
