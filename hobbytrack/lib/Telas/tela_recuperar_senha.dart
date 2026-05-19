import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_login.dart';

class TelaRecuperarSenha extends StatelessWidget {
  const TelaRecuperarSenha({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Stack(
        children: [
          Positioned(
            top: 360,
            left: 45,
            right: 45,
            child: Column(
              children: [
                const AuthLock(),
                const SizedBox(height: 12),
                const Text(
                  'Recuperar senha',
                  style: TextStyle(
                    color: texto,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Digite seu email de cadastro para receber\num link e criar uma nova senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: texto,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 30),
                const AuthInput(label: 'Digite seu e-mail'),
                const SizedBox(height: 30),
                GradientButton(
                  text: 'Entrar',
                  onPressed: () {},
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lembrou a senha? ',
                      style: TextStyle(
                        color: texto,
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaLogin(),
                          ),
                        );
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: roxo,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}