import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'tela_categorias.dart';
import 'tela_criar_hobby.dart';
import 'tela_insights.dart';
import 'tela_metas.dart';
import 'tela_notificacoes.dart';
import 'tela_perfil.dart' hide CustomBottomBar;

// Constantes de Cores
const Color corRoxoApp = Color(0xFF7B2CBF);
const Color corLaranjaApp = Color(0xFFF77F00);
const Color corTextoLabels = Color(0xFF2D2D2D);
const Color corTextoSub = Color(0xFF666666);
const Color corFundoCampos = Color(0xFFFAF6F0);
const Color corBordaCampos = Color(0xFFD6CFC7);

class EditarHobby extends StatelessWidget {
  const EditarHobby({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: SafeArea(
        child: Stack(
          children: [
            // --- 1. O CONTEÚDO DO FORMULÁRIO (SCROLLABLE) ---
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets
                    .zero, // Padding zero aqui para permitir que a linha ocupe 100% da largura
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),

                    // --- BLOCO COM PADDING 24: SETA E TÍTULO ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF7B2CBF),
                              size: 28,
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Editar Hobby',
                            style: TextStyle(
                              color: corTextoLabels,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- LINHA DIVISÓRIA (PEGA 100% DA LARGURA NATURALMENTE) ---
                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 0.5,
                      height: 0.5,
                    ),
                    const SizedBox(height: 24),

                    // --- BLOCO COM PADDING 24: RESTANTE DO FORMULÁRIO ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- BLOCO SUPERIOR: ÍCONE/EMOJI + CAMPO DE NOME ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(
                                    0xFFC7EBC3,
                                  ), // Verde claro do print
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '📖',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Leitura',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: corTextoLabels,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _buildCustomTextField(hintText: 'Leitura'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // --- CARD DE META DIÁRIA ---
                          _buildMetaDiariaCard(),
                          const SizedBox(height: 20),

                          // --- CARD DE SELEÇÃO DE EMOJI ---
                          _buildEmojiCard(),
                          const SizedBox(height: 32),

                          // --- BOTÃO DE SALVAR COM GRADIENTE ---
                          Center(
                            child: Container(
                              width: 230,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [corLaranjaApp, corRoxoApp],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.maybePop(context),
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 120,
                          ), // Espaço da Bottom Bar do app
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. CONTROLE DOS ÍCONES DA DIREITA ---
            Positioned(
              top: 45,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderCircleIcon(
                    Icons.notifications,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaNotificacoes()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderCircleIcon(
                    Icons.person,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaPerfil()),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. BARRA DE NAVEGAÇÃO INFERIOR ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomBar(
                activeIndex: 0,
                onHomeTap: () => Navigator.maybePop(context),
                onMetasTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaMetas()),
                ),
                onCategoriasTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaCategorias()),
                ),
                onInsightsTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaInsights()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES DE WIDGETS ---

  Widget _buildHeaderCircleIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[600], size: 24),
      ),
    );
  }

  Widget _buildCustomTextField({required String hintText}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: corFundoCampos,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corBordaCampos, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        hintText,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }

  Widget _buildMetaDiariaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meta diária',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: corTextoLabels,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdownSelector(),
          const SizedBox(height: 14),
          const Text(
            'Repetir',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: corTextoLabels,
            ),
          ),
          const SizedBox(height: 8),
          _buildDaysOfWeek(),
          const SizedBox(height: 14),
          const Text(
            'Lembrete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: corTextoLabels,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTimeBox('00'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  ':',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              _buildTimeBox('00'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mostrar notificação',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: corTextoLabels,
                ),
              ),
              Switch(value: true, onChanged: (v) {}, activeColor: corRoxoApp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emoji',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: corTextoLabels,
            ),
          ),
          const SizedBox(height: 12),
          _buildCustomTextField(hintText: 'Toque para escolher'),
        ],
      ),
    );
  }

  Widget _buildDropdownSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corBordaCampos, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text(
            '20',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, thickness: 1, color: corBordaCampos),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'selecione uma opção',
              style: TextStyle(fontSize: 14, color: corTextoSub),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final dias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dias.map((dia) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: corLaranjaApp,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            dia,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeBox(String valor) {
    return Container(
      width: 55,
      height: 42,
      decoration: BoxDecoration(
        color: corFundoCampos,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: corBordaCampos),
      ),
      alignment: Alignment.center,
      child: Text(
        valor,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: corTextoLabels,
        ),
      ),
    );
  }
}
