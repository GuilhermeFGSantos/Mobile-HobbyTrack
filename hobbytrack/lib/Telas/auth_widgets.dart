import 'package:flutter/material.dart';

const Color roxo = Color(0xFF7C3AED);
const Color laranja = Color(0xFFFF7A00);
const Color texto = Color(0xFF6B6474);
const Color fundoFora = Color(0xFFC9C4BA);

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
    final String formaBranca =
        cadastro ? 'assets/Rectangle3.png' : 'assets/Rectangle 2.png';

    return Scaffold(
      backgroundColor: fundoFora,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SizedBox.expand(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFF8F3EC),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: cadastro ? 260 : 280,
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
                  top: cadastro ? 82 : 95,
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(cadastro),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutBack,
                    tween: Tween<double>(
                      begin: cadastro ? -0.28 : 0.28,
                      end: 0,
                    ),
                    builder: (context, angle, child) {
                      return Transform.rotate(
                        angle: angle,
                        alignment: Alignment.topCenter,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      formaBranca,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned.fill(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }
}

class AuthInput extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AuthInput({
    super.key,
    required this.label,
    this.obscure = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool carregando;

  const GoogleButton({
    super.key,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: carregando ? null : onPressed,
      child: Container(
        width: 220,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: carregando
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: roxo,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Entrar com Google',
                    style: TextStyle(
                      color: Color(0xFF3C4043),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                      ? const LinearGradient(
                          colors: [roxo, laranja],
                        )
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

class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFora,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SizedBox(
                  width: double.infinity,
                  height: constraints.maxHeight,
                  child: child,
                ),
              ),
            );
          },
        ),
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
  final VoidCallback? onPerfilTap;

  const CustomBottomBar({
    super.key,
    this.activeIndex = 0,
    this.onHomeTap,
    this.onMetasTap,
    this.onCategoriasTap,
    this.onInsightsTap,
    this.onPerfilTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ItemBottomBar(
            icon: Icons.home_rounded,
            label: 'Home',
            ativo: activeIndex == 0,
            onTap: onHomeTap ?? () {},
          ),
          _ItemBottomBar(
            icon: Icons.flag_rounded,
            label: 'Metas',
            ativo: activeIndex == 1,
            onTap: onMetasTap ?? () {},
          ),
          _ItemBottomBar(
            icon: Icons.category_rounded,
            label: 'Categorias',
            ativo: activeIndex == 2,
            onTap: onCategoriasTap ?? () {},
          ),
          _ItemBottomBar(
            icon: Icons.insights_rounded,
            label: 'Insights',
            ativo: activeIndex == 3,
            onTap: onInsightsTap ?? () {},
          ),
          _ItemBottomBar(
            icon: Icons.person_rounded,
            label: 'Perfil',
            ativo: activeIndex == 4,
            onTap: onPerfilTap ?? () {},
          ),
        ],
      ),
    );
  }
}

class _ItemBottomBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _ItemBottomBar({
    required this.icon,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cor = ativo ? roxo : texto;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: cor,
            size: 21,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cor,
              fontSize: 9,
              fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}