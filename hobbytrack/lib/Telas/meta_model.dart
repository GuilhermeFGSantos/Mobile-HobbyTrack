import 'package:flutter/material.dart';

enum TipoMeta { quantitativa, qualitativa }

enum StatusMeta { emAndamento, concluida, pausada }

enum FiltroMeta { todas, emAndamento, concluidas }

// Como o prazo de uma meta é representado:
//  - emDias / emSemanas / emMeses são relativos à data de criação.
//  - dataEspecifica armazena uma data absoluta escolhida pelo usuário.
enum TipoPrazo { emDias, emSemanas, emMeses, dataEspecifica }

// Frequência da meta (substitui Prazo no design novo).
//  - porPeriodo: "X vezes por dia/semana/mês"
//  - diasSemana: dias específicos da semana (0=Dom ... 6=Sáb)
enum TipoFrequencia { porPeriodo, diasSemana }

enum UnidadePeriodo { dia, semana, mes }

// Estado de cada "check" de uma meta qualitativa.
enum EstadoCheck { vazio, concluido, falhado }

class Frequencia {
  final TipoFrequencia tipo;
  final int vezes;
  final UnidadePeriodo unidade;
  final Set<int> dias;

  const Frequencia._({
    required this.tipo,
    this.vezes = 0,
    this.unidade = UnidadePeriodo.semana,
    this.dias = const {},
  });

  factory Frequencia.porPeriodo({
    required int vezes,
    required UnidadePeriodo unidade,
  }) =>
      Frequencia._(
        tipo: TipoFrequencia.porPeriodo,
        vezes: vezes,
        unidade: unidade,
      );

  factory Frequencia.diasSemana(Set<int> dias) => Frequencia._(
        tipo: TipoFrequencia.diasSemana,
        dias: Set<int>.from(dias),
      );

  bool get valida => tipo == TipoFrequencia.porPeriodo
      ? vezes > 0
      : dias.isNotEmpty;

  // Tamanho default da lista de checks pra uma meta qualitativa com esta frequência.
  int get totalOcorrencias =>
      tipo == TipoFrequencia.porPeriodo ? vezes : dias.length;

  String get descricao {
    if (tipo == TipoFrequencia.porPeriodo) {
      final unidadeStr = switch (unidade) {
        UnidadePeriodo.dia => 'dia',
        UnidadePeriodo.semana => 'semana',
        UnidadePeriodo.mes => 'mês',
      };
      final vezesStr = vezes == 1 ? '1 vez' : '$vezes vezes';
      return '$vezesStr por $unidadeStr';
    }
    if (dias.isEmpty) return 'nenhum dia';
    const siglas = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final ordenados = dias.toList()..sort();
    return ordenados.map((d) => siglas[d]).join(', ');
  }
}

class Prazo {
  TipoPrazo tipo;
  int quantidade; // 0 quando tipo == dataEspecifica
  DateTime? dataEspecifica;
  DateTime dataCriacao;

  Prazo.relativo({
    required this.tipo,
    required this.quantidade,
    DateTime? dataCriacao,
  })  : dataEspecifica = null,
        dataCriacao = dataCriacao ?? DateTime.now();

  Prazo.absoluta({
    required DateTime data,
    DateTime? dataCriacao,
  })  : tipo = TipoPrazo.dataEspecifica,
        quantidade = 0,
        dataEspecifica = data,
        dataCriacao = dataCriacao ?? DateTime.now();

  bool get valido {
    if (tipo == TipoPrazo.dataEspecifica) return dataEspecifica != null;
    return quantidade > 0;
  }

  DateTime get dataAlvo {
    switch (tipo) {
      case TipoPrazo.dataEspecifica:
        return dataEspecifica!;
      case TipoPrazo.emDias:
        return dataCriacao.add(Duration(days: quantidade));
      case TipoPrazo.emSemanas:
        return dataCriacao.add(Duration(days: quantidade * 7));
      case TipoPrazo.emMeses:
        return DateTime(
          dataCriacao.year,
          dataCriacao.month + quantidade,
          dataCriacao.day,
        );
    }
  }

  String get descricao {
    return switch (tipo) {
      TipoPrazo.emDias =>
        quantidade == 1 ? 'em 1 dia' : 'em $quantidade dias',
      TipoPrazo.emSemanas =>
        quantidade == 1 ? 'em 1 semana' : 'em $quantidade semanas',
      TipoPrazo.emMeses =>
        quantidade == 1 ? 'em 1 mês' : 'em $quantidade meses',
      TipoPrazo.dataEspecifica => 'até ${_formatarData(dataEspecifica!)}',
    };
  }

  static String _formatarData(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

class Milestone {
  final String id;
  String texto;

  Milestone({required this.id, this.texto = ''});

  factory Milestone.novo() =>
      Milestone(id: DateTime.now().microsecondsSinceEpoch.toString());
}

// Hobby é a entidade-pai: representa a "área" de prática do usuário
// (Leitura, Violão, Jogos...). Uma Meta é sempre derivada de um Hobby.
// O hobby fornece identidade visual (emoji + cor) — a Meta apenas herda.
class Hobby {
  final String id;
  final String nome;
  final String emoji;
  final Color cor;

  const Hobby({
    required this.id,
    required this.nome,
    required this.emoji,
    required this.cor,
  });

  @override
  bool operator ==(Object other) => other is Hobby && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// Mock de hobbies enquanto não existe a tela/back-end de hobbies.
const List<Hobby> hobbiesMock = [
  Hobby(id: 'leitura', nome: 'Leitura', emoji: '📖', cor: Color(0xFFFF9B3F)),
  Hobby(id: 'violao', nome: 'Violão', emoji: '🎸', cor: Color(0xFFEF4444)),
  Hobby(id: 'violino', nome: 'Violino', emoji: '🎻', cor: Color(0xFFFF7A00)),
  Hobby(id: 'yoga', nome: 'Yoga', emoji: '🧘', cor: Color(0xFFB992F4)),
  Hobby(id: 'jogos', nome: 'Jogos', emoji: '🎮', cor: Color(0xFF3B82F6)),
  Hobby(id: 'corrida', nome: 'Corrida', emoji: '🏃', cor: Color(0xFF22C55E)),
  Hobby(id: 'desenho', nome: 'Desenho', emoji: '✏️', cor: Color(0xFF8738F2)),
];

class Meta {
  String titulo;
  Hobby hobby;
  TipoMeta tipo;
  Frequencia frequencia;
  int valorAlvo;              // só usado por quantitativa
  int progresso;              // só usado por quantitativa
  StatusMeta status;
  List<EstadoCheck> checks;   // só usado por qualitativa
  List<Milestone> milestones; // legado — mantido por compat

  Meta({
    required this.titulo,
    required this.hobby,
    required this.tipo,
    required this.frequencia,
    this.valorAlvo = 0,
    this.progresso = 0,
    this.status = StatusMeta.emAndamento,
    List<EstadoCheck>? checks,
    List<Milestone>? milestones,
  })  : checks = checks ?? [],
        milestones = milestones ?? [];

  // Identidade visual derivada do hobby.
  String get emoji => hobby.emoji;
  Color get cor => hobby.cor;

  String get subtitulo => '${hobby.nome} · ${frequencia.descricao}';

  double get percentual {
    if (valorAlvo <= 0) return 0;
    final p = progresso / valorAlvo;
    return p > 1 ? 1 : p;
  }

  // Métrica usada pra eleger a meta "mais frequente do mês":
  // como ainda não temos timestamp por progresso, usamos o total atual
  // como aproximação. Pra quantitativa = progresso, pra qualitativa = nº checks concluídos.
  int get pontuacaoProgresso => tipo == TipoMeta.quantitativa
      ? progresso
      : checks.where((c) => c == EstadoCheck.concluido).length;
}
