import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/hobby.dart';
import '../services/progresso_service.dart';
import '../services/api_client.dart';

class RegistrarProgressoSheet extends StatefulWidget {
  final List<Hobby> hobbies;

  const RegistrarProgressoSheet({super.key, required this.hobbies});

  @override
  State<RegistrarProgressoSheet> createState() =>
      _RegistrarProgressoSheetState();
}

class _RegistrarProgressoSheetState extends State<RegistrarProgressoSheet> {
  Hobby? _selectedHobby;
  final _valorController = TextEditingController();
  bool _loading = false;
  String? _error;

  List<Hobby> get _activeHobbies =>
      widget.hobbies.where((h) => !h.paused).toList();

  @override
  void initState() {
    super.initState();
    if (_activeHobbies.isNotEmpty) _selectedHobby = _activeHobbies.first;
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final hobby = _selectedHobby;
    final valor = int.tryParse(_valorController.text.trim());

    if (hobby == null) {
      setState(() => _error = 'Selecione um hobby.');
      return;
    }
    if (valor == null || valor <= 0) {
      setState(() => _error = 'Informe um valor válido.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ProgressoService.create(hobby.id, {'valor': valor});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Registrar Progresso',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('Hobby',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _activeHobbies.isEmpty
              ? Text('Nenhum hobby ativo.',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary))
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: DropdownButton<Hobby>(
                    value: _selectedHobby,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black87),
                    items: _activeHobbies
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text('${h.emoji} ${h.name}'),
                            ))
                        .toList(),
                    onChanged: (h) => setState(() => _selectedHobby = h),
                  ),
                ),
          const SizedBox(height: 16),
          Text('Quantidade (${_selectedHobby?.unit ?? 'unidade'})',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
                hint: 'Ex: 30'),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Registrar',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
