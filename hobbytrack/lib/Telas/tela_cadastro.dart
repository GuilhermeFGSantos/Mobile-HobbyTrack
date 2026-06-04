import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_login.dart';
import 'tela_home.dart';
import '../services/auth_service.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final usuarioController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  final AuthService authService = AuthService();

  bool carregando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem, {bool erro = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> cadastrarUsuario() async {
    final nome = usuarioController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (!email.toLowerCase().endsWith('@souunit.com.br')) {
      mostrarMensagem('Use apenas e-mail institucional @souunit.com.br.');
      return;
    }

    if (senha.length < 6) {
      mostrarMensagem('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem('As senhas não conferem.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await authService.cadastrarComEmailSenha(
        nome: nome,
        email: email,
        senha: senha,
      );

      if (!mounted) return;

      mostrarMensagem('Cadastro realizado com sucesso!', erro: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TelaHome(),
        ),
      );
    } catch (e) {
      mostrarMensagem('Erro ao cadastrar. Verifique os dados ou tente outro e-mail.');
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
      cadastro: true,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: largura * 0.10,
            ),
            child: Column(
              children: [
                SizedBox(height: altura * 0.18),

                TopTabs(
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

                SizedBox(height: altura * 0.04),

                const AuthLogo(),

                SizedBox(height: altura * 0.008),

                AuthInput(
                  label: 'Usuário',
                  controller: usuarioController,
                ),

                SizedBox(height: altura * 0.006),

                AuthInput(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: altura * 0.006),

                AuthInput(
                  label: 'senha',
                  obscure: true,
                  controller: senhaController,
                ),

                SizedBox(height: altura * 0.006),

                AuthInput(
                  label: 'Confirmação de senha',
                  obscure: true,
                  controller: confirmarSenhaController,
                ),

                SizedBox(height: altura * 0.02),

                carregando
                    ? const CircularProgressIndicator(
                        color: laranja,
                      )
                    : GradientButton(
                        text: 'Cadastrar',
                        onPressed: cadastrarUsuario,
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