import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobbytrack/Telas/tela_categorias.dart';
import 'package:hobbytrack/Telas/tela_criar_hobby.dart';
import 'package:hobbytrack/Telas/tela_registrar_progresso.dart';
import 'package:hobbytrack/Telas/tela_editar_hobby.dart';
import 'package:hobbytrack/Telas/tela_insights.dart';
import 'package:hobbytrack/Telas/tela_metas.dart';
import 'package:hobbytrack/Telas/tela_notificacoes.dart';
import 'package:hobbytrack/Telas/tela_perfil.dart';
import 'auth_widgets.dart';
import 'tela_login.dart';

// ---------------------------------------------------------------------------
// Constantes de cor reutilizadas nesta tela
// ---------------------------------------------------------------------------
const _kBg = Color(0xFFFFF8F1);

// ---------------------------------------------------------------------------
// Mapeia o nome do ícone salvo no Firestore para um IconData do Flutter.
// Armazenar strings em vez de codePoints evita depender de valores numéricos
// frágeis e satisfaz a exigência de argumentos constantes do IconData.
// ---------------------------------------------------------------------------
IconData _iconeParaNome(String nome) {
  switch (nome) {
    case 'leitura':
      return Icons.menu_book_rounded;
    case 'musica':
      return Icons.music_note_rounded;
    case 'pintura':
      return Icons.brush_rounded;
    case 'esportes':
      return Icons.sports_basketball_rounded;
    case 'culinaria':
      return Icons.restaurant_rounded;
    case 'fotografia':
      return Icons.camera_alt_rounded;
    case 'jogos':
      return Icons.videogame_asset_rounded;
    case 'yoga':
      return Icons.self_improvement_rounded;
    default:
      return Icons.star_rounded;
  }
}

// ---------------------------------------------------------------------------
// Filtro por categoria (diálogo)
// ---------------------------------------------------------------------------
class _FiltroSheet extends StatefulWidget {
  final List<String> opcoes;
  final String selecionadoAtual;
  const _FiltroSheet({required this.opcoes, required this.selecionadoAtual});

  @override
  State<_FiltroSheet> createState() => _FiltroSheetState();
}

class _FiltroSheetState extends State<_FiltroSheet> {
  late String selecionado;
  final TextEditingController _busca = TextEditingController();

  @override
  void initState() {
    super.initState();
    selecionado = widget.selecionadoAtual;
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim().toLowerCase();
    // 'Todos' sempre aparece no topo; depois os nomes vindos do Firestore
    final todasOpcoes = ['Todos', ...widget.opcoes];
    final lista = termo.isEmpty
        ? todasOpcoes
        : todasOpcoes.where((n) => n.toLowerCase().contains(termo)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Text(
                'Filtro por nome',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              Spacer(),
              Icon(Icons.more_vert, size: 18, color: texto),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar',
              hintStyle: const TextStyle(color: texto, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: texto, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFE6E1D8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: roxo, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final nome = lista[i];
              final ativo = nome == selecionado;
              final icone = nome == 'Todos'
                  ? Icons.apps_rounded
                  : _iconeParaNome(nome.toLowerCase());
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => selecionado = nome),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ativo
                        ? roxo.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: ativo ? roxo : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: roxo.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(icone, color: roxo, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        nome,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                      const Spacer(),
                      if (ativo)
                        const Icon(Icons.check_rounded, color: roxo, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, selecionado),
            child: Container(
              width: double.infinity,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF7A00),
              ),
              child: const Text(
                'Aplicar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TelaHome — conectada ao Firebase Auth e ao Firestore
// ---------------------------------------------------------------------------

/// [TelaHome] exibe os hobbies do usuário autenticado em tempo real.
///
/// Lógica assíncrona e Firebase:
/// - [FirebaseAuth] fornece o usuário corrente e dispara [_validarDominio].
/// - [FirebaseFirestore] mantém uma stream ativa via [_streamHobbies] que
///   retorna apenas documentos onde `criado_por == email do usuário`.
/// - [_excluirHobby] remove um documento da coleção `hobbies` pelo ID.
/// - [_sair] encerra a sessão com `signOut()` e redireciona para o login.
class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  // Referências aos serviços do Firebase
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? _usuario;
  String _filtroAtivo = 'Todos';

  @override
  void initState() {
    super.initState();
    // Valida o domínio assim que a tela é montada.
    // Se inválido, o método redireciona antes de qualquer renderização.
    _validarDominio();
  }

  // -------------------------------------------------------------------------
  // Regra de negócio: somente e-mails @souunit.com.br têm acesso
  // -------------------------------------------------------------------------

  /// Verifica se o e-mail autenticado pertence ao domínio institucional.
  ///
  /// Caso contrário, chama [FirebaseAuth.signOut] e redireciona para o login,
  /// impedindo que a tela seja exibida para usuários externos.
  Future<void> _validarDominio() async {
    final user = _auth.currentUser;
    final email = user?.email ?? '';

    // Validação de domínio ativa apenas quando há usuário autenticado pelo Firebase.
    // Enquanto o login não estiver conectado ao Firebase, permite entrada sem auth.
    if (user != null && !email.endsWith('@souunit.com.br')) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaLogin()),
          (_) => false,
        );
      }
      return;
    }

    setState(() => _usuario = user);
  }

  // -------------------------------------------------------------------------
  // Nome exibido no cabeçalho
  // -------------------------------------------------------------------------

  /// Retorna o primeiro nome do usuário (displayName do Google) ou a parte
  /// local do e-mail quando o nome não está disponível.
  String get _nomeExibicao {
    if (_usuario == null) return 'você';
    final displayName = _usuario!.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }
    return _usuario!.email!.split('@').first;
  }

  // -------------------------------------------------------------------------
  // Stream do Firestore — leitura em tempo real (R do CRUD)
  // -------------------------------------------------------------------------

  /// Retorna uma [Stream] dos documentos na coleção `hobbies` filtrados
  /// pelo campo `criado_por`, garantindo que cada usuário veja apenas
  /// seus próprios registros.
  ///
  /// O [StreamBuilder] na UI reconstrói automaticamente sempre que há
  /// alteração no banco, sem necessidade de chamar setState manualmente.
  // Hobbies do usuário logado. A coleção `hobbies` é gravada pela tela
  // CriarHobby com o campo `userId` (o uid do Auth) — é por ele que filtramos.
  // Os documentos não têm campo `pausado`, então não dá pra filtrar por ele.
  Stream<QuerySnapshot<Map<String, dynamic>>> get _streamHobbies => _db
      .collection('hobbies')
      .where('userId', isEqualTo: _usuario?.uid ?? '')
      .snapshots();

  // Mesma fonte; mantido separado porque o card de "atividade em risco" o consome.
  Stream<QuerySnapshot<Map<String, dynamic>>> get _streamTodosHobbies => _db
      .collection('hobbies')
      .where('userId', isEqualTo: _usuario?.uid ?? '')
      .snapshots();

  // -------------------------------------------------------------------------
  // Delete do Firestore (D do CRUD)
  // -------------------------------------------------------------------------

  /// Remove o documento com [id] da coleção `hobbies`.
  ///
  /// A operação é assíncrona: o [StreamBuilder] reflete a exclusão em tempo
  /// real sem reload manual da tela.
  Future<void> _excluirHobby(String id) async {
    await _db.collection('hobbies').doc(id).delete();
  }

  Future<void> _pausarHobby(String id) async {
    await _db.collection('hobbies').doc(id).update({'pausado': true});
  }

  Future<void> _retomarHobby(String id) async {
    await _db.collection('hobbies').doc(id).update({
      'pausado': false,
      'ultima_atualizacao': Timestamp.now(),
    });
  }

  // -------------------------------------------------------------------------
  // Sign-out
  // -------------------------------------------------------------------------

  Future<void> _sair() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaLogin()),
        (_) => false,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // StreamBuilder assina a stream e reconstrói a seção de hobbies
    // sempre que o Firestore emite novos dados.
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _streamHobbies,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final carregando = snap.connectionState == ConnectionState.waiting;

        return Scaffold(
          backgroundColor: _kBg,
          body: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: ClipRect(
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: _kBg,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          left: false,
                          right: false,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 110),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com notificações e perfil/sair
                                _HeaderGradiente(onSair: _sair),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'hobbytrack_logo_sem_fundo.png',
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -30),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Saudação dinâmica com nome real do Firebase Auth
                                            Text(
                                              'Olá, $_nomeExibicao',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF2B2B2B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Que tal registrar um momento do seu hobby hoje?',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B6474),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const _BotaoRegistrar(),
                                const SizedBox(height: 22),
                                // Lista de hobbies — dados vindos do Firestore
                                _SecaoHobbiesAtivos(
                                  docs: docs,
                                  carregando: carregando,
                                  onExcluir: _excluirHobby,
                                  filtroAtivo: _filtroAtivo,
                                  onFiltroAlterado: (f) =>
                                      setState(() => _filtroAtivo = f),
                                ),
                                const SizedBox(height: 22),
                                // Card de evolução com contagem real de hobbies
                                _CardEvolucao(docs: docs),
                                const SizedBox(height: 16),
                                StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: _streamTodosHobbies,
                                  builder: (context, snapTodos) {
                                    final todos = snapTodos.data?.docs ?? [];
                                    return _CardAtividadeRisco(
                                      docs: todos,
                                      onPausar: _pausarHobby,
                                      onRetomar: _retomarHobby,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _BottomNav(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header com gradiente
// ---------------------------------------------------------------------------

/// [onSair] é chamado ao fazer logout via ícone de perfil.
class _HeaderGradiente extends StatelessWidget {
  final VoidCallback onSair;
  const _HeaderGradiente({required this.onSair});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7C3AED), Color(0xFFC34CA3), Color(0xFFFF7A00)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                _IconeCirculo(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TelaNotificacoes()),
                  ),
                ),
                const SizedBox(width: 10),
                // Toque curto → perfil | Toque longo → logout
                _IconeCirculo(
                  icon: Icons.person_outline_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaPerfil()),
                  ),
                  onLongPress: () => _confirmarSaida(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo de confirmação de logout para evitar saída acidental.
  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSair();
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const amplitude = 16.0;
    const baseY = 16.0;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - baseY);
    for (int i = 0; i <= 100; i++) {
      final x = size.width * i / 100;
      final y =
          size.height - baseY + amplitude * math.sin(i / 100 * 2 * math.pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper _) => false;
}

class _IconeCirculo extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _IconeCirculo({required this.icon, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: _kBg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, color: texto, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão registrar progresso
// ---------------------------------------------------------------------------

class _BotaoRegistrar extends StatelessWidget {
  const _BotaoRegistrar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaRegistrarProgresso()),
        ),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [laranja, roxo]),
          ),
          child: const Text(
            '+ Registrar progresso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção de hobbies ativos — dados em tempo real do Firestore
// ---------------------------------------------------------------------------

/// Recebe [docs] da stream do Firestore e [onExcluir] para deletar um hobby.
///
/// Enquanto [carregando] é verdadeiro, exibe um indicador de progresso.
/// Quando [docs] está vazio, exibe um estado vazio amigável.
class _SecaoHobbiesAtivos extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final bool carregando;
  final Future<void> Function(String id) onExcluir;
  final String filtroAtivo;
  final ValueChanged<String> onFiltroAlterado;

  const _SecaoHobbiesAtivos({
    required this.docs,
    required this.carregando,
    required this.onExcluir,
    required this.filtroAtivo,
    required this.onFiltroAlterado,
  });

  @override
  Widget build(BuildContext context) {
    // Nomes únicos dos hobbies para popular o filtro
    final nomesUnicos = docs
        .map((d) => d.data()['nome'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();

    // Aplica o filtro selecionado
    final docsFiltrados = filtroAtivo == 'Todos'
        ? docs
        : docs
              .where((d) => (d.data()['nome'] as String? ?? '') == filtroAtivo)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Hobbies ativos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              if (filtroAtivo != 'Todos')
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roxo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filtroAtivo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: roxo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final resultado = await showDialog<String>(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.25),
                    builder: (_) => Dialog(
                      backgroundColor: Colors.white,
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 80,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      child: _FiltroSheet(
                        opcoes: nomesUnicos,
                        selecionadoAtual: filtroAtivo,
                      ),
                    ),
                  );
                  if (resultado != null) onFiltroAlterado(resultado);
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.tune_rounded, size: 20, color: texto),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (carregando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: roxo)),
          )
        else if (docsFiltrados.isEmpty)
          const _EmptyHobbies()
        else
          _HobbiesScroller(docs: docsFiltrados, onExcluir: onExcluir),
      ],
    );
  }
}

class _HobbiesScroller extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final Future<void> Function(String id) onExcluir;

  const _HobbiesScroller({required this.docs, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    final items = docs.map((hobbyDoc) {
      final d = hobbyDoc.data();
      return FutureBuilder<QuerySnapshot>(
        future: hobbyDoc.reference.collection('metas').limit(1).get(),
        builder: (context, metaSnapshot) {
          if (!metaSnapshot.hasData) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(color: roxo)),
            );
          }
          final docsMeta = metaSnapshot.data!.docs;
          final metaDoc = docsMeta.isNotEmpty ? docsMeta.first : null;
          final m = metaDoc?.data() as Map<String, dynamic>? ?? {};
          return _CardHobby(
            id: hobbyDoc.id,
            metaDocId: metaDoc?.id ?? '',
            emoji: d['emoji'] as String? ?? '🎯',
            nome: d['nome'] as String? ?? '',
            onExcluir: () => onExcluir(hobbyDoc.id),
            metaTipo: m['meta_tipo'] as String? ?? 'Minutos',
            metaValor: m['meta_valor'] as int? ?? 20,
            repetir: m['repetir'] as bool? ?? true,
            diasSemana: List<String>.from(m['dias_semana'] as List? ?? []),
            horarioLembrete: m['horario_lembrete'] as String? ?? '19:30',
            mostrarNotificacao: m['mostrar_notificacao'] as bool? ?? true,
          );
        },
      );
    }).toList();

    // Grid de 2 colunas
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: items[i]),
              const SizedBox(width: 10),
              Expanded(child: i + 1 < items.length ? items[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// Estado vazio exibido quando o usuário ainda não tem hobbies no Firestore.
class _EmptyHobbies extends StatelessWidget {
  const _EmptyHobbies();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 40, color: texto),
            SizedBox(height: 8),
            Text(
              'Nenhum hobby cadastrado ainda.',
              style: TextStyle(fontSize: 13, color: texto),
            ),
            SizedBox(height: 4),
            Text(
              'Toque em "+ Registrar progresso" para começar!',
              style: TextStyle(fontSize: 11, color: texto),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de hobby individual — mostra progresso de hoje, sequência e lembrete
// ---------------------------------------------------------------------------

class _CardHobby extends StatefulWidget {
  final String id;
  final String emoji;
  final String nome;
  final VoidCallback onExcluir;
  final String metaTipo;
  final int metaValor;
  final bool repetir;
  final List<String> diasSemana;
  final String horarioLembrete;
  final bool mostrarNotificacao;
  final String metaDocId;

  const _CardHobby({
    required this.id,
    required this.emoji,
    required this.nome,
    required this.onExcluir,
    required this.metaTipo,
    required this.metaValor,
    required this.repetir,
    required this.diasSemana,
    required this.horarioLembrete,
    required this.mostrarNotificacao,
    required this.metaDocId,
  });

  @override
  State<_CardHobby> createState() => _CardHobbyState();
}

class _CardHobbyState extends State<_CardHobby> {
  int _progressoHoje = 0;
  int _streak = 0;
  bool _carregando = true;
  StreamSubscription<QuerySnapshot>? _sub;

  @override
  void initState() {
    super.initState();
    _iniciarStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _iniciarStream() {
    final agora = DateTime.now();
    final inicioDia = DateTime(agora.year, agora.month, agora.day);
    final limite = inicioDia.subtract(const Duration(days: 60));

    _sub = FirebaseFirestore.instance
        .collection('hobbies')
        .doc(widget.id)
        .collection('registros')
        .where('registradoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(limite))
        .snapshots()
        .listen((snap) => _processar(snap, inicioDia));
  }

  void _processar(QuerySnapshot snap, DateTime inicioDia) {
    int progresso = 0;
    final diasComRegistro = <String>{};

    for (final r in snap.docs) {
      final data = r.data() as Map<String, dynamic>;
      final ts = data['registradoEm'];
      if (ts == null) continue;
      final date = (ts as Timestamp).toDate();
      final chave = '${date.year}-${date.month}-${date.day}';
      diasComRegistro.add(chave);
      if (!date.isBefore(inicioDia)) {
        progresso += data['quantidade'] as int? ?? 0;
      }
    }

    int streak = 0;
    var dia = inicioDia;
    while (diasComRegistro.contains('${dia.year}-${dia.month}-${dia.day}')) {
      streak++;
      dia = dia.subtract(const Duration(days: 1));
    }
    if (streak == 0) {
      dia = inicioDia.subtract(const Duration(days: 1));
      while (diasComRegistro.contains('${dia.year}-${dia.month}-${dia.day}')) {
        streak++;
        dia = dia.subtract(const Duration(days: 1));
      }
    }

    if (mounted) {
      setState(() {
        _progressoHoje = progresso;
        _streak = streak;
        _carregando = false;
      });
    }
  }

  void _mostrarMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: roxo),
              title: const Text('Editar hobby'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarHobby(
                      hobbyId: widget.id,
                      dadosIniciaisHobby: {'nome': widget.nome, 'emoji': widget.emoji},
                      dadosIniciaisMeta: {
                        'meta_tipo': widget.metaTipo,
                        'meta_valor': widget.metaValor,
                        'repetir': widget.repetir,
                        'dias_semana': widget.diasSemana,
                        'horario_lembrete': widget.horarioLembrete,
                        'mostrar_notificacao': widget.mostrarNotificacao,
                      },
                      metaDocId: widget.metaDocId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir hobby', style: TextStyle(color: Colors.red)),
              onTap: () {
                FirebaseFirestore.instance.collection('hobbies').doc(widget.id).delete();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String get _labelMeta {
    final freq = widget.repetir ? 'Todo dia' : widget.diasSemana.join(', ');
    final abrev = switch (widget.metaTipo) {
      'Minutos' => 'min',
      'Horas'   => 'h',
      'Vezes'   => 'vez',
      'Páginas' => 'pág',
      _         => widget.metaTipo.toLowerCase(),
    };
    return '$freq • ${widget.metaValor} $abrev';
  }

  String get _labelProximo {
    if (!widget.repetir && widget.diasSemana.isNotEmpty) {
      const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final hoje = DateTime.now().weekday; // 1=seg … 7=dom
      for (var i = 0; i < 7; i++) {
        final diaNome = nomes[(hoje - 1 + i) % 7];
        if (widget.diasSemana.any((d) => d.startsWith(diaNome))) {
          return i == 0 ? 'Próximo: hoje' : 'Próximo: $diaNome';
        }
      }
      return 'Próximo: ${widget.diasSemana.first}';
    }
    return 'Próximo: hoje às ${widget.horarioLembrete}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.metaValor > 0
        ? (_progressoHoje / widget.metaValor).clamp(0.0, 1.0)
        : 0.0;
    final metaCumprida = _progressoHoje >= widget.metaValor && widget.metaValor > 0;
    final corAnel = metaCumprida ? const Color(0xFF5B4FCF) : roxo;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Topo: emoji + menu ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: roxo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarMenu(context),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.more_vert, size: 18, color: texto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Nome + meta ──
          Text(
            widget.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _labelMeta,
            style: const TextStyle(fontSize: 11, color: texto),
          ),
          const SizedBox(height: 12),

          // ── Meio: progresso circular + sequência ──
          if (_carregando)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Center(
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: roxo),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52, height: 52,
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 5,
                          backgroundColor: corAnel.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(corAnel),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_progressoHoje',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B2B2B),
                              height: 1,
                            ),
                          ),
                          Text(
                            '/${widget.metaValor}',
                            style: const TextStyle(fontSize: 9, color: texto),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _streak > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('sequência', style: TextStyle(fontSize: 10, color: texto)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 15)),
                                const SizedBox(width: 3),
                                Text(
                                  '$_streak dias',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2B2B2B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Text(
                          'Comece hoje! 💪',
                          style: TextStyle(fontSize: 11, color: texto.withValues(alpha: 0.7)),
                        ),
                ),
              ],
            ),

          const SizedBox(height: 10),
          // ── Rodapé: próximo lembrete ──
          const Divider(height: 1, color: Color(0xFFF0EBE8)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _labelProximo,
                    style: TextStyle(fontSize: 11, color: texto.withValues(alpha: 0.8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                metaCumprida
                    ? const Icon(Icons.check_circle, size: 22, color: Color(0xFF5B4FCF))
                    : Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: roxo.withValues(alpha: 0.35), width: 1.5),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de evolução — busca registros reais para calcular dias e evolução
// ---------------------------------------------------------------------------

class _CardEvolucao extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  const _CardEvolucao({required this.docs});

  @override
  State<_CardEvolucao> createState() => _CardEvolucaoState();
}

class _CardEvolucaoState extends State<_CardEvolucao> {
  int _diasConstancia = 0;
  double _evolucaoSemana = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _calcularStats();
  }

  @override
  void didUpdateWidget(_CardEvolucao old) {
    super.didUpdateWidget(old);
    if (old.docs.length != widget.docs.length) _calcularStats();
  }

  Future<void> _calcularStats() async {
    if (widget.docs.isEmpty) {
      if (mounted) setState(() { _diasConstancia = 0; _evolucaoSemana = 0; _carregando = false; });
      return;
    }

    final agora = DateTime.now();
    // Início da semana atual (segunda-feira)
    final inicioSemanaAtual = DateTime(agora.year, agora.month, agora.day)
        .subtract(Duration(days: agora.weekday - 1));

    final diasComRegistro = <String>{};
    int totalRegistradoSemana = 0;
    int totalMetaSemanal = 0;

    for (final doc in widget.docs) {
      // Meta diária do hobby
      final metaSnap = await doc.reference.collection('metas').limit(1).get();
      final metaDiaria = metaSnap.docs.isNotEmpty
          ? metaSnap.docs.first.data()['meta_valor'] as int? ?? 20
          : 20;
      totalMetaSemanal += metaDiaria * 7;

      // Registros desta semana
      final registrosSnap = await doc.reference
          .collection('registros')
          .where('registradoEm',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioSemanaAtual))
          .get();

      for (final r in registrosSnap.docs) {
        final ts = r.data()['registradoEm'];
        if (ts == null) continue;
        final data = (ts as Timestamp).toDate();
        diasComRegistro.add('${data.year}-${data.month}-${data.day}');
        totalRegistradoSemana += r.data()['quantidade'] as int? ?? 0;
      }
    }

    // % da meta semanal cumprida — cresce a cada registro novo
    final evolucao = totalMetaSemanal > 0
        ? (totalRegistradoSemana / totalMetaSemanal) * 100
        : 0.0;

    if (!mounted) return;
    setState(() {
      _diasConstancia = diasComRegistro.length;
      _evolucaoSemana = evolucao;
      _carregando = false;
    });
  }

  String get _mensagem {
    if (widget.docs.isEmpty) return 'Cadastre seu primeiro hobby para começar!';
    if (_diasConstancia >= 5) return 'Você manteve a constância esta semana! 🔥';
    if (_diasConstancia >= 3) return 'Continue cuidando dos seus hobbies! 🎯';
    return 'Continue cuidando dos seus hobbies! 🎯';
  }

  @override
  Widget build(BuildContext context) {
    final evolucaoTexto = '${_evolucaoSemana.toStringAsFixed(0)}%';
    final evolucaoCor = _evolucaoSemana >= 100
        ? const Color(0xFF22A45D)   // verde: meta cumprida
        : _evolucaoSemana >= 50
            ? const Color(0xFFF77F00) // laranja: metade do caminho
            : const Color(0xFF2B2B2B); // neutro: ainda começando

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sua evolução',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _mensagem,
                  style: const TextStyle(fontSize: 12, color: texto),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_carregando)
                  const SizedBox(
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: roxo),
                      ),
                    ),
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatEvolucao(
                            valor: '${widget.docs.length}',
                            rotulo: 'hobbies ativos',
                            cor: const Color(0xFF2B2B2B),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE0D9D2)),
                        Expanded(
                          child: _StatEvolucao(
                            valor: '$_diasConstancia',
                            rotulo: 'Dias de constância',
                            cor: const Color(0xFF2B2B2B),
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Color(0xFFE0D9D2)),
                        Expanded(
                          child: _StatEvolucao(
                            valor: evolucaoTexto,
                            rotulo: 'evolução da semana',
                            cor: evolucaoCor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatEvolucao extends StatelessWidget {
  final String valor;
  final String rotulo;
  final Color cor;
  const _StatEvolucao({
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rotulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: texto),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card de atividade em risco — dinâmico com dados do Firestore
// ---------------------------------------------------------------------------

class _CardAtividadeRisco extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final Future<void> Function(String id) onPausar;
  final Future<void> Function(String id) onRetomar;

  const _CardAtividadeRisco({
    required this.docs,
    required this.onPausar,
    required this.onRetomar,
  });

  // Retorna o hobby com mais dias sem atualizar (>= 3 dias)
  QueryDocumentSnapshot<Map<String, dynamic>>? get _hobbyEmRisco {
    QueryDocumentSnapshot<Map<String, dynamic>>? emRisco;
    int maiorDias = 2; // só mostra se >= 3 dias sem atualizar

    for (final doc in docs) {
      final d = doc.data();
      final pausado = d['pausado'] as bool? ?? false;
      if (pausado) continue;

      final ultima = d['ultima_atualizacao'];
      if (ultima == null) continue;

      final diasSemAtualizar = DateTime.now()
          .difference((ultima as Timestamp).toDate())
          .inDays;

      if (diasSemAtualizar > maiorDias) {
        maiorDias = diasSemAtualizar;
        emRisco = doc;
      }
    }
    return emRisco;
  }

  @override
  Widget build(BuildContext context) {
    final hobby = _hobbyEmRisco;

    // Oculta o card se não há nenhum hobby em risco
    if (hobby == null) return const SizedBox.shrink();

    final d = hobby.data();
    final nome = d['nome'] as String? ?? 'hobby';
    final ultima = (d['ultima_atualizacao'] as Timestamp).toDate();
    final dias = DateTime.now().difference(ultima).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC76D3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: laranja,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Atividade em risco',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: laranja,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Você está há $dias dias sem atualizar $nome.\nRetome agora para manter sua constância.',
                        style: const TextStyle(fontSize: 11, color: texto),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE5CC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onRetomar(hobby.id),
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: roxo,
                      ),
                      child: const Text(
                        'Retomar agora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onPausar(hobby.id),
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE6E1D8)),
                      ),
                      child: const Text(
                        'Pausar',
                        style: TextStyle(
                          color: Color(0xFF2B2B2B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
}

// ---------------------------------------------------------------------------
// Barra de navegação inferior
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  ativo: true,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.track_changes_outlined,
                  label: 'Metas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaMetas()),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categorias',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCategorias()),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Insights',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaInsights()),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -6,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CriarHobby()),
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [laranja, roxo]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ativo;
  final VoidCallback? onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    this.ativo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cor = ativo ? roxo : texto;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cor,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
