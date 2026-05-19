import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_login.dart';

class TelaCadastro extends StatelessWidget {
  const TelaCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      cadastro: true,
      child: Stack(
        children: [
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Center(
              child: TopTabs(
                cadastroSelecionado: true,
                entrar: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaLogin(),
                    ),
                  );
                },
                cadastrar: () {},
              ),
            ),
          ),
          Positioned(
            top: 330,
            left: 45,
            right: 45,
            child: Column(
              children: [
                const AuthLogo(),
                const SizedBox(height: 8),
                const Text(
                  'HobbyTrack',
                  style: TextStyle(
                    color: laranja,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                const AuthInput(label: 'Usuário'),
                const SizedBox(height: 12),
                const AuthInput(label: 'Email'),
                const SizedBox(height: 12),
                const AuthInput(label: 'senha', obscure: true),
                const SizedBox(height: 12),
                const AuthInput(label: 'Confirmação de senha', obscure: true),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Cadastrar',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}