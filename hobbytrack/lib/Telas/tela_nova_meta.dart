import 'package:flutter/material.dart';
import 'meta_model.dart';
import 'mobile_frame.dart';

const Color _bgOffWhite = Color(0xFFFFF7F0);
const Color _purple = Color(0xFF8738F2);
const Color _orange = Color(0xFFFF7A00);
const Color _grayText = Color(0xFF6B6474);
const Color _grayLight = Color(0xFF9E9E9E);
const Color _bordaInput = Color(0xFFD9D9D9);

class TelaNovaMeta extends StatefulWidget {
  final Meta? metaExistente;

  const TelaNovaMeta({super.key, this.metaExistente});

  @override
  State<TelaNovaMeta> createState() => _TelaNovaMetaState();
}

class _TelaNovaMetaState extends State<TelaNovaMeta> {
  late TextEditingController nomeCtrl;
  late TextEditingController valorCtrl;
  late TextEditingController emojiCtrl;

  TipoMeta tipo = TipoMeta.quantitativa;
  Frequencia frequencia = Frequencia.porPeriodo(
    vezes: 1,
    unidade: UnidadePeriodo.semana,
  );
  Color cor = coresDisponiveis.first;

  bool get editando => widget.metaExistente != null;

  @override
  void initState() {
    super.initState();
    final m = widget.metaExistente;
    nomeCtrl = TextEditingController(text: m?.nome ?? '');
    valorCtrl = TextEditingController(
      text: m != null && m.valorAlvo > 0 ? '${m.valorAlvo}' : '',
    );
    emojiCtrl = TextEditingController(text: m?.emoji ?? '');
    tipo = m?.tipo ?? TipoMeta.quantitativa;
    frequencia = m?.frequencia ??
        Frequencia.porPeriodo(vezes: 1, unidade: UnidadePeriodo.semana);
    cor = m?.cor ?? coresDisponiveis.first;
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    valorCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  void salvar() {
    if (nomeCtrl.text.trim().isEmpty) {
      _mostrarErro('Informe o nome da meta.');
      return;
    }
    if (!frequencia.valida) {
      _mostrarErro('Defina a frequência da meta.');
      return;
    }

    final valor = int.tryParse(valorCtrl.text.trim()) ?? 0;
    if (tipo == TipoMeta.quantitativa && valor <= 0) {
      _mostrarErro('Informe um valor para a meta quantitativa.');
      return;
    }

    final novaMeta = Meta(
      nome: nomeCtrl.text.trim(),
      emoji: emojiCtrl.text.trim().isEmpty ? '🎯' : emojiCtrl.text.trim(),
      cor: cor,
      tipo: tipo,
      frequencia: frequencia,
      valorAlvo: tipo == TipoMeta.quantitativa ? valor : 0,
      progresso: widget.metaExistente?.progresso ?? 0,
      status: widget.metaExistente?.status ?? StatusMeta.emAndamento,
      checks: tipo == TipoMeta.qualitativa
          ? List<EstadoCheck>.filled(
              frequencia.totalOcorrencias,
              EstadoCheck.vazio,
            )
          : const [],
    );

    Navigator.pop(context, novaMeta);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Scaffold(
      backgroundColor: _bgOffWhite,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HeaderNovaMeta(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(50),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),

                        Text(
                          editando ? 'Editar Meta' : 'Nova Meta',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const _Rotulo('Nome da meta'),
                        const SizedBox(height: 6),
                        _CampoTexto(
                          controller: nomeCtrl,
                          hint: 'Digite o nome da meta',
                        ),

                        const SizedBox(height: 16),

                        const _Rotulo('Tipo de meta'),
                        const SizedBox(height: 6),
                        _RadioTipo(
                          label: 'Quantitativa',
                          descricao: 'Metas que têm um valor numérico',
                          valor: TipoMeta.quantitativa,
                          grupo: tipo,
                          onTap: () =>
                              setState(() => tipo = TipoMeta.quantitativa),
                        ),
                        const SizedBox(height: 8),
                        _RadioTipo(
                          label: 'Qualitativo',
                          descricao: 'Metas baseadas em frequência e hábitos',
                          valor: TipoMeta.qualitativa,
                          grupo: tipo,
                          onTap: () =>
                              setState(() => tipo = TipoMeta.qualitativa),
                        ),

                        if (tipo == TipoMeta.quantitativa) ...[
                          const SizedBox(height: 16),
                          const _Rotulo('Meta'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  'Valor:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _grayText,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _CampoTexto(
                                  controller: valorCtrl,
                                  hint: 'Digite o valor',
                                  numerico: true,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        const _Rotulo('Frequência'),
                        const SizedBox(height: 6),
                        _SeletorFrequencia(
                          valor: frequencia,
                          onChanged: (f) => setState(() => frequencia = f),
                        ),

                        const SizedBox(height: 16),

                        const _Rotulo('Emoji'),
                        const SizedBox(height: 6),
                        _CampoTexto(
                          controller: emojiCtrl,
                          hint: 'Toque para escolher',
                        ),

                        const SizedBox(height: 16),

                        const _Rotulo('Cor'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final c in coresDisponiveis) ...[
                              _BolinhaCor(
                                cor: c,
                                selecionada: c == cor,
                                onTap: () => setState(() => cor = c),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ],
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: GestureDetector(
                            onTap: salvar,
                            child: Container(
                              width: 240,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  colors: [_orange, _purple],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: const Text(
                                'Salvar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _HeaderNovaMeta extends StatelessWidget {
  const _HeaderNovaMeta();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 130),
      painter: _NovaMetaHeaderPainter(),
    );
  }
}

class _NovaMetaHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [_purple, _orange],
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      ).createShader(rect);

    final path = Path();
    path.lineTo(0, size.height * 0.55);
    path.cubicTo(
      size.width * 0.22, size.height * 0.45,
      size.width * 0.40, size.height * 0.85,
      size.width * 0.55, size.height * 0.82,
    );
    path.cubicTo(
      size.width * 0.72, size.height * 0.78,
      size.width * 0.86, size.height * 0.55,
      size.width, size.height * 0.60,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool numerico;

  const _CampoTexto({
    required this.controller,
    required this.hint,
    this.numerico = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: numerico ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _grayLight),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _bordaInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _purple, width: 1.3),
        ),
      ),
    );
  }
}

class _RadioTipo extends StatelessWidget {
  final String label;
  final String descricao;
  final TipoMeta valor;
  final TipoMeta grupo;
  final VoidCallback onTap;

  const _RadioTipo({
    required this.label,
    required this.descricao,
    required this.valor,
    required this.grupo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selecionado = valor == grupo;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selecionado ? _purple : _grayLight,
                width: 1.6,
              ),
            ),
            alignment: Alignment.center,
            child: selecionado
                ? Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: _purple,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  descricao,
                  style: const TextStyle(fontSize: 11, color: _grayText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeletorFrequencia extends StatelessWidget {
  final Frequencia valor;
  final ValueChanged<Frequencia> onChanged;

  const _SeletorFrequencia({required this.valor, required this.onChanged});

  bool get _porPeriodo => valor.tipo == TipoFrequencia.porPeriodo;

  void _trocarTipo(TipoFrequencia novoTipo) {
    if (novoTipo == valor.tipo) return;
    if (novoTipo == TipoFrequencia.porPeriodo) {
      onChanged(
        Frequencia.porPeriodo(vezes: 1, unidade: UnidadePeriodo.semana),
      );
    } else {
      onChanged(Frequencia.diasSemana({}));
    }
  }

  void _alterarVezes(int delta) {
    final novo = (valor.vezes + delta).clamp(1, 99);
    onChanged(Frequencia.porPeriodo(vezes: novo, unidade: valor.unidade));
  }

  void _trocarUnidade(UnidadePeriodo nova) {
    onChanged(Frequencia.porPeriodo(vezes: valor.vezes, unidade: nova));
  }

  void _alternarDia(int dia) {
    final novos = Set<int>.from(valor.dias);
    if (novos.contains(dia)) {
      novos.remove(dia);
    } else {
      novos.add(dia);
    }
    onChanged(Frequencia.diasSemana(novos));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToggleModoFrequencia(
          porPeriodoSelecionado: _porPeriodo,
          onSelecionar: _trocarTipo,
        ),
        const SizedBox(height: 10),

        if (_porPeriodo)
          _ModoPorPeriodo(
            vezes: valor.vezes,
            unidade: valor.unidade,
            onIncrementar: () => _alterarVezes(1),
            onDecrementar: () => _alterarVezes(-1),
            onTrocarUnidade: _trocarUnidade,
          )
        else
          _ModoDiasSemana(
            diasSelecionados: valor.dias,
            onTap: _alternarDia,
          ),

        const SizedBox(height: 6),
        Text(
          valor.valida
              ? 'Frequência: ${valor.descricao}'
              : 'Selecione pelo menos um dia',
          style: TextStyle(
            fontSize: 11,
            color: valor.valida ? _grayText : _orange,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ToggleModoFrequencia extends StatelessWidget {
  final bool porPeriodoSelecionado;
  final ValueChanged<TipoFrequencia> onSelecionar;

  const _ToggleModoFrequencia({
    required this.porPeriodoSelecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordaInput),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AbaToggle(
              texto: 'Por período',
              selecionado: porPeriodoSelecionado,
              onTap: () => onSelecionar(TipoFrequencia.porPeriodo),
            ),
          ),
          Expanded(
            child: _AbaToggle(
              texto: 'Dias específicos',
              selecionado: !porPeriodoSelecionado,
              onTap: () => onSelecionar(TipoFrequencia.diasSemana),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbaToggle extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const _AbaToggle({
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selecionado
              ? const LinearGradient(colors: [_purple, _orange])
              : null,
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selecionado ? Colors.white : _grayText,
          ),
        ),
      ),
    );
  }
}

class _ModoPorPeriodo extends StatelessWidget {
  final int vezes;
  final UnidadePeriodo unidade;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final ValueChanged<UnidadePeriodo> onTrocarUnidade;

  const _ModoPorPeriodo({
    required this.vezes,
    required this.unidade,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onTrocarUnidade,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BotaoStep(icone: Icons.remove, onTap: onDecrementar),
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            '$vezes',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        _BotaoStep(icone: Icons.add, onTap: onIncrementar),
        const SizedBox(width: 10),
        const Text(
          'por',
          style: TextStyle(fontSize: 13, color: _grayText),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _bordaInput),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UnidadePeriodo>(
                value: unidade,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _grayText),
                style: const TextStyle(fontSize: 13, color: Colors.black),
                onChanged: (v) {
                  if (v != null) onTrocarUnidade(v);
                },
                items: const [
                  DropdownMenuItem(
                    value: UnidadePeriodo.dia,
                    child: Text('dia'),
                  ),
                  DropdownMenuItem(
                    value: UnidadePeriodo.semana,
                    child: Text('semana'),
                  ),
                  DropdownMenuItem(
                    value: UnidadePeriodo.mes,
                    child: Text('mês'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoStep extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;

  const _BotaoStep({required this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _bordaInput),
        ),
        child: Icon(icone, size: 16, color: _purple),
      ),
    );
  }
}

class _ModoDiasSemana extends StatelessWidget {
  final Set<int> diasSelecionados;
  final ValueChanged<int> onTap;

  const _ModoDiasSemana({
    required this.diasSelecionados,
    required this.onTap,
  });

  static const _siglas = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 7; i++)
          _ChipDia(
            sigla: _siglas[i],
            selecionado: diasSelecionados.contains(i),
            onTap: () => onTap(i),
          ),
      ],
    );
  }
}

class _ChipDia extends StatelessWidget {
  final String sigla;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipDia({
    required this.sigla,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado ? _purple : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: selecionado ? _purple : _bordaInput,
            width: 1.2,
          ),
        ),
        child: Text(
          sigla,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selecionado ? Colors.white : _grayText,
          ),
        ),
      ),
    );
  }
}

class _BolinhaCor extends StatelessWidget {
  final Color cor;
  final bool selecionada;
  final VoidCallback onTap;

  const _BolinhaCor({
    required this.cor,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(
            color: selecionada ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
