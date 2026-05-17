import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../models/hobby.dart';
import '../../models/progresso.dart';
import '../../services/hobby_service.dart';
import '../../services/progresso_service.dart';
import '../../services/stats_service.dart';
import '../../services/auth_store.dart';
import '../../services/api_client.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/registrar_progresso_sheet.dart';
import '../hobby/edit_hobby_screen.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _showFilter = false;
  String _filterText = '';
  String _pendingFilterText = '';
  List<Hobby> _hobbies = [];
  Map<String, int> _progressoHoje = {};
  Stats? _stats;
  bool _loading = true;
  String _userName = '';
  int _navIndex = 0;

  static const _cardColors = [
    AppColors.greenLight,
    AppColors.peach,
    AppColors.lavender,
    Color(0xFFE3F2FD),
    Color(0xFFFCE4EC),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final name = await AuthStore.getName();
      final results = await Future.wait([
        HobbyService.list(),
        StatsService.get(),
      ]);
      final hobbies = results[0] as List<Hobby>;
      final stats = results[1] as Stats;

      final hoje = DateTime.now();
      final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);

      final progressoLists = await Future.wait(
        hobbies.map((h) =>
            ProgressoService.list(h.id).catchError((_) => <Progresso>[])),
      );

      final progressoHoje = <String, int>{};
      for (int i = 0; i < hobbies.length; i++) {
        progressoHoje[hobbies[i].id] = progressoLists[i]
            .where((p) => DateTime.parse(p.date).isAfter(inicioDia))
            .fold(0, (sum, p) => sum + p.valor);
      }

      NotificationService.scheduleForHobbies(hobbies);

      if (mounted) {
        setState(() {
          _userName = name ?? '';
          _hobbies = hobbies;
          _progressoHoje = progressoHoje;
          _stats = stats;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pauseHobby(String id) async {
    final hobby = _hobbies.firstWhere((h) => h.id == id);
    try {
      final updated = await HobbyService.update(id, {'paused': !hobby.paused});
      if (mounted) {
        setState(() {
          final idx = _hobbies.indexWhere((h) => h.id == id);
          if (idx != -1) _hobbies[idx] = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(apiError(e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _deleteHobby(String id) async {
    try {
      await HobbyService.delete(id);
      setState(() => _hobbies.removeWhere((h) => h.id == id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(apiError(e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void addHobby(Hobby hobby) {
    setState(() => _hobbies.insert(0, hobby));
  }

  Future<void> _editHobby(String id) async {
    final hobby = _hobbies.firstWhere((h) => h.id == id);
    final updated = await Navigator.push<Hobby>(
      context,
      MaterialPageRoute(builder: (_) => EditHobbyScreen(hobby: hobby)),
    );
    if (updated != null && mounted) {
      setState(() {
        final index = _hobbies.indexWhere((h) => h.id == id);
        if (index != -1) _hobbies[index] = updated;
      });
      NotificationService.scheduleForHobbies(_hobbies);
    }
  }

  _HobbyData _toView(Hobby h, int index) {
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    final daysStr = h.days.isEmpty
        ? 'Todo dia'
        : h.days.map((d) => dayNames[d.clamp(0, 6)]).join(', ');
    final schedule = '$daysStr • ${h.metaValue} ${h.unit}';
    final next = (h.reminderHour == 0 && h.reminderMin == 0)
        ? 'Sem lembrete'
        : 'Lembrete: ${h.reminderHour.toString().padLeft(2, '0')}:${h.reminderMin.toString().padLeft(2, '0')}';
    return _HobbyData(
      id: h.id,
      emoji: h.emoji,
      name: h.name,
      schedule: schedule,
      current: _progressoHoje[h.id] ?? 0,
      total: h.metaValue,
      streak: null,
      nextLabel: next,
      bgColor: _cardColors[index % _cardColors.length],
      progressColor: AppColors.purple,
      done: false,
      paused: h.paused,
    );
  }

  List<_HobbyData> get _viewHobbies {
    final all =
        _hobbies.asMap().entries.map((e) => _toView(e.value, e.key)).toList();
    if (_filterText.isEmpty) return all;
    return all
        .where((h) => h.name.toLowerCase().contains(_filterText.toLowerCase()))
        .toList();
  }

  Future<void> _openRegisterSheet() async {
    final registered = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RegistrarProgressoSheet(hobbies: _hobbies),
    );
    if (registered == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showFilter) setState(() => _showFilter = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        extendBody: true,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppHeader(showLogo: false, showActions: true),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/hobbytrack_transparent.png',
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userName.isEmpty
                                  ? 'Olá!'
                                  : 'Olá, ${_userName.split(' ').first}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Que tal registrar um momento do seu hobby hoje?',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GradientButton(
                              label: '+ Registrar progresso',
                              onPressed: _openRegisterSheet,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text('Hobbies ativos',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _pendingFilterText = _filterText;
                                    _showFilter = !_showFilter;
                                  }),
                                  child: Icon(
                                    Icons.filter_list,
                                    color: _showFilter
                                        ? AppColors.purple
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      _loading
                          ? const SizedBox(
                              height: 215,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _HobbiesCarousel(
                              hobbies: _viewHobbies,
                              onDeleteHobby: _deleteHobby,
                              onEditHobby: _editHobby,
                              onPauseHobby: _pauseHobby,
                            ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EvolucaoCard(
                              hobbyCount:
                                  _hobbies.where((h) => !h.paused).length,
                              sequencia: _stats?.sequenciaAtual ?? 0,
                              evolucaoPercent: _stats?.evolucaoPercent ?? 0,
                            ),
                            const SizedBox(height: 16),
                            _AtividadeEmRiscoCard(
                              onRegistrar: _openRegisterSheet,
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showFilter)
              Positioned(
                top: 250,
                right: 20,
                child: _FilterDropdown(
                  initial: _pendingFilterText,
                  onApply: (text) => setState(() {
                    _filterText = text;
                    _showFilter = false;
                  }),
                  onReset: () => setState(() {
                    _filterText = '';
                    _pendingFilterText = '';
                  }),
                ),
              ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _navIndex,
          onTabSelected: (i) => setState(() => _navIndex = i),
          onCenterPressed: () {},
        ),
      ),
    );
  }
}

class _HobbiesCarousel extends StatelessWidget {
  final List<_HobbyData> hobbies;
  final ValueChanged<String> onDeleteHobby;
  final ValueChanged<String> onEditHobby;
  final ValueChanged<String> onPauseHobby;

  const _HobbiesCarousel({
    required this.hobbies,
    required this.onDeleteHobby,
    required this.onEditHobby,
    required this.onPauseHobby,
  });

  @override
  Widget build(BuildContext context) {
    if (hobbies.isEmpty) {
      return SizedBox(
        height: 215,
        child: Center(
          child: Text(
            'Nenhum hobby encontrado',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 215,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: hobbies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _HobbyCard(
          data: hobbies[i],
          onDelete: () => onDeleteHobby(hobbies[i].id),
          onEdit: () => onEditHobby(hobbies[i].id),
          onPause: () => onPauseHobby(hobbies[i].id),
        ),
      ),
    );
  }
}

class _HobbyData {
  final String id;
  final String emoji;
  final String name;
  final String schedule;
  final int current;
  final int total;
  final int? streak;
  final String nextLabel;
  final Color bgColor;
  final Color progressColor;
  final bool done;
  final bool paused;

  const _HobbyData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.schedule,
    required this.current,
    required this.total,
    required this.streak,
    required this.nextLabel,
    required this.bgColor,
    required this.progressColor,
    required this.done,
    required this.paused,
  });
}

class _HobbyCard extends StatefulWidget {
  final _HobbyData data;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPause;

  const _HobbyCard(
      {required this.data,
      required this.onDelete,
      required this.onEdit,
      required this.onPause});

  @override
  State<_HobbyCard> createState() => _HobbyCardState();
}

class _HobbyCardState extends State<_HobbyCard> {
  late bool _done;

  @override
  void initState() {
    super.initState();
    _done = widget.data.done;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: widget.data.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(widget.data.emoji,
                        style: const TextStyle(fontSize: 20))),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showOptions(context),
                child: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.data.name,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          Text(widget.data.schedule,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: widget.data.total > 0
                          ? widget.data.current / widget.data.total
                          : 0,
                      strokeWidth: 5,
                      backgroundColor: Colors.white,
                      valueColor:
                          AlwaysStoppedAnimation(widget.data.progressColor),
                    ),
                    Center(
                      child: Text(
                        '${widget.data.current}\n/${widget.data.total}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (widget.data.streak != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    Text('sequência',
                        style: GoogleFonts.poppins(
                            fontSize: 9, color: AppColors.textSecondary)),
                    Text('${widget.data.streak} dias',
                        style: GoogleFonts.poppins(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.data.nextLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _done = !_done),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _done ? AppColors.purple : AppColors.textSecondary,
                      width: 2,
                    ),
                    color: _done ? AppColors.purple : Colors.transparent,
                  ),
                  child: _done
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HobbyOptionsSheet(
          hobbyName: widget.data.name,
          paused: widget.data.paused,
          onDelete: widget.onDelete,
          onEdit: widget.onEdit,
          onPause: widget.onPause),
    );
  }
}

class _HobbyOptionsSheet extends StatelessWidget {
  final String hobbyName;
  final bool paused;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPause;

  const _HobbyOptionsSheet({
    required this.hobbyName,
    required this.paused,
    required this.onDelete,
    required this.onEdit,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.purple),
            title: Text('Editar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('Excluir',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, hobbyName);
            },
          ),
          ListTile(
            leading: Icon(
              paused ? Icons.play_arrow_outlined : Icons.pause_outlined,
              color: AppColors.textSecondary,
            ),
            title: Text(paused ? 'Retomar' : 'Pausar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              onPause();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(hobbyName: name, onConfirm: onDelete),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final String hobbyName;
  final VoidCallback onConfirm;

  const _DeleteDialog({required this.hobbyName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Confirmar exclusão',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Você tem certeza que deseja excluir\no hobby "$hobbyName"?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: AppColors.textSecondary),
                    ),
                    child: Text('Cancelar',
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Excluir',
                        style: GoogleFonts.poppins(color: Colors.white)),
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

class _EvolucaoCard extends StatelessWidget {
  final int hobbyCount;
  final int sequencia;
  final int evolucaoPercent;

  const _EvolucaoCard({
    required this.hobbyCount,
    required this.sequencia,
    required this.evolucaoPercent,
  });

  @override
  Widget build(BuildContext context) {
    final evolucaoStr = evolucaoPercent > 0
        ? '+$evolucaoPercent%'
        : evolucaoPercent < 0
            ? '$evolucaoPercent%'
            : '—';
    final evolucaoColor = evolucaoPercent > 0
        ? AppColors.green
        : evolucaoPercent < 0
            ? AppColors.error
            : AppColors.green;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sua evolução',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: const [
                      TextSpan(text: 'Você manteve a '),
                      TextSpan(
                          text: 'constância',
                          style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600)),
                      TextSpan(text: ' esta semana! 🔥'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                          child: _StatItem(
                              value: '$hobbyCount',
                              label: 'hobbies ativos',
                              valueColor: AppColors.purple)),
                      const VerticalDivider(
                          color: Color(0xFFE5DDD0), thickness: 1, width: 1),
                      Expanded(
                          child: _StatItem(
                              value: sequencia > 0 ? '$sequencia' : '—',
                              label: 'Dias de constância',
                              valueColor: AppColors.orange)),
                      const VerticalDivider(
                          color: Color(0xFFE5DDD0), thickness: 1, width: 1),
                      Expanded(
                        child: _StatItem(
                          value: evolucaoStr,
                          label: 'evolução da semana',
                          valueColor: evolucaoColor,
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                )),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary, height: 1.2)),
        ],
      ),
    );
  }
}

class _AtividadeEmRiscoCard extends StatelessWidget {
  final VoidCallback onRegistrar;
  const _AtividadeEmRiscoCard({required this.onRegistrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE5CC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0845A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 22),
                    const SizedBox(width: 8),
                    Text('Atividade em risco',
                        style: GoogleFonts.poppins(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Registre progresso nos seus hobbies\npara manter sua constância.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onRegistrar,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text('Retomar agora',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Center(
                      child: Text('Pausar',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13)),
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

class _FilterDropdown extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onApply;
  final VoidCallback onReset;

  const _FilterDropdown({
    required this.initial,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtro por nome',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              controller: _controller,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.purple),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onReset();
              },
              child: Row(
                children: [
                  Icon(Icons.apps,
                      size: 16,
                      color: _controller.text.isEmpty
                          ? AppColors.purple
                          : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Todos',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _controller.text.isEmpty
                            ? AppColors.purple
                            : AppColors.textSecondary,
                        fontWeight: _controller.text.isEmpty
                            ? FontWeight.w600
                            : FontWeight.normal,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: GestureDetector(
                onTap: () => widget.onApply(_controller.text),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text('Aplicar',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
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
