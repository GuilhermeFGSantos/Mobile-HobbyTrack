import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_login.dart';
import '../services/auth_service.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final emailController = TextEditingController();
  final AuthService authService = AuthService();

  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem, {bool erro = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> enviarRecuperacaoSenha() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      mostrarMensagem('Digite seu e-mail institucional.');
      return;
    }

    if (!email.toLowerCase().endsWith('@souunit.com.br')) {
      mostrarMensagem('Use apenas e-mail institucional @souunit.com.br.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await authService.recuperarSenha(email);

      if (!mounted) return;

      mostrarMensagem(
        'Link enviado! Verifique seu e-mail institucional.',
        erro: false,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TelaLogin(),
          ),
        );
      });
    } catch (e) {
      mostrarMensagem(
        'Não foi possível enviar o link. Verifique o e-mail digitado.',
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;
    final largura = MediaQuery.of(context).size.width;

    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: largura * 0.10,
            ),
            child: Column(
              children: [
                SizedBox(height: altura * 0.20),

                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AuthLock(),
                  ),
                ),

                SizedBox(height: altura * 0.025),

                const Text(
                  'Recuperar senha',
                  style: TextStyle(
                    color: texto,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: altura * 0.012),

                const Text(
                  'Informe seu e-mail institucional para\nreceber o link de redefinição de senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: texto,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: altura * 0.035),

                AuthInput(
                  label: 'E-mail institucional',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: altura * 0.03),

                carregando
                    ? const CircularProgressIndicator(
                        color: laranja,
                      )
                    : GradientButton(
                        text: 'Enviar link',
                        onPressed: enviarRecuperacaoSenha,
                      ),

                SizedBox(height: altura * 0.022),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lembrou sua senha? ',
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}