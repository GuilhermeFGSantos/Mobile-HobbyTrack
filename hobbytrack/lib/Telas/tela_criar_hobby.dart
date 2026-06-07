import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Constantes de Cores
const Color corRoxoApp = Color(0xFF7B2CBF);
const Color corLaranjaApp = Color(0xFFF77F00);
const Color corTextoLabels = Color(0xFF2D2D2D);
const Color corTextoSub = Color(0xFF666666);
const Color corFundoCampos = Color(0xFFFAF6F0);
const Color corBordaCampos = Color(0xFFD6CFC7);

class CriarHobby extends StatefulWidget {
  const CriarHobby({super.key});

  @override
  State<CriarHobby> createState() => _CriarHobbyState();
}

class _CriarHobbyState extends State<CriarHobby> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emojiController = TextEditingController();
  final TextEditingController metaQuantidadeController =
      TextEditingController();

  bool repetirOpcao = true;
  String metaQuantidade = "1";
  String metaSelecionada = 'Minutos';
  bool mostrarNotificacao = true;
  List<String> diasParaSalvar = [];

  TimeOfDay horarioLembrete = const TimeOfDay(hour: 10, minute: 00);

  final List<bool> diasSelecionados = [
    false,
    true,
    false,
    false,
    false,
    false,
    false,
  ];
  final List<String> nomesDias = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];

  Future<void> selecionarHora(BuildContext context) async {
    final TimeOfDay? novoHorario = await showTimePicker(
      context: context,
      initialTime: horarioLembrete,
    );
    if (novoHorario != null) {
      setState(() {
        horarioLembrete = novoHorario;
      });
    }
  }

  Future<void> salvarHobbyFirebase() async {
    for (int i = 0; i < diasSelecionados.length; i++) {
      if (diasSelecionados[i]) {
        diasParaSalvar.add(nomesDias[i]);
      }
    }
    if (nomeController.text.isEmpty ||
        emojiController.text.isEmpty ||
        metaQuantidade.trim().isEmpty ||
        diasParaSalvar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro!! Preencha todos os campos.")),
      );
      return;
    }

    final int? metaValorNumerico = int.tryParse(
      metaQuantidadeController.text.trim(),
    );

    if (metaValorNumerico == null || metaValorNumerico <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Erro!! Insira um valor numérico válido maior que zero.",
          ),
        ),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      DocumentReference hobbyRef = await firestore.collection('hobbies').add({
        'userId': userId,
        'nome': nomeController.text,
        'emoji': emojiController.text,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      String novoHobbyId = hobbyRef.id;

      await firestore
          .collection('hobbies')
          .doc(novoHobbyId)
          .collection('metas')
          .add({
            'meta_tipo': metaSelecionada,
            'meta_valor': metaValorNumerico,
            'repetir': repetirOpcao,
            'dias_semana': diasParaSalvar,
            'horario_lembrete':
                '${horarioLembrete.hour.toString().padLeft(2, '0')}:${horarioLembrete.minute.toString().padLeft(2, '0')}',
            'mostrar_notificacao': mostrarNotificacao,
            'criadaEm': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobby criado com sucesso!')),
        );
        Navigator.maybePop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  void limpar() {
    nomeController.dispose();
    emojiController.dispose();
    super.dispose();
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

                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 0.5,
                      height: 0.5,
                    ),
                    const SizedBox(height: 30),

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
                          _buildCustomTextField(
                            hintText: 'Teste',
                            controller: nomeController,
                            keyboardType: TextInputType.text,
                          ),

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
                          _buildCustomTextField(
                            hintText: '🎨',
                            controller: emojiController,
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 20),

                          _buildMetaDiariaCard(),

                          const SizedBox(height: 32),

                          Center(
                            child: SizedBox(
                              width: 230,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  salvarHobbyFirebase();
                                },
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
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    List<TextInputFormatter>? formatters,
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
        keyboardType: keyboardType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
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

          Container(
            height: 44,
            decoration: BoxDecoration(
              color: corFundoCampos,
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
                    style: const TextStyle(color: corTextoLabels, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '00',
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: metaSelecionada,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[600],
          ),
          items: const [
            DropdownMenuItem(value: 'Minutos', child: Text('20 Minutos')),
            DropdownMenuItem(value: 'Horas', child: Text('1 Hora')),
            DropdownMenuItem(value: 'Paginas', child: Text('10 Páginas')),
          ],
          onChanged: (String? novoValor) {
            if (novoValor != null) {
              setState(() {
                metaSelecionada = novoValor;
                metaQuantidade = novoValor == 'Minutos'
                    ? '20'
                    : (novoValor == 'Horas' ? '1' : '10');
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(nomesDias.length, (index) {
        final booleanSelecionado = diasSelecionados[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              diasSelecionados[index] = !diasSelecionados[index];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: booleanSelecionado
                  ? corLaranjaApp
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              nomesDias[index],
              style: TextStyle(
                color: booleanSelecionado ? Colors.white : Colors.black54,
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
