import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_widgets.dart';
import 'tela_cadastro.dart';
import 'tela_recuperar_senha.dart';
import 'tela_home.dart';
import '../services/auth_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final AuthService authService = AuthService();

  bool lembrarSenha = false;
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    carregarEmailSalvo();
  }

  Future<void> carregarEmailSalvo() async {
    final prefs = await SharedPreferences.getInstance();

    final lembrar = prefs.getBool('lembrar_email') ?? false;
    final emailSalvo = prefs.getString('email_salvo') ?? '';

    if (!mounted) return;

    setState(() {
      lembrarSenha = lembrar;

      if (lembrarSenha) {
        emailController.text = emailSalvo;
      }
    });
  }

  Future<void> atualizarLembreSe() async {
    final prefs = await SharedPreferences.getInstance();

    if (lembrarSenha) {
      await prefs.setBool('lembrar_email', true);
      await prefs.setString('email_salvo', emailController.text.trim());
    } else {
      await prefs.setBool('lembrar_email', false);
      await prefs.remove('email_salvo');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> entrarComEmailSenha() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha o e-mail e a senha.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await authService.entrarComEmailSenha(
        email: email,
        senha: senha,
      );

      await atualizarLembreSe();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TelaHome(),
        ),
      );
    } catch (e) {
      mostrarMensagem(
        'E-mail ou senha inválidos. Use uma conta @souunit.com.br.',
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> entrarComGoogle() async {
    setState(() {
      carregando = true;
    });

    try {
      await authService.entrarComGoogle();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TelaHome(),
        ),
      );
    } catch (e) {
      mostrarMensagem(
        'Acesso permitido apenas com e-mail @souunit.com.br.',
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
              horizontal: largura * 0.11,
            ),
            child: Column(
              children: [
                SizedBox(height: altura * 0.18),

                TopTabs(
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

                SizedBox(height: altura * 0.05),

                const AuthLogo(),

                SizedBox(height: altura * 0.015),

                AuthInput(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: altura * 0.01),

                AuthInput(
                  label: 'senha',
                  obscure: true,
                  controller: senhaController,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
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

                SizedBox(height: altura * 0.008),

                carregando
                    ? const CircularProgressIndicator(
                        color: laranja,
                      )
                    : GradientButton(
                        text: 'Entrar',
                        onPressed: entrarComEmailSenha,
                      ),

                SizedBox(height: altura * 0.012),

                GoogleButton(
                  onPressed: entrarComGoogle,
                  carregando: carregando,
                ),

                SizedBox(height: altura * 0.015),

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
                      onTap: () async {
                        setState(() {
                          lembrarSenha = !lembrarSenha;
                        });

                        await atualizarLembreSe();
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
                              color: lembrarSenha ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
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