import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_widgets.dart';

const Color corRoxoApp = Color(0xFF7B2CBF);
const Color corLaranjaApp = Color(0xFFF77F00);
const Color corTextoLabels = Color(0xFF2D2D2D);
const Color corTextoSub = Color(0xFF666666);
const Color corFundoCampos = Color(0xFFFAF6F0);
const Color corBordaCampos = Color(0xFFD6CFC7);

class EditarHobby extends StatefulWidget {
  final String hobbyId;
  final Map<String, dynamic> dadosIniciaisHobby;
  final Map<String, dynamic>? dadosIniciaisMeta;
  final String? metaDocId;

  const EditarHobby({
    super.key,
    required this.hobbyId,
    required this.dadosIniciaisHobby,
    this.dadosIniciaisMeta,
    this.metaDocId,
  });

  @override
  State<EditarHobby> createState() => _EditarHobbyState();
}

class _EditarHobbyState extends State<EditarHobby> {
  late TextEditingController nomeController;
  late TextEditingController metaQuantidadeController;
  late TextEditingController emojiController;

  late String metaSelecionada;
  late bool repetirOpcao;
  late bool mostrarNotificacao;
  late TimeOfDay horarioLembrete;

  final List<String> nomesDias = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];
  late List<bool> diasSelecionados;

  void handleInitialData() {
    nomeController = TextEditingController(
      text: widget.dadosIniciaisHobby['nome'] ?? '',
    );
    emojiController = TextEditingController(
      text: widget.dadosIniciaisHobby['emoji'] ?? '📖',
    );

    final metaData = widget.dadosIniciaisMeta;
    metaQuantidadeController = TextEditingController(
      text: metaData?['meta_valor']?.toString() ?? '20',
    );

    String metaDoBanco = metaData?['meta_tipo'] ?? '';

    const opcoesValidas = ['Minutos', 'Horas', 'Páginas', 'Vezes'];

    if (opcoesValidas.contains(metaDoBanco)) {
      metaSelecionada = metaDoBanco;
    } else {
      metaSelecionada = 'Minutos';
    }

    repetirOpcao = metaData?['repetir'] ?? true;
    mostrarNotificacao = metaData?['mostrar_notificacao'] ?? true;

    String horarioString = metaData?['horario_lembrete'] ?? "19:30";
    try {
      final partes = horarioString.split(':');
      horarioLembrete = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    } catch (_) {
      horarioLembrete = const TimeOfDay(hour: 19, minute: 30);
    }

    List<dynamic> diasDoBanco = metaData?['dias_semana'] ?? [];
    diasSelecionados = nomesDias
        .map((dia) => diasDoBanco.contains(dia))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    handleInitialData();
  }

  @override
  void dispose() {
    nomeController.dispose();
    metaQuantidadeController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  Future<void> atualizarHobbyFirebase() async {
    print('metaDocId: ${widget.metaDocId}');
    if (nomeController.text.trim().isEmpty ||
        emojiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro!! Preencha todos os campos.")),
      );
      return;
    }

    final int valorNumerico =
        int.tryParse(metaQuantidadeController.text.trim()) ?? 20;

    List<String> diasParaSalvar = [];
    for (int i = 0; i < diasSelecionados.length; i++) {
      if (diasSelecionados[i]) {
        diasParaSalvar.add(nomesDias[i]);
      }
    }

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('hobbies').doc(widget.hobbyId).update({
        'nome': nomeController.text.trim(),
        'emoji': emojiController.text.trim(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      if (widget.metaDocId != null) {
        await firestore
            .collection('hobbies')
            .doc(widget.hobbyId)
            .collection('metas')
            .doc(widget.metaDocId)
            .update({
              'meta_tipo': metaSelecionada,
              'meta_valor': valorNumerico,
              'repetir': repetirOpcao,
              'dias_semana': nomesDias
                  .asMap()
                  .entries
                  .where((entry) => diasSelecionados[entry.key])
                  .map((entry) => entry.value)
                  .toList(),
              'horario_lembrete':
                  '${horarioLembrete.hour.toString().padLeft(2, '0')}:${horarioLembrete.minute.toString().padLeft(2, '0')}',
              'mostrar_notificacao': mostrarNotificacao,
            });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobby atualizado com sucesso! 🎉')),
        );
        Navigator.maybePop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
    }
  }

  Future<void> selecionarHora(BuildContext context) async {
    final TimeOfDay? obtida = await showTimePicker(
      context: context,
      initialTime: horarioLembrete,
    );
    if (obtida != null && obtida != horarioLembrete) {
      setState(() {
        horarioLembrete = obtida;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
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
                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 0.5,
                      height: 0.5,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC7EBC3),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  emojiController.text,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nome do Hobby',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: corTextoLabels,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _buildCustomTextField(
                                      controller: nomeController,
                                      hintText: 'Ex: Leitura diária',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildMetaDiariaCard(),
                          const SizedBox(height: 20),
                          _buildEmojiCard(),
                          const SizedBox(height: 32),
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
                                onPressed: atualizarHobbyFirebase,
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
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: corFundoCampos,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corBordaCampos, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
        ),
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

          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: corBordaCampos, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: metaQuantidadeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '20',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
                Container(height: 24, width: 1, color: corBordaCampos),
                Expanded(
                  flex: 7,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: metaSelecionada,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[600],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Minutos',
                          child: Text('Minutos'),
                        ),
                        DropdownMenuItem(value: 'Horas', child: Text('Horas')),
                        DropdownMenuItem(
                          value: 'Páginas',
                          child: Text('Páginas'),
                        ),
                        DropdownMenuItem(value: 'Vezes', child: Text('Vezes')),
                      ],
                      onChanged: (String? novoValor) {
                        if (novoValor != null) {
                          setState(() {
                            metaSelecionada = novoValor;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

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
              Switch(
                value: repetirOpcao,
                onChanged: (v) => setState(() => repetirOpcao = v),
                activeColor: corRoxoApp,
              ),
            ],
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
          GestureDetector(
            onTap: () => selecionarHora(context),
            child: Row(
              children: [
                _buildTimeBox(horarioLembrete.hour.toString().padLeft(2, '0')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ':',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                _buildTimeBox(
                  horarioLembrete.minute.toString().padLeft(2, '0'),
                ),
              ],
            ),
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
              Switch(
                value: mostrarNotificacao,
                onChanged: (v) => setState(() => mostrarNotificacao = v),
                activeColor: corRoxoApp,
              ),
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
          _buildCustomTextField(
            controller: emojiController,
            hintText: 'Toque para escolher',
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(nomesDias.length, (index) {
        final dia = nomesDias[index];
        final estaSelecionado = diasSelecionados[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              diasSelecionados[index] = !diasSelecionados[index];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: estaSelecionado ? corLaranjaApp : Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dia,
              style: TextStyle(
                color: estaSelecionado ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
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
