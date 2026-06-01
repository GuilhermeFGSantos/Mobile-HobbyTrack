import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobbytrack/Telas/tela_categorias.dart';
import 'package:hobbytrack/Telas/tela_criar_hobby.dart';
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
void _abrirFiltro(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: _FiltroSheet(),
    ),
  );
}

class _FiltroSheet extends StatefulWidget {
  const _FiltroSheet();

  @override
  State<_FiltroSheet> createState() => _FiltroSheetState();
}

class _FiltroSheetState extends State<_FiltroSheet> {
  String selecionado = 'Todos';
  final TextEditingController _busca = TextEditingController();

  static const List<_OpcaoFiltro> _opcoes = [
    _OpcaoFiltro('Todos', Icons.apps_rounded, roxo),
    _OpcaoFiltro('Leitura', Icons.menu_book_rounded, Color(0xFF8FC79A)),
    _OpcaoFiltro('Violino', Icons.music_note_rounded, laranja),
    _OpcaoFiltro('Pintura', Icons.brush_rounded, Color(0xFFB39DDB)),
    _OpcaoFiltro('Esportes', Icons.sports_basketball_rounded, Color(0xFF64B5F6)),
  ];

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim().toLowerCase();
    final lista = termo.isEmpty
        ? _opcoes
        : _opcoes.where((o) => o.nome.toLowerCase().contains(termo)).toList();

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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              final o = lista[i];
              final ativo = o.nome == selecionado;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => selecionado = o.nome),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ativo ? roxo.withValues(alpha: 0.08) : Colors.transparent,
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
                          color: o.cor.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(o.icone, color: o.cor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        o.nome,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                      const Spacer(),
                      if (ativo) const Icon(Icons.check_rounded, color: roxo, size: 18),
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
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpcaoFiltro {
  final String nome;
  final IconData icone;
  final Color cor;
  const _OpcaoFiltro(this.nome, this.icone, this.cor);
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
  // Retorna apenas hobbies ativos (não pausados) do usuário
  Stream<QuerySnapshot<Map<String, dynamic>>> get _streamHobbies => _db
      .collection('hobbies')
      .where('criado_por', isEqualTo: _usuario?.email ?? '')
      .where('pausado', isEqualTo: false)
      .snapshots();

  // Retorna todos os hobbies incluindo pausados (para detectar atividade em risco)
  Stream<QuerySnapshot<Map<String, dynamic>>> get _streamTodosHobbies => _db
      .collection('hobbies')
      .where('criado_por', isEqualTo: _usuario?.email ?? '')
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'hobbytrack_logo_sem_fundo.png',
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -30),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                              style: TextStyle(fontSize: 13, color: Color(0xFF6B6474)),
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
                                ),
                                const SizedBox(height: 22),
                                // Card de evolução com contagem real de hobbies
                                _CardEvolucao(docs: docs),
                                const SizedBox(height: 16),
                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
      final y = size.height - baseY + amplitude * math.sin(i / 100 * 2 * math.pi);
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
          MaterialPageRoute(builder: (_) => const CriarHobby()),
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
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
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

  const _SecaoHobbiesAtivos({
    required this.docs,
    required this.carregando,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Hobbies ativos',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF2B2B2B)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _abrirFiltro(context),
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
          const SizedBox(
            height: 210,
            child: Center(child: CircularProgressIndicator(color: roxo)),
          )
        else if (docs.isEmpty)
          const _EmptyHobbies()
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final d = docs[i].data();
                return _CardHobby(
                  id: docs[i].id,
                  // icone e cor são mapeados a partir do nome salvo no Firestore
                  icone: _iconeParaNome(d['icone_nome'] as String? ?? ''),
                  corIcone: Color(d['cor'] as int? ?? 0xFF8FC79A),
                  nome: d['nome'] as String? ?? '',
                  info: d['info'] as String? ?? '',
                  progresso: d['progresso'] as int? ?? 0,
                  meta: d['meta'] as int? ?? 1,
                  streak: d['streak'] as String?,
                  proximo: d['proximo'] as String? ?? '',
                  onExcluir: () => onExcluir(docs[i].id),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(ativo: true),
              const SizedBox(width: 6),
              _Dot(ativo: false),
              const SizedBox(width: 6),
              _Dot(ativo: false),
            ],
          ),
        ),
      ],
    );
  }
}

/// Estado vazio exibido quando o usuário ainda não tem hobbies no Firestore.
class _EmptyHobbies extends StatelessWidget {
  const _EmptyHobbies();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 210,
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

class _Dot extends StatelessWidget {
  final bool ativo;
  const _Dot({required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ativo ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: ativo ? roxo : const Color(0xFFD9D4CC),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de hobby individual
// ---------------------------------------------------------------------------

/// [id] é o ID do documento no Firestore.
/// [onExcluir] deleta o documento via [_excluirHobby] do estado pai.
class _CardHobby extends StatelessWidget {
  final String id;
  final IconData icone;
  final Color corIcone;
  final String nome;
  final String info;
  final int progresso;
  final int meta;
  final String? streak;
  final String proximo;
  final VoidCallback onExcluir;

  const _CardHobby({
    required this.id,
    required this.icone,
    required this.corIcone,
    required this.nome,
    required this.info,
    required this.progresso,
    required this.meta,
    required this.streak,
    required this.proximo,
    required this.onExcluir,
  });

  /// Menu de contexto com opções de editar e excluir o hobby.
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
                  MaterialPageRoute(builder: (_) => const EditarHobby()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir hobby', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onExcluir();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double pct = meta == 0 ? 0 : progresso / meta;
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icone, color: corIcone, size: 22),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarMenu(context),
                child: const Icon(Icons.more_vert, size: 18, color: texto),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nome,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2B2B2B)),
          ),
          Text(info, style: const TextStyle(fontSize: 11, color: texto)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFEAE6DE),
                        valueColor: const AlwaysStoppedAnimation(roxo),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$progresso',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: roxo,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/$meta',
                          style: const TextStyle(fontSize: 9, color: texto, height: 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (streak != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('sequência', style: TextStyle(fontSize: 10, color: texto)),
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 2),
                          Text(
                            streak!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: laranja,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Próximo: $proximo',
                  style: const TextStyle(fontSize: 10, color: texto),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.radio_button_unchecked, size: 14, color: texto),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de evolução — usa contagem real de hobbies do Firestore
// ---------------------------------------------------------------------------

/// [totalHobbies] vem da quantidade de documentos retornados pelo Firestore.
class _CardEvolucao extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  const _CardEvolucao({required this.docs});

  // Maior streak entre todos os hobbies (ex: "7 dias" → 7)
  int get _maiorStreak {
    int max = 0;
    for (final doc in docs) {
      final streak = doc.data()['streak'] as String? ?? '';
      final num = int.tryParse(streak.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (num > max) max = num;
    }
    return max;
  }

  // Média de conclusão de todos os hobbies em %
  String get _evolucaoMedia {
    if (docs.isEmpty) return '0%';
    double soma = 0;
    for (final doc in docs) {
      final d = doc.data();
      final progresso = (d['progresso'] as int? ?? 0).toDouble();
      final meta = (d['meta'] as int? ?? 1).toDouble();
      soma += meta == 0 ? 0 : (progresso / meta) * 100;
    }
    final media = (soma / docs.length).round();
    return '+$media%';
  }

  // Exibe mensagem diferente conforme o progresso
  String get _mensagemConstancia {
    if (docs.isEmpty) return 'Cadastre seu primeiro hobby para começar!';
    final streak = _maiorStreak;
    if (streak >= 7) return 'Incrível! Você manteve a constância esta semana! 🔥';
    if (streak >= 3) return 'Você está mantendo a constância! Continue assim 💪';
    return 'Que tal registrar seu hobby hoje? 🎯';
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2B2B2B)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Center(
                  child: Text(
                    _mensagemConstancia,
                    style: const TextStyle(fontSize: 12, color: texto),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Total de hobbies vindo do Firestore
                    Expanded(
                      child: _StatEvolucao(
                        valor: '${docs.length}',
                        rotulo: 'hobbies ativos',
                        cor: const Color(0xFF2B2B2B),
                      ),
                    ),
                    // Maior streak entre todos os hobbies
                    Expanded(
                      child: _StatEvolucao(
                        valor: '$_maiorStreak',
                        rotulo: 'dias de constância',
                        cor: const Color(0xFF2B2B2B),
                      ),
                    ),
                    // Média de conclusão dos hobbies
                    Expanded(
                      child: _StatEvolucao(
                        valor: _evolucaoMedia,
                        rotulo: 'evolução da semana',
                        cor: const Color(0xFF22A36B),
                      ),
                    ),
                  ],
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
  const _StatEvolucao({required this.valor, required this.rotulo, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cor),
        ),
        const SizedBox(height: 2),
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
                const Icon(Icons.warning_amber_rounded, color: laranja, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Atividade em risco',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: laranja),
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
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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
                        style: TextStyle(color: Color(0xFF2B2B2B), fontSize: 12, fontWeight: FontWeight.w600),
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
                child: _NavItem(icon: Icons.home_rounded, label: 'Home', ativo: true),
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
  const _NavItem({required this.icon, required this.label, this.ativo = false, this.onTap});

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
