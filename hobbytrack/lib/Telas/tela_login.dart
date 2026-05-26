import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_cadastro.dart';
import 'tela_recuperar_senha.dart';
import 'tela_home.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool lembrarSenha = true;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Stack(
        children: [
          Positioned(
            top: 270,
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
            top: 340,
            left: 45,
            right: 45,
            child: Column(
              children: [
                const AuthLogo(),

                const SizedBox(height: 20),

                const AuthInput(label: 'Email'),

                const SizedBox(height: 14),

                const AuthInput(
                  label: 'senha',
                  obscure: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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

                const SizedBox(height: 14),

                GradientButton(
                  text: 'Entrar',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaHome(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

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

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          lembrarSenha = !lembrarSenha;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 22,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: lembrarSenha
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: lembrarSenha
                                  ? Colors.green
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
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