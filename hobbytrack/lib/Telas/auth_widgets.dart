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
