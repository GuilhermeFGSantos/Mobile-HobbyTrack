import 'package:flutter/material.dart';

const Color roxo = Color(0xFF7C3AED);
const Color laranja = Color(0xFFFF7A00);
const Color texto = Color(0xFF6B6474);
const Color fundoFora = Color(0xFFC9C4BA);

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool cadastro;

  const AuthBackground({super.key, required this.child, this.cadastro = false});

  @override
  Widget build(BuildContext context) {
    final String formaBranca = cadastro
        ? 'assets/Rectangle3.png'
        : 'assets/Rectangle 2.png';

    return Scaffold(
      backgroundColor: fundoFora,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              children: [
                // FUNDO OFF-WHITE GERAL
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFF8F3EC),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: cadastro ? 280 : 300,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFFC34CA3),
                          Color(0xFFFF7A00),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: cadastro ? 100 : 100,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    formaBranca,
                    fit: cadastro ? BoxFit.fitWidth : BoxFit.cover,
                    alignment: cadastro
                        ? Alignment.topCenter
                        : Alignment.center,
                  ),
                ),

                // CONTEÚDO DA TELA
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFora,
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F3EC),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment.topCenter,
                      transform: GradientRotation(2.1),
                      colors: [roxo, laranja, roxo],
                      stops: [0.25, 0.63, 0.2],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ClipPath(
                    clipper: HomeClipper(),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: const Color(0xFFF8F3EC),
                    ),
                  ),
                ),
              ),

              child,
            ],
          ),
        ),
      ),
    );
  }
}

class HomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.25);

    path.cubicTo(
      size.width * 0.00,
      size.height * 0.15,
      size.width * 0.35,
      size.height * 0.13,
      size.width * 0.50,
      size.height * 0.28,
    );

    path.cubicTo(
      size.width * 0.70,
      size.height * 0.48,
      size.width * 0.85,
      size.height * 0.40,
      size.width,
      size.height * 0.36,
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
    return Image.asset(
      'assets/logo.png',
      width: 155,
      height: 155,
      fit: BoxFit.contain,
    );
  }
}

class AuthLock extends StatelessWidget {
  const AuthLock({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/cadeado.png',
      width: 130,
      height: 130,
      fit: BoxFit.contain,
    );
  }
}

class AuthInput extends StatelessWidget {
  final String label;
  final bool obscure;

  const AuthInput({super.key, required this.label, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: texto),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: texto),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: roxo, width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: roxo, width: 2),
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
          gradient: const LinearGradient(colors: [laranja, roxo]),
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
            color: Colors.black.withValues(alpha: 0.15),
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
                      : const LinearGradient(colors: [roxo, laranja]),
                ),
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    color: cadastroSelecionado ? texto : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
                      ? const LinearGradient(colors: [roxo, laranja])
                      : null,
                ),
                child: Text(
                  'Cadastrar-se',
                  style: TextStyle(
                    color: cadastroSelecionado ? Colors.white : texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class CustomBottomBar extends StatelessWidget {
  final int activeIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMetasTap;
  final VoidCallback? onCategoriasTap;
  final VoidCallback? onInsightsTap;

  const CustomBottomBar({
    super.key,
    required this.activeIndex,
    this.onHomeTap,
    this.onMetasTap,
    this.onCategoriasTap,
    this.onInsightsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 65,
          color: const Color(0xFFEAEAEA),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomItem(Icons.home_outlined, 'Home', activeIndex == 0, onHomeTap),
              _buildBottomItem(Icons.track_changes, 'Metas', activeIndex == 1, onMetasTap),
              const SizedBox(width: 45),
              _buildBottomItem(Icons.grid_view_rounded, 'Categorias', activeIndex == 2, onCategoriasTap),
              _buildBottomItem(Icons.bar_chart_rounded, 'Insights', activeIndex == 3, onInsightsTap),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    final color = isActive ? roxo : Colors.grey.shade600;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
