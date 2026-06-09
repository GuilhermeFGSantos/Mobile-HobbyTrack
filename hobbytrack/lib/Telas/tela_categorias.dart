import 'package:flutter/material.dart';
import 'package:hobbytrack/Telas/tela_criar_hobby.dart';
import 'package:hobbytrack/Telas/tela_insights.dart';
import 'package:hobbytrack/Telas/tela_metas.dart';
import 'package:hobbytrack/Telas/tela_notificacoes.dart';
import 'package:hobbytrack/Telas/tela_nova_categoria.dart';
import 'package:hobbytrack/Telas/tela_perfil.dart';
import 'package:hobbytrack/Telas/tela_editar_categoria.dart';
import 'auth_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaCategorias extends StatefulWidget {
  const TelaCategorias({super.key});

  @override
  State<TelaCategorias> createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  List<QueryDocumentSnapshot> categorias = [];
  List<QueryDocumentSnapshot> categoriasFiltradas = [];
  final TextEditingController buscaController = TextEditingController();
  bool carregando = true;

  Future<void> buscarCategorias() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => carregando = false);
      return;
    }
    ;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categorias')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        categorias = snapshot.docs;
        carregando = false;
        categoriasFiltradas = snapshot.docs;
      });
    } catch (e) {
      print('Erro ao buscar categorias: $e');
      if (!mounted) return;
      setState(() => carregando = false);
    }
  }

  Future<void> excluirCategoria(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categorias')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Erro ao excluir categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir categoria.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    buscarCategorias();
  }

  void filtrarCategorias(String texto) {
    setState(() {
      categoriasFiltradas = categorias.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final nome = (data['nome'] ?? '').toString().toLowerCase();
        return nome.contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
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
          ),

          Positioned(
            top: 110,
            left: 24,
            right: 24,
            bottom: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categorias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    onChanged: filtrarCategorias,
                    controller: buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator())
                      : categorias.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma categoria criada ainda.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: categoriasFiltradas.length,
                          itemBuilder: (context, index) {
                            final data =
                                categoriasFiltradas[index].data()
                                    as Map<String, dynamic>;
                            final docId = categoriasFiltradas[index].id;

                            return _buildCategoryCard(
                              context: context,
                              docId: docId,
                              emoji: data['emoji'] ?? '📁',
                              cor: Color(data['cor'] ?? 0xFF7B2CBF),
                              title: data['nome'] ?? 'Sem nome',
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 85,
            right: 20,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [laranja, roxo],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaNovaCategoria(),
                    ),
                  ).then((_) => buscarCategorias());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  '+ Nova categoria',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 65,
                  color: const Color(0xFFEAEAEA),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomItem(
                        Icons.home_outlined,
                        'Home',
                        false,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildBottomItem(
                        Icons.track_changes,
                        'Metas',
                        false,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const TelaMetas()),
                        ),
                      ),
                      const SizedBox(width: 45),
                      _buildBottomItem(
                        Icons.grid_view_rounded,
                        'Categorias',
                        true,
                      ),
                      _buildBottomItem(
                        Icons.bar_chart_rounded,
                        'Insights',
                        false,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaInsights(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: -22,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CriarHobby()),
                    ),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [laranja, roxo],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoExclusao(
    BuildContext context,
    String nomeCategoria,
    String docId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF56A6A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Confirmar exclusão',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Você tem certeza que deseja excluir\na categoria “$nomeCategoria”?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFD9D9D9,
                            ), // Cinza do print
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () async {
                            excluirCategoria(docId);
                            Navigator.pop(context);
                            buscarCategorias();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFE65F2B,
                            ), // Laranja puro da foto
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
        );
      },
    );
  }

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

  Widget _buildCategoryCard({
    required BuildContext context,
    required String emoji,
    required Color cor,
    required String title,
    required String docId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          offset: const Offset(-10, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onSelected: (value) {
            if (value == 'excluir') {
              mostrarDialogoExclusao(context, title, docId);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaEditarCategoria(
                    categoria: {
                      'id': docId,
                      'nome': title,
                      'emoji': emoji,
                      'cor': cor.value,
                    },
                  ),
                ),
              ).then((_) => buscarCategorias());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'excluir',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    final color = isActive ? roxo : Colors.grey.shade600;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
