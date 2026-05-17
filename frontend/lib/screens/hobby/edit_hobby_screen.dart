import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../models/hobby.dart';
import '../../services/hobby_service.dart';
import '../../services/api_client.dart';
import '../../widgets/app_header.dart';
import '../../widgets/gradient_button.dart';

class EditHobbyScreen extends StatefulWidget {
  final Hobby hobby;

  const EditHobbyScreen({super.key, required this.hobby});

  @override
  State<EditHobbyScreen> createState() => _EditHobbyScreenState();
}

class _EditHobbyScreenState extends State<EditHobbyScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late final TextEditingController _metaValueController;
  late final TextEditingController _unitController;
  late List<int> _days;
  late int _reminderHour;
  late int _reminderMin;
  late bool _notification;
  bool _loading = false;
  String? _error;

  static const _dayLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  void initState() {
    super.initState();
    final h = widget.hobby;
    _nameController = TextEditingController(text: h.name);
    _emojiController = TextEditingController(text: h.emoji);
    _metaValueController = TextEditingController(text: h.metaValue.toString());
    _unitController = TextEditingController(text: h.unit);
    _days = List<int>.from(h.days);
    _reminderHour = h.reminderHour;
    _reminderMin = h.reminderMin;
    _notification = h.notification;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _metaValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final metaValue = int.tryParse(_metaValueController.text.trim());
    final unit = _unitController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'O nome é obrigatório.');
      return;
    }
    if (metaValue == null || metaValue <= 0) {
      setState(() => _error = 'Informe uma meta válida.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await HobbyService.update(widget.hobby.id, {
        'name': name,
        'emoji': _emojiController.text.trim(),
        'metaValue': metaValue,
        'unit': unit,
        'days': _days,
        'reminderHour': _reminderHour,
        'reminderMin': _reminderMin,
        'notification': _notification,
      });
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(
              showBack: true, showLogo: false, title: 'Editar Hobby'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            _label('Emoji'),
            const SizedBox(height: 8),
            _field(_emojiController, hint: '🎸'),
            const SizedBox(height: 16),
            _label('Nome do hobby'),
            const SizedBox(height: 8),
            _field(_nameController, hint: 'Ex: Violão'),
            const SizedBox(height: 16),
            _label('Meta diária'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _field(_metaValueController,
                      hint: '30', keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _field(_unitController, hint: 'minutos'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _label('Dias da semana'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final selected = _days.contains(i);
                return FilterChip(
                  label: Text(_dayLabels[i],
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary)),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _days.add(i);
                        _days.sort();
                      } else {
                        _days.remove(i);
                      }
                    });
                  },
                  selectedColor: AppColors.orange,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                );
              }),
            ),
            const SizedBox(height: 20),
            _label('Lembrete'),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: _notification,
                  activeThumbColor: AppColors.purple,
                  onChanged: (v) => setState(() => _notification = v),
                ),
                const SizedBox(width: 8),
                Text(_notification ? 'Ativado' : 'Desativado',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            if (_notification) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: _reminderHour, minute: _reminderMin),
                  );
                  if (picked != null) {
                    setState(() {
                      _reminderHour = picked.hour;
                      _reminderMin = picked.minute;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMin.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                  style: GoogleFonts.poppins(
                      color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            GradientButton(
              label: _loading ? 'Salvando...' : 'Salvar',
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
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w500));

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
        ),
      );
}
