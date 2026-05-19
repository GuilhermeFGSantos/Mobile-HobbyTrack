import 'package:flutter/material.dart';

enum TipoMeta { quantitativa, qualitativa }

enum StatusMeta { emAndamento, concluida, pausada }

enum FiltroMeta { todas, emAndamento, concluidas }

enum TipoFrequencia { porPeriodo, diasSemana }

enum UnidadePeriodo { dia, semana, mes }

// Estado de cada "ocorrência" de uma meta qualitativa.
// Ciclo do toque: vazio -> concluido -> falhado -> vazio.
enum EstadoCheck { vazio, concluido, falhado }

extension EstadoCheckProximo on EstadoCheck {
  EstadoCheck get proximo => switch (this) {
        EstadoCheck.vazio => EstadoCheck.concluido,
        EstadoCheck.concluido => EstadoCheck.falhado,
        EstadoCheck.falhado => EstadoCheck.vazio,
      };
}

class Frequencia {
  final TipoFrequencia tipo;
  final int vezes;
  final UnidadePeriodo unidade;
  final Set<int> dias; // 0 = Dom ... 6 = Sáb

  Frequencia.porPeriodo({required this.vezes, required this.unidade})
      : tipo = TipoFrequencia.porPeriodo,
        dias = const {};

  Frequencia.diasSemana(Set<int> dias)
      : tipo = TipoFrequencia.diasSemana,
        vezes = 0,
        unidade = UnidadePeriodo.semana,
        dias = Set<int>.unmodifiable(dias);

  bool get valida => totalOcorrencias > 0;

  int get totalOcorrencias {
    if (tipo == TipoFrequencia.diasSemana) return dias.length;
    return vezes;
  }

  String get descricao {
    if (tipo == TipoFrequencia.diasSemana) {
      const nomes = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final ordenados = dias.toList()..sort();
      return ordenados.map((d) => nomes[d]).join(', ');
    }

    if (unidade == UnidadePeriodo.dia && vezes == 1) return 'Diariamente';
    if (unidade == UnidadePeriodo.semana && vezes == 1) return 'Semanalmente';
    if (unidade == UnidadePeriodo.mes && vezes == 1) return 'Mensalmente';

    final sufixo = switch (unidade) {
      UnidadePeriodo.dia => 'por dia',
      UnidadePeriodo.semana => 'por semana',
      UnidadePeriodo.mes => 'por mês',
    };
    return '${vezes}x $sufixo';
  }
}

class Meta {
  String nome;
  String emoji;
  Color cor;
  TipoMeta tipo;
  Frequencia frequencia;
  int valorAlvo;
  int progresso;
  StatusMeta status;
  List<EstadoCheck> checks;

  Meta({
    required this.nome,
    required this.emoji,
    required this.cor,
    required this.tipo,
    required this.frequencia,
    this.valorAlvo = 0,
    this.progresso = 0,
    this.status = StatusMeta.emAndamento,
    List<EstadoCheck>? checks,
  }) : checks = checks ?? const [];

  String get descricao {
    if (tipo == TipoMeta.quantitativa) {
      return 'Meta: $valorAlvo, ${frequencia.descricao.toLowerCase()}';
    }
    return 'Meta: ${frequencia.descricao}';
  }

  double get percentual {
    if (valorAlvo <= 0) return 0;
    final p = progresso / valorAlvo;
    return p > 1 ? 1 : p;
  }
}

const List<Color> coresDisponiveis = [
  Color(0xFF8738F2),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFFF7A00),
  Color(0xFFEF4444),
];
