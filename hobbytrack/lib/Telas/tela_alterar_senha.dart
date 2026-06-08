import 'package:flutter/material.dart';
import 'tela_criar_hobby.dart';
import 'tela_notificacoes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaAlterarSenha extends StatefulWidget {
  const TelaAlterarSenha({super.key});

  @override
  State<TelaAlterarSenha> createState() => _TelaAlterarSenhaState();
}

class _TelaAlterarSenhaState extends State<TelaAlterarSenha> {
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  bool ocultarSenhaAtual = true;
  bool ocultarNovaSenha = true;
  bool ocultarRepetirSenha = true;
  bool carregando = false;

  String nomeUsuario = 'Carregando...';
  @override
  void initState() {
    super.initState();
    carregarNomeUsuario();
  }

  Future<void> carregarNomeUsuario() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    final dados = doc.data();

    if (!mounted) return;

    setState(() {
      nomeUsuario = dados?['nome'] ?? usuario.displayName ?? 'Usuário';
    });
  }

  static const Color backgroundColor = Color(0xFFFFF7F0);
  static const Color purple = Color(0xFF8738F2);
  static const Color orange = Color(0xFFFF7A00);
  static const Color lightPurple = Color(0xFFB992F4);

  @override
  void dispose() {
    senhaAtualController.dispose();
    novaSenhaController.dispose();
    repetirSenhaController.dispose();
    super.dispose();
  }

  Future<void> atualizarSenha() async {
    final senhaAtual = senhaAtualController.text.trim();
    final novaSenha = novaSenhaController.text.trim();
    final repetirSenha = repetirSenhaController.text.trim();

    if (senhaAtual.isEmpty || novaSenha.isEmpty || repetirSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (novaSenha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova senha precisa ter pelo menos 6 caracteres.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (novaSenha != repetirSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova senha e a confirmação precisam ser iguais.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null || usuario.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado. Faça login novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final credencial = EmailAuthProvider.credential(
        email: usuario.email!,
        password: senhaAtual,
      );

      await usuario.reauthenticateWithCredential(credencial);

      await usuario.updatePassword(novaSenha);

      senhaAtualController.clear();
      novaSenhaController.clear();
      repetirSenhaController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha atualizada com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Não foi possível atualizar a senha.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagem = 'Senha atual incorreta.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A nova senha é muito fraca.';
      } else if (e.code == 'requires-recent-login') {
        mensagem = 'Por segurança, faça login novamente para alterar a senha.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), duration: const Duration(seconds: 2)),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void botaoMenuSemAcao(String nomeTela) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nomeTela ainda não possui navegação.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void botaoAdicionar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Botão de adicionar será conectado depois.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: ProfileHeader()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      const SizedBox(height: 22),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: purple,
                                  size: 28,
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TelaNotificacoes(),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF7F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Color(0xFF8F8F8F),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 110),

                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: lightPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFFEFE9FA),
                          size: 78,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        nomeUsuario,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 38),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Senha atual',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                CampoSenhaPerfil(
                                  controller: senhaAtualController,
                                  obscureText: ocultarSenhaAtual,
                                  onVisibilityTap: () {
                                    setState(() {
                                      ocultarSenhaAtual = !ocultarSenhaAtual;
                                    });
                                  },
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Nova senha',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                CampoSenhaPerfil(
                                  controller: novaSenhaController,
                                  obscureText: ocultarNovaSenha,
                                  onVisibilityTap: () {
                                    setState(() {
                                      ocultarNovaSenha = !ocultarNovaSenha;
                                    });
                                  },
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Repita a nova senha',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                CampoSenhaPerfil(
                                  controller: repetirSenhaController,
                                  obscureText: ocultarRepetirSenha,
                                  onVisibilityTap: () {
                                    setState(() {
                                      ocultarRepetirSenha =
                                          !ocultarRepetirSenha;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 68),

                      SizedBox(
                        width: 284,
                        height: 41,
                        child: ElevatedButton(
                          onPressed: carregando ? null : atualizarSenha,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [orange, purple],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: carregando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Atualizar senha',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomBar(
        onHomeTap: () => Navigator.pop(context),
        onMetasTap: () => Navigator.pop(context),
        onCategoriasTap: () => Navigator.pop(context),
        onInsightsTap: () => Navigator.pop(context),
        onAddTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CriarHobby()),
        ),
      ),
    );
  }
}

class CampoSenhaPerfil extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onVisibilityTap;

  const CampoSenhaPerfil({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onVisibilityTap,
  });

  static const Color purple = Color(0xFF8738F2);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: onVisibilityTap,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            size: 18,
            color: const Color(0xFF8F8F8F),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 32,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF9F9F9F), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
      ),
      style: const TextStyle(fontSize: 12, color: Colors.black),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 130),
      painter: HeaderPainter(),
    );
  }
}

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8738F2), Color(0xFFFF7A00)],
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      ).createShader(rect);

    final Path path = Path();

    path.lineTo(0, 41);

    path.cubicTo(
      size.width * 0.22,
      20,
      size.width * 0.38,
      48,
      size.width * 0.50,
      73,
    );

    path.cubicTo(
      size.width * 0.66,
      108,
      size.width * 0.86,
      101,
      size.width,
      84,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomBottomBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onMetasTap;
  final VoidCallback onCategoriasTap;
  final VoidCallback onInsightsTap;
  final VoidCallback onAddTap;

  const CustomBottomBar({
    super.key,
    required this.onHomeTap,
    required this.onMetasTap,
    required this.onCategoriasTap,
    required this.onInsightsTap,
    required this.onAddTap,
  });

  static const Color purple = Color(0xFF8738F2);
  static const Color orange = Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Icons.home,
                label: 'Home',
                selected: true,
                onTap: onHomeTap,
              ),
              _BottomItem(
                icon: Icons.track_changes,
                label: 'Metas',
                selected: false,
                onTap: onMetasTap,
              ),
              const SizedBox(width: 58),
              _BottomItem(
                icon: Icons.grid_view_rounded,
                label: 'Categorias',
                selected: false,
                onTap: onCategoriasTap,
              ),
              _BottomItem(
                icon: Icons.bar_chart_rounded,
                label: 'Insights',
                selected: false,
                onTap: onInsightsTap,
              ),
            ],
          ),

          Positioned(
            top: -18,
            child: InkWell(
              onTap: onAddTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [purple, orange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? const Color(0xFF8738F2)
        : const Color(0xFF9E9E9E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
