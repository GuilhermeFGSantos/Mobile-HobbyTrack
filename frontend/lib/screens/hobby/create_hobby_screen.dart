import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../services/hobby_service.dart';
import '../../services/api_client.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/gradient_button.dart';

class CreateHobbyScreen extends StatefulWidget {
  const CreateHobbyScreen({super.key});

  @override
  State<CreateHobbyScreen> createState() => _CreateHobbyScreenState();
}

class _CreateHobbyScreenState extends State<CreateHobbyScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late final TextEditingController _metaValueController;
  late List<int> _days;
  late int _reminderHour;
  late int _reminderMin;
  late bool _notification;
  late bool _repeat;
  late String _selectedUnit;
  bool _loading = false;
  String? _error;

  static const _dayLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  static const _unitOptions = ['nome', 'horas', 'vezes', 'minutos', 'paginas'];
  static const _emojiOptions = [
    '🎸',
    '🎯',
    '📚',
    '🏃‍♂️',
    '🧘‍♂️',
    '🎨',
    '🎧',
    '🎮',
    '✍️',
    '🥗',
    '💧',
    '🚴‍♂️',
    '🏋️‍♂️',
    '🎹',
    '📷',
    '🧩',
    '🌱',
    '🗣️',
    '🏊‍♂️',
    '🧠',
    '📝',
    '🥁',
    '🍳',
    '🧵',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emojiController = TextEditingController();
    _metaValueController = TextEditingController();
    _days = List<int>.generate(7, (i) => i);
    _reminderHour = 0;
    _reminderMin = 0;
    _notification = true;
    _repeat = true;
    _selectedUnit = _unitOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _metaValueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final emoji = _emojiController.text.trim();
    final metaValue = int.tryParse(_metaValueController.text.trim());
    final unit = _selectedUnit.trim();

    if (emoji.isEmpty) {
      setState(() => _error = 'O emoji é obrigatório.');
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = 'O nome é obrigatório.');
      return;
    }
    if (metaValue == null || metaValue <= 0) {
      setState(() => _error = 'Informe uma meta válida.');
      return;
    }
    if (unit.isEmpty) {
      setState(() => _error = 'A unidade é obrigatória.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final created = await HobbyService.create({
        'name': name,
        'emoji': emoji,
        'metaValue': metaValue,
        'unit': unit,
        'repeat': _repeat,
        'days': _repeat ? _days : <int>[],
        'notification': _notification,
        'reminderHour': _notification ? _reminderHour : 0,
        'reminderMin': _notification ? _reminderMin : 0,
      });
      if (mounted) Navigator.pop(context, created);
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: Column(
        children: [
          const AppHeader(showBack: false, showLogo: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF7D3BED), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Criar Hobby',
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _label('Nome'),
                  const SizedBox(height: 8),
                  _field(_nameController, hint: 'Nome do hobby'),
                  const SizedBox(height: 16),
                  _label('Emoji'),
                  const SizedBox(height: 8),
                  _emojiField(),
                  const SizedBox(height: 16),
                  _metaCard(context),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!,
                        style: GoogleFonts.poppins(
                            color: AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 32),
                  GradientButton(
                    label: _loading ? 'Criando...' : 'Criar',
                    onPressed: _loading ? () {} : _save,
                    height: 52,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTabSelected: (_) {},
        onCenterPressed: () {},
      ),
    );
  }

  Widget _metaCard(BuildContext context) {
    final timeEnabled = _notification;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meta diária',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Qual é a sua meta para este hobby?',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _label('Meta'),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 64,
                child: _field(_metaValueController,
                    hint: '30', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_selectedUnit),
                  initialValue: _selectedUnit,
                  items: _unitOptions
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedUnit = v);
                  },
                  decoration: _dropdownDecoration(),
                  dropdownColor: AppColors.cardCream,
                  icon: const Icon(Icons.expand_more,
                      color: AppColors.textSecondary),
                  isDense: true,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Repetir',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Switch(
                value: _repeat,
                activeThumbColor: AppColors.purple,
                onChanged: (v) => setState(() => _repeat = v),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final selected = _days.contains(i);
              return FilterChip(
                label: Text(_dayLabels[i],
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            selected ? Colors.white : AppColors.textPrimary)),
                selected: selected,
                onSelected: _repeat
                    ? (v) {
                        setState(() {
                          if (v) {
                            _days.add(i);
                            _days.sort();
                          } else {
                            _days.remove(i);
                          }
                        });
                      }
                    : null,
                selectedColor: AppColors.orange,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                showCheckmark: false,
              );
            }),
          ),
          const SizedBox(height: 12),
          _label('Lembrete'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: timeEnabled ? () => _openWheelTimePicker(context) : null,
            child: Opacity(
              opacity: timeEnabled ? 1 : 0.5,
              child: Row(
                children: [
                  _timeBox(_reminderHour),
                  const SizedBox(width: 8),
                  Text(':', style: GoogleFonts.poppins(fontSize: 16)),
                  const SizedBox(width: 8),
                  _timeBox(_reminderMin),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Mostrar notificação',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Switch(
                value: _notification,
                activeThumbColor: AppColors.purple,
                onChanged: (v) => setState(() => _notification = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(int value) {
    return Container(
      width: 44,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Text(
        value.toString().padLeft(2, '0'),
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  Widget _emojiField() {
    return GestureDetector(
      onTap: _openEmojiPicker,
      child: AbsorbPointer(
        child: TextField(
          controller: _emojiController,
          style: GoogleFonts.poppins(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Toque para escolher',
            hintStyle: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.purple),
            ),
            suffixIcon: const Icon(Icons.emoji_emotions_outlined,
                color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Future<void> _openEmojiPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Escolha um emoji',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _emojiOptions.length,
                  itemBuilder: (_, index) {
                    final emoji = _emojiOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _emojiController.text = emoji);
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: Center(
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openWheelTimePicker(BuildContext context) async {
    int tempHour = _reminderHour;
    int tempMin = _reminderMin;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (sheetContext) {
        final hourController =
            FixedExtentScrollController(initialItem: tempHour);
        final minController = FixedExtentScrollController(initialItem: tempMin);
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      child: CupertinoPicker(
                        itemExtent: 36,
                        scrollController: hourController,
                        onSelectedItemChanged: (value) => tempHour = value,
                        children: List.generate(
                          24,
                          (i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(':',
                        style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 90,
                      child: CupertinoPicker(
                        itemExtent: 36,
                        scrollController: minController,
                        onSelectedItemChanged: (value) => tempMin = value,
                        children: List.generate(
                          60,
                          (i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text('Cancelar',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _reminderHour = tempHour;
                            _reminderMin = tempMin;
                          });
                        }
                        Navigator.pop(sheetContext);
                      },
                      child: Text('OK',
                          style: GoogleFonts.poppins(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500));

  Widget _field(
    TextEditingController controller, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.purple),
          ),
        ),
      );

  InputDecoration _dropdownDecoration() => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      );
}
