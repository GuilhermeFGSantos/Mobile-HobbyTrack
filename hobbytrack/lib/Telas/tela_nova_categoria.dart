import 'package:flutter/material.dart';
import 'tela_categorias.dart';
import 'auth_widgets.dart';

class TelaNovaCategoria extends StatefulWidget {
  const TelaNovaCategoria({super.key});

  @override
  State<TelaNovaCategoria> createState() => _TelaNovaCategoriaState();
}

class _TelaNovaCategoriaState extends State<TelaNovaCategoria> {
  int corSelecionada = 0;
  final List<Color> coresOpcoes = [
    const Color(0xFF7B2CBF), // Roxo
    const Color(0xFF62CDFF), // Azul
    const Color(0xFFFF9E9E), // Rosa
    const Color(0xFFFFB84C), // Laranja
    const Color(0xFFA5D7E8), // Ciano claro
  ];

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
                    _buildCircularIconButton(Icons.notifications_sharp),
                    const SizedBox(width: 10),
                    _buildCircularIconButton(Icons.person_sharp),
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

                _buildLabel('Nome da categoria'),
                _buildTextField('Digite o nome da meta'),

                const SizedBox(height: 20),
                _buildLabel('Emoji'),
                _buildTextField('Toque para escolher', readOnly: true),

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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaCategorias(),
                          ),
                        );
                      },
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

          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomBar(activeIndex: 2),
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

  Widget _buildTextField(String hint, {bool readOnly = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    ),
  );

  Widget _buildCircularIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey.shade700, size: 20),
    );
  }
}
