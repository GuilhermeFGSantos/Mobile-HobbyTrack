import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_categorias.dart';
import 'tela_criar_hobby.dart';
import 'tela_metas.dart';
import 'tela_notificacoes.dart';
import 'tela_perfil.dart';

class TelaInsights extends StatelessWidget {
  const TelaInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      body: Stack(
        children: [
          // 1. FUNDO CURVO DO TOPO COM GRADIENTE
          ClipPath(
            clipper: TopHeaderClipper(),
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [roxo, laranja],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. ÍCONES DO TOPO (Notificação e Perfil)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Ícone de Sino
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TelaNotificacoes()),
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 22,
                              child: Icon(
                                Icons.notifications,
                                color: Colors.grey[400],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Ícone de Perfil
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TelaPerfil()),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: Icon(Icons.person, color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Acompanhe sua evolução da semana',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 4. LISTA DE DIAS (CARDS)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: const [
                      DiaCard(
                        dia: 'Segunda',
                        mensagem: 'Você registrou progresso em 2 metas',
                        icone: Icon(
                          Icons.check_circle_outline,
                          color: laranja,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      DiaCard(
                        dia: 'Terça',
                        mensagem: 'Sua meta de leitura foi concluida',
                        icone: Icon(
                          Icons.check_circle_outline,
                          color: laranja,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      DiaCard(
                        dia: 'Quarta',
                        mensagem: 'Você manteve constância em exercícios',
                        icone: Icon(
                          Icons.check_circle_outline,
                          color: laranja,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      DiaCard(
                        dia: 'Quinta',
                        mensagem: 'Nenhum progresso foi registrado hoje',
                        icone: Icon(
                          Icons.warning,
                          color: Colors.amber,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      DiaCard(
                        dia: 'Sexta',
                        mensagem:
                            'Sua evolução foi maior que no inicio da semana',
                        icone: Icon(
                          Icons.bar_chart,
                          color: Colors.green,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      DiaCard(
                        dia: 'Sábado',
                        mensagem:
                            'Sua evolução foi maior que no inicio da semana',
                        icone: Icon(
                          Icons.bar_chart,
                          color: Colors.green,
                          size: 28,
                        ),
                        corDia: roxo,
                      ),
                      SizedBox(
                        height: 80,
                      ), // Espaço em branco pro último item não ficar atrás da barra de baixo
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CriarHobby()),
        ),
        child: Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [roxo, laranja],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: laranja.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFFFFF7F0),
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', false, onTap: () => Navigator.pop(context)),
              _buildNavItem(
                Icons.track_changes,
                'Metas',
                false,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaMetas()),
                ),
              ),
              const SizedBox(
                width: 40,
              ), // Espaço vazio onde entra o botão central (+)
              _buildNavItem(
                Icons.grid_view,
                'Categorias',
                false,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaCategorias()),
                ),
              ),
              _buildNavItem(Icons.bar_chart, 'Insights', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? roxo : texto, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isActive ? roxo : texto,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

//WIDGETS
class DiaCard extends StatelessWidget {
  final String dia;
  final String mensagem;
  final Widget icone;
  final Color corDia;

  const DiaCard({
    super.key,
    required this.dia,
    required this.mensagem,
    required this.icone,
    required this.corDia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dia,
            style: TextStyle(
              color: corDia,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              icone,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensagem,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 60,
    );
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
