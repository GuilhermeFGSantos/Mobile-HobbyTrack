import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color roxo = Color(0xFF7C3AED);
const Color laranja = Color(0xFFFF7A00);
const Color offWhite = Color(0xFFF8F3EC);
const Color fundoFora = Color(0xFFC9C4BA);
const Color texto = Color(0xFF6B6474);

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool cadastro;

  const AuthBackground({
    super.key,
    required this.child,
    this.cadastro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFora,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              color: offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // FUNDO COM GRADIENTE ANGULAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: cadastro ? 270 : 290,
                    decoration: const BoxDecoration(
                      gradient: SweepGradient(
                        center: Alignment.topCenter,
                        transform: GradientRotation(0.0),
                        colors: [
                          roxo,
                          laranja,
                          roxo,
                        ],
                        stops: [
                          0.54,
                          0.63,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),

                // FORMA BRANCA / OFF WHITE
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: cadastro ? CadastroClipper() : LoginClipper(),
                      child: Container(
                        width: double.infinity,
                        height: cadastro ? 700 : 650,
                        color: offWhite,
                      ),
                    ),
                  ),
                ),

                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.20);

    path.cubicTo(
      size.width * 0.15,
      size.height * 0.12,
      size.width * 0.38,
      size.height * 0.02,
      size.width * 0.48,
      size.height * 0.03,
    );

    path.cubicTo(
      size.width * 0.60,
      size.height * 0.05,
      size.width * 0.58,
      size.height * 0.23,
      size.width * 0.47,
      size.height * 0.27,
    );

    path.cubicTo(
      size.width * 0.40,
      size.height * 0.30,
      size.width * 0.28,
      size.height * 0.28,
      size.width * 0.15,
      size.height * 0.25,
    );

    path.cubicTo(
      size.width * 0.08,
      size.height * 0.23,
      size.width * 0.03,
      size.height * 0.21,
      0,
      size.height * 0.20,
    );

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.23 * size.height);

    path.cubicTo(
      size.width * 0.86,
      size.height * 0.25,
      size.width * 0.72,
      size.height * 0.27,
      size.width * 0.55,
      size.height * 0.20,
    );

    path.cubicTo(
      size.width * 0.52,
      size.height * 0.19,
      size.width * 0.50,
      size.height * 0.19,
      size.width * 0.48,
      size.height * 0.20,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CadastroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.12);

    path.cubicTo(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.35,
      size.height * 0.16,
      size.width * 0.42,
      size.height * 0.10,
    );

    path.cubicTo(
      size.width * 0.55,
      -size.height * 0.02,
      size.width * 0.20,
      -size.height * 0.03,
      size.width * 0.33,
      size.height * 0.04,
    );

    path.cubicTo(
      size.width * 0.55,
      size.height * 0.15,
      size.width * 0.78,
      size.height * 0.10,
      size.width,
      size.height * 0.22,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: SvgPicture.asset(
        'assets/logo.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthLock extends StatelessWidget {
  const AuthLock({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: SvgPicture.asset(
        'assets/cadeado.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthInput extends StatelessWidget {
  final String label;
  final bool obscure;

  const AuthInput({
    super.key,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: texto,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: texto,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: roxo,
            width: 2,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: roxo,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 180,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              laranja,
              roxo,
            ],
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class TopTabs extends StatelessWidget {
  final bool cadastroSelecionado;
  final VoidCallback entrar;
  final VoidCallback cadastrar;

  const TopTabs({
    super.key,
    required this.cadastroSelecionado,
    required this.entrar,
    required this.cadastrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: entrar,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: cadastroSelecionado
                      ? null
                      : const LinearGradient(
                          colors: [roxo, laranja],
                        ),
                ),
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    color: cadastroSelecionado ? texto : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: cadastrar,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: cadastroSelecionado
                      ? const LinearGradient(
                          colors: [roxo, laranja],
                        )
                      : null,
                ),
                child: Text(
                  'Cadastrar-se',
                  style: TextStyle(
                    color: cadastroSelecionado ? Colors.white : texto,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}