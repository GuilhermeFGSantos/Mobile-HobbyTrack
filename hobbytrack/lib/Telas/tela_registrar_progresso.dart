import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tela_notificacoes.dart';
import 'tela_perfil.dart';

const _kBg = Color(0xFFFFF8F1);
const _kPurple = Color(0xFF7B2CBF);
const _kOrange = Color(0xFFF77F00);
const _kGray = Color(0xFF6B6474);

class TelaRegistrarProgresso extends StatefulWidget {
  const TelaRegistrarProgresso({super.key});

  @override
  State<TelaRegistrarProgresso> createState() => _TelaRegistrarProgressoState();
}

class _TelaRegistrarProgressoState extends State<TelaRegistrarProgresso> {
  final _inputController = TextEditingController();

  List<_HobbyInfo> _hobbies = [];
  _HobbyInfo? _hobbySelecionado;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarHobbies();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _carregarHobbies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _carregando = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('hobbies')
        .where('userId', isEqualTo: user.uid)
        .get();

    final hobbies = <_HobbyInfo>[];
    for (final doc in snap.docs) {
      final d = doc.data();
      final metaSnap = await doc.reference.collection('metas').limit(1).get();
      String metaTipo = 'Minutos';
      int metaValor = 20;
      if (metaSnap.docs.isNotEmpty) {
        final m = metaSnap.docs.first.data();
        metaTipo = m['meta_tipo'] as String? ?? 'Minutos';
        metaValor = m['meta_valor'] as int? ?? 20;
      }

      // progresso atual do dia
      final hoje = DateTime.now();
      final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
      final registrosSnap = await doc.reference
          .collection('registros')
          .where('registradoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .get();
      int progressoHoje = 0;
      for (final r in registrosSnap.docs) {
        progressoHoje += (r.data()['quantidade'] as int? ?? 0);
      }

      hobbies.add(_HobbyInfo(
        id: doc.id,
        nome: d['nome'] as String? ?? '',
        emoji: d['emoji'] as String? ?? '🎯',
        metaTipo: metaTipo,
        metaValor: metaValor,
        progressoHoje: progressoHoje,
      ));
    }

    if (!mounted) return;
    setState(() {
      _hobbies = hobbies;
      _hobbySelecionado = hobbies.isNotEmpty ? hobbies.first : null;
      _carregando = false;
    });
  }

  String get _unidadeAbrev {
    switch (_hobbySelecionado?.metaTipo) {
      case 'Minutos':
        return 'min';
      case 'Horas':
        return 'h';
      case 'Páginas':
        return 'pág';
      case 'Vezes':
        return 'x';
      default:
        return 'min';
    }
  }

  Future<void> _salvar() async {
    final hobby = _hobbySelecionado;
    if (hobby == null) return;

    final quantidade = int.tryParse(_inputController.text.trim()) ?? 0;
    if (quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira uma quantidade válida.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      final hobbyRef =
          FirebaseFirestore.instance.collection('hobbies').doc(hobby.id);
      await hobbyRef.collection('registros').add({
        'quantidade': quantidade,
        'tipo': hobby.metaTipo,
        'registradoEm': FieldValue.serverTimestamp(),
      });
      await hobbyRef
          .update({'ultima_atualizacao': FieldValue.serverTimestamp()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progresso salvo! 🎉'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _Header(onVoltar: () => Navigator.maybePop(context)),
          if (_carregando)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_hobbies.isEmpty)
            const Expanded(child: _EstadoSemHobbies())
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── label seção ───────────────────────────────
                    const Text(
                      'Selecione o hobby',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kGray,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── lista de hobbies (radio) ──────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _hobbies.length,
                        separatorBuilder: (_, i) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFF0EBE3),
                        ),
                        itemBuilder: (_, i) {
                          final h = _hobbies[i];
                          final sel = _hobbySelecionado?.id == h.id;
                          return _HobbyRadioTile(
                            hobby: h,
                            selecionado: sel,
                            unidadeAbrev: _abrevTipo(h.metaTipo),
                            onTap: () => setState(() {
                              _hobbySelecionado = h;
                              _inputController.clear();
                            }),
                          );
                        },
                      ),
                    ),

                    if (_hobbySelecionado != null) ...[
                      const SizedBox(height: 20),

                      // ── card de progresso ─────────────────────
                      _ProgressoCard(hobby: _hobbySelecionado!),

                      const SizedBox(height: 20),

                      // ── input ─────────────────────────────────
                      Text(
                        'Quanto você fez hoje? (${_hobbySelecionado!.metaTipo.toLowerCase()})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2B2B2B),
                                ),
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFBBB5AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EBF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _unidadeAbrev,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _kPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── botão salvar ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kOrange, _kPurple],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _kPurple.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _salvando ? null : _salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _salvando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _abrevTipo(String tipo) {
    switch (tipo) {
      case 'Minutos':
        return 'min';
      case 'Horas':
        return 'h';
      case 'Páginas':
        return 'pág';
      case 'Vezes':
        return 'x';
      default:
        return 'min';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile de hobby com radio button
// ─────────────────────────────────────────────────────────────────────────────

class _HobbyRadioTile extends StatelessWidget {
  final _HobbyInfo hobby;
  final bool selecionado;
  final String unidadeAbrev;
  final VoidCallback onTap;

  const _HobbyRadioTile({
    required this.hobby,
    required this.selecionado,
    required this.unidadeAbrev,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selecionado
              ? _kPurple.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selecionado ? _kPurple : const Color(0xFFCCC6C0),
                  width: selecionado ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // emoji + nome
            Text(hobby.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hobby.nome,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selecionado ? FontWeight.w700 : FontWeight.w500,
                  color: selecionado ? _kPurple : const Color(0xFF2B2B2B),
                ),
              ),
            ),
            // progresso
            Text(
              '${hobby.progressoHoje} / ${hobby.metaValor} $unidadeAbrev',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selecionado ? _kPurple : _kGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de progresso do hobby selecionado
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressoCard extends StatelessWidget {
  final _HobbyInfo hobby;
  const _ProgressoCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    final pct = hobby.metaValor > 0
        ? (hobby.progressoHoje / hobby.metaValor).clamp(0.0, 1.0)
        : 0.0;
    final abrev = _abrev(hobby.metaTipo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Progresso de "${hobby.nome}"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Meta: ${hobby.metaValor} $abrev  •  Atual: ${hobby.progressoHoje} $abrev',
            style: const TextStyle(fontSize: 12, color: _kGray),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0EBF6),
              valueColor: const AlwaysStoppedAnimation<Color>(_kPurple),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _abrev(String tipo) {
    switch (tipo) {
      case 'Minutos':
        return 'min';
      case 'Horas':
        return 'h';
      case 'Páginas':
        return 'pág';
      case 'Vezes':
        return 'x';
      default:
        return 'min';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header idêntico ao da home
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onVoltar;
  const _Header({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 0, 16, 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7C3AED), Color(0xFFC34CA3), Color(0xFFFF7A00)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 24),
                onPressed: onVoltar,
              ),
              const Expanded(
                child: Text(
                  'Registrar Progresso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _IconeCirculo(
                icon: Icons.notifications_none_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaNotificacoes()),
                ),
              ),
              const SizedBox(width: 10),
              _IconeCirculo(
                icon: Icons.person_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaPerfil()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(_WaveClipper _) => false;
}

class _IconeCirculo extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconeCirculo({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: _kBg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, color: _kGray, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modelo local
// ─────────────────────────────────────────────────────────────────────────────

class _HobbyInfo {
  final String id;
  final String nome;
  final String emoji;
  final String metaTipo;
  final int metaValor;
  final int progressoHoje;

  _HobbyInfo({
    required this.id,
    required this.nome,
    required this.emoji,
    required this.metaTipo,
    required this.metaValor,
    required this.progressoHoje,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vazio
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoSemHobbies extends StatelessWidget {
  const _EstadoSemHobbies();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded, size: 36, color: _kPurple),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhum hobby ainda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crie um hobby primeiro para registrar seu progresso.',
              style: TextStyle(fontSize: 13, color: _kGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_kOrange, _kPurple]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
