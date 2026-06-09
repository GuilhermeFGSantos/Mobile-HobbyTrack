import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_categorias.dart';
import 'tela_insights.dart';
import 'tela_metas.dart';
import 'tela_notificacoes.dart';
import 'tela_perfil.dart' hide CustomBottomBar;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEditarCategoria extends StatefulWidget {
  final Map<String, dynamic> categoria;

  const TelaEditarCategoria({super.key, required this.categoria});

  @override
  State<TelaEditarCategoria> createState() => _TelaEditarCategoriaState();
}

class _TelaEditarCategoriaState extends State<TelaEditarCategoria> {
  int corSelecionada = 0;
  final List<Color> coresOpcoes = [
    const Color(0xFF7B2CBF), // Roxo
    const Color(0xFF62CDFF), // Azul
    const Color(0xFFFF9E9E), // Rosa
    const Color(0xFFFFB84C), // Laranja
    const Color(0xFFA5D7E8), // Ciano claro
  ];

  late TextEditingController nomeController;
  late TextEditingController emojiController;
  bool _salvando = false;

  @override
  void dispose() {
    nomeController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  Future<void> editarCategoria() async {
    final nome = nomeController.text.trim();
    final emoji = emojiController.text.trim();

    if (nome.isEmpty || emoji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('categorias')
          .doc(widget.categoria['id'])
          .update({
            'userId': user.uid,
            'nome': nome,
            'emoji': emoji,
            'cor': coresOpcoes[corSelecionada].value, // salva o int da cor
          });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TelaCategorias()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    print('categoria recebida: ${widget.categoria}');
    nomeController = TextEditingController(
      text: widget.categoria['nome'] ?? '',
    );
    emojiController = TextEditingController(
      text: widget.categoria['emoji'] ?? '',
    );

    final int corSalva = widget.categoria['cor'] ?? 0;
    final index = coresOpcoes.indexWhere((c) => c.value == corSalva);
    corSelecionada = index != -1 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: Stack(
        children: [
          Positioned(
            top: 45,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCircularIconButton(
                      Icons.notifications_sharp,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TelaNotificacoes()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildCircularIconButton(
                      Icons.person_sharp,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaPerfil()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: 110,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                _buildLabel('Editar Categoria '),
                _buildTextField(
                  'Digite o nome da categoria',
                  controller: nomeController,
                ),

                const SizedBox(height: 20),
                _buildLabel('Editar Emoji'),
                _buildTextField(
                  'Toque para escolher',
                  controller: emojiController,
                ),

                const SizedBox(height: 20),
                _buildLabel('Cor'),
                Row(
                  children: List.generate(coresOpcoes.length, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => corSelecionada = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: coresOpcoes[index],
                          shape: BoxShape.circle,
                          border: corSelecionada == index
                              ? Border.all(color: Colors.black54, width: 2)
                              : null,
                        ),
                        child: corSelecionada == index
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 50),

                Center(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [laranja, roxo]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: _salvando ? null : editarCategoria,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomBar(
              activeIndex: 2,
              onHomeTap: () => Navigator.pop(context),
              onMetasTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TelaMetas()),
              ),
              onInsightsTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TelaInsights()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget _buildTextField(
    String hint, {
    bool readOnly = false,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    ),
  );

  Widget _buildCircularIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
    );
  }
}
