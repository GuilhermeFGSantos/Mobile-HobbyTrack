import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hobbytrack/Telas/tela_categorias.dart';
import 'package:hobbytrack/Telas/tela_criar_hobby.dart';
import 'package:hobbytrack/Telas/tela_insights.dart';
import 'package:hobbytrack/Telas/tela_metas.dart';
import 'package:hobbytrack/Telas/tela_notificacoes.dart';
import 'package:hobbytrack/Telas/tela_perfil.dart';
import 'auth_widgets.dart';

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
    _OpcaoFiltro(
      'Esportes',
      Icons.sports_basketball_rounded,
      Color(0xFF64B5F6),
    ),
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
              final o = lista[i];
              final ativo = o.nome == selecionado;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => selecionado = o.nome),
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

class _OpcaoFiltro {
  final String nome;
  final IconData icone;
  final Color cor;
  const _OpcaoFiltro(this.nome, this.icone, this.cor);
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
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
                    color: const Color(0xFFFFF8F1),
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
                            const _HeaderGradiente(),
                            Padding(
                              padding: EdgeInsets.only(left: 0, right: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Olá, Ana',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2B2B2B),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
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
                            const _SecaoHobbiesAtivos(),
                            const SizedBox(height: 22),
                            const _CardEvolucao(),
                            const SizedBox(height: 16),
                            const _CardAtividadeRisco(),
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
  }
}

class _HeaderGradiente extends StatelessWidget {
  const _HeaderGradiente();

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
                _IconeCirculo(
                  icon: Icons.person_outline_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaPerfil()),
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
  const _IconeCirculo({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: texto, size: 20),
      ),
    );
  }
}

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

class _SecaoHobbiesAtivos extends StatelessWidget {
  const _SecaoHobbiesAtivos();

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
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                ),
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
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _CardHobby(
                icone: Icons.menu_book_rounded,
                corIcone: Color(0xFF8FC79A),
                nome: 'Leitura',
                info: 'Todo dia • 20 pág',
                progresso: 12,
                meta: 20,
                streak: '7 dias',
                proximo: 'hoje às 20:00',
              ),
              SizedBox(width: 12),
              _CardHobby(
                icone: Icons.music_note_rounded,
                corIcone: Color(0xFFF1A86A),
                nome: 'Violino',
                info: 'Quarta e Sexta • 1h',
                progresso: 8,
                meta: 8,
                streak: null,
                proximo: 'Quarta feira',
              ),
              SizedBox(width: 12),
              _CardHobby(
                icone: Icons.brush_rounded,
                corIcone: Color(0xFFB39DDB),
                nome: 'Pintura',
                info: 'Fim de semana',
                progresso: 3,
                meta: 5,
                streak: null,
                proximo: 'Sábado',
              ),
            ],
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

class _CardHobby extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final String nome;
  final String info;
  final int progresso;
  final int meta;
  final String? streak;
  final String proximo;

  const _CardHobby({
    required this.icone,
    required this.corIcone,
    required this.nome,
    required this.info,
    required this.progresso,
    required this.meta,
    required this.streak,
    required this.proximo,
  });

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
              const Icon(Icons.more_vert, size: 18, color: texto),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nome,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
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
                          style: const TextStyle(
                            fontSize: 9,
                            color: texto,
                            height: 1,
                          ),
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
                      const Text(
                        'sequência',
                        style: TextStyle(fontSize: 10, color: texto),
                      ),
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

class _CardEvolucao extends StatelessWidget {
  const _CardEvolucao();

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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2B),
            ),
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
                const Center(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 12, color: texto),
                      children: [
                        TextSpan(text: 'Você manteve a '),
                        TextSpan(
                          text: 'constância',
                          style: TextStyle(
                            color: roxo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' esta semana! 🔥'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(
                      child: _StatEvolucao(
                        valor: '4',
                        rotulo: 'hobbies ativos',
                        cor: Color(0xFF2B2B2B),
                      ),
                    ),
                    Expanded(
                      child: _StatEvolucao(
                        valor: '8',
                        rotulo: 'Dias de constância',
                        cor: Color(0xFF2B2B2B),
                      ),
                    ),
                    Expanded(
                      child: _StatEvolucao(
                        valor: '+12%',
                        rotulo: 'evolução da semana',
                        cor: Color(0xFF22A36B),
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
  const _StatEvolucao({
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cor,
          ),
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

class _CardAtividadeRisco extends StatelessWidget {
  const _CardAtividadeRisco();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
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
                    children: const [
                      Text(
                        'Atividade em risco',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: laranja,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Você está há 9 dias sem atualizar violino.\nRetome agora para manter sua constância.',
                        style: TextStyle(fontSize: 11, color: texto),
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
                const SizedBox(width: 10),
                Expanded(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
              Expanded(child: SizedBox()),
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
