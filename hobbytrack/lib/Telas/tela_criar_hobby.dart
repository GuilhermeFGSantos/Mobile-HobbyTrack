import 'package:flutter/material.dart';
import 'auth_widgets.dart';

// Constantes de Cores
const Color corRoxoApp = Color(0xFF7B2CBF);
const Color corLaranjaApp = Color(0xFFF77F00);
const Color corTextoLabels = Color(0xFF2D2D2D);
const Color corTextoSub = Color(0xFF666666);
const Color corFundoCampos = Color(0xFFFAF6F0);
const Color corBordaCampos = Color(0xFFD6CFC7);

class CriarHobby extends StatelessWidget {
  const CriarHobby({super.key});

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
                    .zero, // Mudado para zero para a linha poder vazar 100%
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
                            'Criar Hobby',
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

                    // --- LINHA DIVISÓRIA (PEGA 100% DA TELA NATURALMENTE) ---
                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 0.5,
                      height: 0.5,
                    ),
                    const SizedBox(height: 30),

                    // --- BLOCO COM PADDING 24: RESTANTE DO FORMULÁRIO ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nome',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: corTextoLabels,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildCustomTextField(hintText: 'Pintura'),

                          const SizedBox(height: 14),
                          const Text(
                            'Emoji',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: corTextoLabels,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildCustomTextField(hintText: '🎨'),

                          const SizedBox(height: 20),

                          // Card de Meta Diária
                          _buildMetaDiariaCard(),

                          const SizedBox(height: 32),

                          Center(
                            child: SizedBox(
                              width: 230,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF949494),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Criar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 120), // Espaço da Bottom Bar
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
                  _buildHeaderCircleIcon(Icons.notifications),
                  const SizedBox(width: 10),
                  _buildHeaderCircleIcon(Icons.person),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCircleIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey[600], size: 24),
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
          const SizedBox(height: 4),
          const Text(
            'Qual é a sua meta para este hobby?',
            style: TextStyle(color: corTextoSub, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Meta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: corTextoLabels,
            ),
          ),
          const SizedBox(height: 6),
          _buildDropdownSelector(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Repetir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: corTextoLabels,
                ),
              ),
              Switch(value: true, onChanged: (v) {}, activeColor: corRoxoApp),
            ],
          ),
          const SizedBox(height: 8),
          _buildDaysOfWeek(),
          const SizedBox(height: 18),
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
              _buildTimeBox('19'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  ':',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              _buildTimeBox('30'),
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
          const SizedBox(height: 16),
          _buildConflitoHorarioCard(),
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

  Widget _buildConflitoHorarioCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAA675)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: corLaranjaApp,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conflito de Horário',
                        style: TextStyle(
                          color: corLaranjaApp,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Há um conflito de horário com outras atividades já agendadas: Leitura diária',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE7D6),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
            ),
            child: const Text(
              'Segundas às 19:30',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: corTextoLabels,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
