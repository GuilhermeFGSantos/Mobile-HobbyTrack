import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_cadastro.dart';
import 'tela_metas.dart';
import 'tela_recuperar_senha.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Stack(
        children: [
          Positioned(
            top: 310,
            left: 0,
            right: 0,
            child: Center(
              child: TopTabs(
                cadastroSelecionado: false,
                entrar: () {},
                cadastrar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaCadastro(),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 390,
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
                const SizedBox(height: 26),
                const AuthInput(label: 'Email'),
                const SizedBox(height: 14),
                const AuthInput(label: 'senha', obscure: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaRecuperarSenha(),
                        ),
                      );
                    },
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: texto,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  text: 'Entrar',
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                // TEMP: atalho para testar TelaMetas sem precisar logar.
                // Remover quando a Home estiver pronta e for o destino do login.
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaMetas(),
                      ),
                    );
                  },
                  child: const Text(
                    '[DEV] Testar Metas',
                    style: TextStyle(
                      color: roxo,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lembre-se',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 20,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
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