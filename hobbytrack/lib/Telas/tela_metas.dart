import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'meta_model.dart';
import 'mobile_frame.dart';
import 'tela_categorias.dart';
import 'tela_insights.dart';
import 'tela_notificacoes.dart';
import 'tela_nova_meta.dart';
import 'tela_perfil.dart';

// AVISO: existe um botão TEMPORÁRIO "[DEV] Testar Metas" na tela_login.dart
// que abre essa tela direto, só para facilitar o desenvolvimento do módulo
// de Metas enquanto a TelaHome (Igor) ainda não existe. Remover quando o
// fluxo Login -> Home -> Metas estiver pronto.

const Color _bgOffWhite = Color(0xFFFFF7F0);
const Color _purple = Color(0xFF8738F2);
const Color _orange = Color(0xFFFF7A00);
const Color _grayText = Color(0xFF6B6474);
const Color _grayLight = Color(0xFF9E9E9E);

class TelaMetas extends StatefulWidget {
  const TelaMetas({super.key});

  @override
  State<TelaMetas> createState() => _TelaMetasState();
}

class _TelaMetasState extends State<TelaMetas> {
  FiltroMeta filtro = FiltroMeta.todas;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // E-mail do usuário logado: é o campo que separa as metas de cada um,
  // igual a Home faz com os hobbies.
  String get _email => _auth.currentUser?.email ?? '';

  // "Atalho" para a coleção de metas no Firestore.
  CollectionReference<Map<String, dynamic>> get _metasRef =>
      _db.collection('metas');

  // Leitura em tempo real: só as metas do usuário logado. O StreamBuilder no
  // build assina essa stream e redesenha a tela sozinho a cada mudança no banco.
  Stream<QuerySnapshot<Map<String, dynamic>>> get _streamMetas =>
      _metasRef.where('criado_por', isEqualTo: _email).snapshots();

  // ----- Cálculos derivados da lista que chega da stream -----

  List<Meta> _aplicarFiltro(List<Meta> metas) {
    switch (filtro) {
      case FiltroMeta.todas:
        return metas;
      case FiltroMeta.emAndamento:
        return metas.where((m) => m.status == StatusMeta.emAndamento).toList();
      case FiltroMeta.concluidas:
        return metas.where((m) => m.status == StatusMeta.concluida).toList();
    }
  }

  int _contarAtivas(List<Meta> metas) =>
      metas.where((m) => m.status != StatusMeta.pausada).length;

  Meta? _maisFrequente(List<Meta> metas) {
    if (metas.isEmpty) return null;
    return metas.reduce(
      (a, b) => a.pontuacaoProgresso >= b.pontuacaoProgresso ? a : b,
    );
  }

  Future<void> abrirNovaMeta({Meta? metaParaEditar}) async {
    final resultado = await Navigator.push<Meta>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaNovaMeta(metaExistente: metaParaEditar),
      ),
    );

    if (resultado == null) return;

    // Edição: atualiza o documento existente (pelo id). Criação: novo
    // documento, com a data de criação. A stream reflete a mudança sozinha,
    // então nem precisamos de setState aqui.
    if (metaParaEditar?.id != null) {
      await _metasRef.doc(metaParaEditar!.id).update(resultado.toMap(_email));
    } else {
      await _metasRef.add({
        ...resultado.toMap(_email),
        'criado_em': Timestamp.now(),
      });
    }
  }

  Future<void> pausarMeta(Meta meta) async {
    final novoStatus = meta.status == StatusMeta.pausada
        ? StatusMeta.emAndamento
        : StatusMeta.pausada;
    await _metasRef.doc(meta.id).update({
      'status': novoStatus.name,
      'ultima_atualizacao': Timestamp.now(),
    });
    if (!mounted) return;
    final txt = novoStatus == StatusMeta.pausada
        ? 'Meta "${meta.titulo}" pausada.'
        : 'Meta "${meta.titulo}" retomada.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(txt), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> confirmarExclusao(Meta meta) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => _DialogExcluir(nomeMeta: meta.titulo),
    );

    if (confirmado != true) return;

    await _metasRef.doc(meta.id).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meta "${meta.titulo}" excluída.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void avisoSemAcao(String nome) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nome ainda não possui navegação.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> ajustarProgresso(Meta meta, int delta) async {
    if (meta.tipo != TipoMeta.quantitativa) return;
    final novo = (meta.progresso + delta).clamp(0, meta.valorAlvo);
    // Quantitativa conclui automaticamente ao bater o alvo.
    final novoStatus = novo >= meta.valorAlvo && meta.valorAlvo > 0
        ? StatusMeta.concluida
        : StatusMeta.emAndamento;
    await _metasRef.doc(meta.id).update({
      'progresso': novo,
      'status': novoStatus.name,
      'ultima_atualizacao': Timestamp.now(),
    });
  }

  // Cicla o estado do check no índice i: vazio → concluído → falhado → vazio.
  Future<void> alternarCheck(Meta meta, int i) async {
    if (i < 0 || i >= meta.checks.length) return;
    // Trabalha numa cópia e grava a lista inteira de volta no documento.
    final novosChecks = List<EstadoCheck>.from(meta.checks);
    novosChecks[i] = switch (novosChecks[i]) {
      EstadoCheck.vazio => EstadoCheck.concluido,
      EstadoCheck.concluido => EstadoCheck.falhado,
      EstadoCheck.falhado => EstadoCheck.vazio,
    };

    // Conclui automaticamente se todos os checks estão como concluído.
    final todosOk =
        novosChecks.isNotEmpty &&
        novosChecks.every((c) => c == EstadoCheck.concluido);
    final novoStatus = todosOk ? StatusMeta.concluida : StatusMeta.emAndamento;

    await _metasRef.doc(meta.id).update({
      'checks': novosChecks.map((c) => c.name).toList(),
      'status': novoStatus.name,
      'ultima_atualizacao': Timestamp.now(),
    });
  }

  // Conclusão manual — usada por metas qualitativas via menu ⋮.
  Future<void> concluirMeta(Meta meta) async {
    await _metasRef.doc(meta.id).update({
      'status': StatusMeta.concluida.name,
      'ultima_atualizacao': Timestamp.now(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meta "${meta.titulo}" marcada como concluída.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      // StreamBuilder: assina a coleção `metas` no Firestore e reconstrói a
      // tela sempre que algo muda no banco (criar/editar/excluir/pausar...).
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _streamMetas,
        builder: (context, snap) {
          // Cada documento vira uma Meta via Meta.fromDoc.
          final metas = (snap.data?.docs ?? []).map(Meta.fromDoc).toList();
          final carregando = snap.connectionState == ConnectionState.waiting;
          final lista = _aplicarFiltro(metas);

          return Scaffold(
            backgroundColor: _bgOffWhite,
            body: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _MetasHeader(),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _IconeCirculo(
                                    icone: Icons.notifications_outlined,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TelaNotificacoes(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _IconeCirculo(
                                    icone: Icons.person_outline,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TelaPerfil(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 64),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Metas',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Acompanhe sua evolução e mantenha a constância',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _grayText,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: _PainelEstatisticas(
                                ativas: _contarAtivas(metas),
                                maisFrequente: _maisFrequente(metas),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: _AbasFiltro(
                                filtroSelecionado: filtro,
                                onSelecionar: (f) => setState(() => filtro = f),
                              ),
                            ),

                            const SizedBox(height: 14),

                            if (carregando)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (lista.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 30,
                                ),
                                child: Center(
                                  child: Text(
                                    'Nenhuma meta nessa visualização.',
                                    style: TextStyle(
                                      color: _grayText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    for (final m in lista) ...[
                                      _CardMeta(
                                        meta: m,
                                        desabilitado:
                                            m.status == StatusMeta.pausada,
                                        onEditar: () =>
                                            abrirNovaMeta(metaParaEditar: m),
                                        onExcluir: () => confirmarExclusao(m),
                                        onPausar: () => pausarMeta(m),
                                        onCheckTap: (i) => alternarCheck(m, i),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                              ),

                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Botão flutuante no canto inferior direito (acima da bottom bar),
                // posicionado absoluto para não descer junto da lista.
                Positioned(
                  right: 18,
                  bottom: 16,
                  child: _BotaoNovaMeta(onTap: () => abrirNovaMeta()),
                ),
              ],
            ),

            bottomNavigationBar: _MetasBottomBar(
              onHomeTap: () => Navigator.pop(context),
              onCategoriasTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TelaCategorias()),
              ),
              onInsightsTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TelaInsights()),
              ),
              onAddTap: () => abrirNovaMeta(),
            ),
          );
        },
      ),
    );
  }
}

class _IconeCirculo extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;

  const _IconeCirculo({required this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: _bgOffWhite,
          shape: BoxShape.circle,
        ),
        child: Icon(icone, color: _grayLight, size: 20),
      ),
    );
  }
}

class _MetasHeader extends StatelessWidget {
  const _MetasHeader();

  @override
  Widget build(BuildContext context) {
    // Mesmo header em onda multicolor da TelaCategorias (HomeBackground):
    // uma faixa com SweepGradient roxo→laranja→roxo recortada pela HomeClipper,
    // deixando só a tira colorida em formato de onda no topo.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: SweepGradient(
                  center: Alignment.topCenter,
                  transform: GradientRotation(2.1),
                  colors: [roxo, laranja, roxo],
                  stops: [0.25, 0.63, 0.2],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topLeft,
              child: ClipPath(
                clipper: HomeClipper(),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: _bgOffWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PainelEstatisticas extends StatelessWidget {
  final int ativas;
  final Meta? maisFrequente;

  const _PainelEstatisticas({
    required this.ativas,
    required this.maisFrequente,
  });

  @override
  Widget build(BuildContext context) {
    final mf = maisFrequente;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ItemEstatistica(titulo: 'Metas ativas', valor: '$ativas'),
          ),
          Container(width: 1, height: 38, color: const Color(0xFFE6E6E6)),
          Expanded(
            child: _ItemEstatistica(
              titulo: 'Mais frequente do mês',
              valor: mf == null ? '—' : mf.hobby.nome,
              icone: mf?.icone,
              corIcone: mf?.cor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemEstatistica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData? icone;
  final Color? corIcone;

  const _ItemEstatistica({
    required this.titulo,
    required this.valor,
    this.icone,
    this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12, color: _grayText)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 18, color: corIcone ?? _orange),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                valor,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AbasFiltro extends StatelessWidget {
  final FiltroMeta filtroSelecionado;
  final ValueChanged<FiltroMeta> onSelecionar;

  const _AbasFiltro({
    required this.filtroSelecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          texto: 'Todas',
          selecionado: filtroSelecionado == FiltroMeta.todas,
          onTap: () => onSelecionar(FiltroMeta.todas),
        ),
        const SizedBox(width: 8),
        _Pill(
          texto: 'Em andamento',
          selecionado: filtroSelecionado == FiltroMeta.emAndamento,
          onTap: () => onSelecionar(FiltroMeta.emAndamento),
        ),
        const SizedBox(width: 8),
        _Pill(
          texto: 'Concluídas',
          selecionado: filtroSelecionado == FiltroMeta.concluidas,
          onTap: () => onSelecionar(FiltroMeta.concluidas),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const _Pill({
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? _purple : Colors.transparent,
          border: Border.all(color: _purple, width: 1.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: selecionado ? Colors.white : _purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  final Meta meta;
  final bool desabilitado;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onPausar;
  final ValueChanged<int> onCheckTap;

  const _CardMeta({
    required this.meta,
    required this.desabilitado,
    required this.onEditar,
    required this.onExcluir,
    required this.onPausar,
    required this.onCheckTap,
  });

  @override
  Widget build(BuildContext context) {
    final corFundo = meta.cor.withOpacity(desabilitado ? 0.10 : 0.22);

    return Opacity(
      opacity: desabilitado ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(meta.icone, color: meta.cor, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.subtitulo,
                    style: const TextStyle(fontSize: 11, color: _grayText),
                  ),
                  const SizedBox(height: 8),

                  if (meta.tipo == TipoMeta.quantitativa)
                    _ProgressoQuantitativo(meta: meta)
                  else
                    _ProgressoChecks(meta: meta, onCheckTap: onCheckTap),
                ],
              ),
            ),

            _MenuMeta(
              metaPausada: meta.status == StatusMeta.pausada,
              onEditar: onEditar,
              onExcluir: onExcluir,
              onPausar: onPausar,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressoQuantitativo extends StatelessWidget {
  final Meta meta;

  const _ProgressoQuantitativo({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso: ${meta.progresso}/${meta.valorAlvo}',
          style: const TextStyle(fontSize: 11, color: _grayText),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: meta.percentual,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.7),
            valueColor: AlwaysStoppedAnimation<Color>(meta.cor),
          ),
        ),
      ],
    );
  }
}

class _ProgressoChecks extends StatelessWidget {
  final Meta meta;
  final ValueChanged<int> onCheckTap;

  const _ProgressoChecks({required this.meta, required this.onCheckTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < meta.checks.length; i++) ...[
          GestureDetector(
            onTap: () => onCheckTap(i),
            child: _CaixaCheck(estado: meta.checks[i]),
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _CaixaCheck extends StatelessWidget {
  final EstadoCheck estado;

  static const Color _verde = Color(0xFF22C55E);
  static const Color _vermelho = Color(0xFFEF4444);

  const _CaixaCheck({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cor = switch (estado) {
      EstadoCheck.vazio => null,
      EstadoCheck.concluido => _verde,
      EstadoCheck.falhado => _vermelho,
    };
    final icone = switch (estado) {
      EstadoCheck.vazio => null,
      EstadoCheck.concluido => Icons.check,
      EstadoCheck.falhado => Icons.close,
    };

    return Container(
      width: 26,
      height: 22,
      decoration: BoxDecoration(
        color: cor ?? Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cor ?? Colors.white, width: 1),
      ),
      child: icone == null ? null : Icon(icone, color: Colors.white, size: 16),
    );
  }
}

class _MenuMeta extends StatelessWidget {
  final bool metaPausada;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onPausar;

  const _MenuMeta({
    required this.metaPausada,
    required this.onEditar,
    required this.onExcluir,
    required this.onPausar,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: _grayText),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (v) {
        switch (v) {
          case 'editar':
            onEditar();
            break;
          case 'excluir':
            onExcluir();
            break;
          case 'pausar':
            onPausar();
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'editar',
          height: 36,
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: _grayText),
              SizedBox(width: 8),
              Text('Editar', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'excluir',
          height: 36,
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pausar',
          height: 36,
          child: Row(
            children: [
              Icon(
                metaPausada ? Icons.play_arrow : Icons.pause,
                size: 16,
                color: _grayText,
              ),
              const SizedBox(width: 8),
              Text(
                metaPausada ? 'Retomar' : 'Pausar',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotaoNovaMeta extends StatelessWidget {
  final VoidCallback onTap;

  const _BotaoNovaMeta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 42,
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
          '+ Nova Meta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DialogExcluir extends StatelessWidget {
  final String nomeMeta;

  const _DialogExcluir({required this.nomeMeta});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Confirmar exclusão',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você tem certeza que deseja excluir a Meta "$nomeMeta"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _grayText),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _grayLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: _grayText, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetasBottomBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onCategoriasTap;
  final VoidCallback onInsightsTap;
  final VoidCallback onAddTap;

  const _MetasBottomBar({
    required this.onHomeTap,
    required this.onCategoriasTap,
    required this.onInsightsTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: _bgOffWhite,
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
              _ItemBottom(
                icone: Icons.home,
                label: 'Home',
                selecionado: false,
                onTap: onHomeTap,
              ),
              _ItemBottom(
                icone: Icons.track_changes,
                label: 'Metas',
                selecionado: true,
                onTap: () {},
              ),
              const SizedBox(width: 58),
              _ItemBottom(
                icone: Icons.grid_view_rounded,
                label: 'Categorias',
                selecionado: false,
                onTap: onCategoriasTap,
              ),
              _ItemBottom(
                icone: Icons.bar_chart_rounded,
                label: 'Insights',
                selecionado: false,
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
                    colors: [_purple, _orange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemBottom extends StatelessWidget {
  final IconData icone;
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _ItemBottom({
    required this.icone,
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? _purple : _grayLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: cor, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cor,
                fontWeight: selecionado ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
