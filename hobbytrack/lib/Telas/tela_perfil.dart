import 'package:flutter/material.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Futuramente você pode trocar esses valores por dados vindos do login/back-end.
  String nomeUsuario = 'Ana lima';
  String emailUsuario = 'ana.souza@gmail.com';

  late TextEditingController nomeController;
  late TextEditingController emailController;

  static const Color backgroundColor = Color(0xFFFFF7F0);
  static const Color purple = Color(0xFF8738F2);
  static const Color orange = Color(0xFFFF7A00);
  static const Color lightPurple = Color(0xFFB992F4);
  static const Color gray = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: nomeUsuario);
    emailController = TextEditingController(text: emailUsuario);
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void salvarDadosPerfil() {
    setState(() {
      nomeUsuario = nomeController.text;
      emailUsuario = emailController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados do perfil atualizados!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void alterarSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tela de alteração de senha será criada depois.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void sairDaConta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Função de sair da conta será conectada depois.'),
        duration: Duration(seconds: 2),
      ),
    );
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileHeader(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 54),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notificações serão conectadas depois.',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
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

                      const SizedBox(height: 115),

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
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nome',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    TextField(
                                      controller: nomeController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF9F9F9F),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: purple,
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      onChanged: (valor) {
                                        setState(() {
                                          nomeUsuario = valor;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      'E-mail',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    TextField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF9F9F9F),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: purple,
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(
                                height: 1,
                                thickness: 0.6,
                                color: Color(0xFFE8E8E8),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Senha',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: alterarSenha,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Alterar senha >',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: purple,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: 284,
                        height: 41,
                        child: ElevatedButton(
                          onPressed: salvarDadosPerfil,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  orange,
                                  purple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Salvar alterações',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: 284,
                        height: 41,
                        child: ElevatedButton(
                          onPressed: sairDaConta,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  orange,
                                  purple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Sair da conta',
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
        onHomeTap: () => botaoMenuSemAcao('Home'),
        onMetasTap: () => botaoMenuSemAcao('Metas'),
        onCategoriasTap: () => botaoMenuSemAcao('Categorias'),
        onInsightsTap: () => botaoMenuSemAcao('Insights'),
        onAddTap: botaoAdicionar,
      ),
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
        colors: [
          Color(0xFF8738F2),
          Color(0xFFFF7A00),
        ],
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
  static const Color gray = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
                    colors: [
                      purple,
                      orange,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 38,
                ),
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
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