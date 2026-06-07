import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TipoMeta { quantitativa, qualitativa }

enum StatusMeta { emAndamento, concluida, pausada }

enum FiltroMeta { todas, emAndamento, concluidas }

// Frequência da meta.
//  - porPeriodo: "X vezes por dia/semana/mês"
//  - diasSemana: dias específicos da semana (0=Dom ... 6=Sáb)
enum TipoFrequencia { porPeriodo, diasSemana }

enum UnidadePeriodo { dia, semana, mes }

// Estado de cada "check" de uma meta qualitativa.
enum EstadoCheck { vazio, concluido, falhado }

// ---------------------------------------------------------------------------
// Helpers de (de)serialização com o Firestore
// ---------------------------------------------------------------------------

// No Firestore guardamos enums como texto (ex: 'emAndamento'). `.name` faz
// objeto -> texto; esta função faz texto -> objeto na leitura, caindo em um
// valor padrão se o texto vier nulo/desconhecido (banco nunca é 100% confiável).
T _enumFromName<T extends Enum>(List<T> valores, String? nome, T padrao) {
  for (final v in valores) {
    if (v.name == nome) return v;
  }
  return padrao;
}

// Mapeia o `icone_nome` salvo no Firestore (mesmo esquema dos hobbies) para um
// IconData do Flutter. Espelha o mapeamento usado na TelaHome, mantendo o
// módulo de Metas independente.
IconData iconeHobby(String nome) {
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

  // Reconstrói a frequência a partir do mapa aninhado salvo no documento.
  factory Frequencia.fromMap(Map<String, dynamic> map) {
    final tipo = _enumFromName(
      TipoFrequencia.values,
      map['tipo'] as String?,
      TipoFrequencia.porPeriodo,
    );
    if (tipo == TipoFrequencia.diasSemana) {
      final dias = (map['dias'] as List?) ?? const [];
      return Frequencia.diasSemana(
        dias.map((e) => (e as num).toInt()).toSet(),
      );
    }
    return Frequencia.porPeriodo(
      vezes: (map['vezes'] as num?)?.toInt() ?? 1,
      unidade: _enumFromName(
        UnidadePeriodo.values,
        map['unidade'] as String?,
        UnidadePeriodo.semana,
      ),
    );
  }

  // Objeto -> mapa, guardado como campo aninhado dentro do documento da meta.
  Map<String, dynamic> toMap() => {
        'tipo': tipo.name,
        'vezes': vezes,
        'unidade': unidade.name,
        'dias': (dias.toList()..sort()),
      };

  bool get valida =>
      tipo == TipoFrequencia.porPeriodo ? vezes > 0 : dias.isNotEmpty;

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

// Hobby é a entidade-pai: representa a "área" de prática do usuário
// (Leitura, Violão, Jogos...). Uma Meta é sempre derivada de um Hobby.
// O hobby fornece identidade visual (ícone + cor) — a Meta apenas herda.
//
// Os campos espelham o documento da coleção `hobbies` no Firestore:
//   nome (string), icone_nome (string) e cor (int -> Color).
class Hobby {
  final String id;
  final String nome;
  final String iconeNome;
  final Color cor;

  const Hobby({
    required this.id,
    required this.nome,
    required this.iconeNome,
    required this.cor,
  });

  // Constrói um Hobby a partir de um documento da coleção `hobbies`.
  factory Hobby.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Hobby(
      id: doc.id,
      nome: d['nome'] as String? ?? '',
      iconeNome: d['icone_nome'] as String? ?? '',
      cor: Color((d['cor'] as num?)?.toInt() ?? 0xFF8738F2),
    );
  }

  IconData get icone => iconeHobby(iconeNome);

  // Igualdade por id: necessário pro DropdownButton reconhecer o hobby
  // selecionado mesmo sendo uma instância diferente vinda do Firestore.
  @override
  bool operator ==(Object other) => other is Hobby && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Meta {
  // id do documento no Firestore. Nulo enquanto a meta ainda não foi salva.
  final String? id;

  String titulo;
  Hobby hobby;
  TipoMeta tipo;
  Frequencia frequencia;
  int valorAlvo; // só usado por quantitativa
  int progresso; // só usado por quantitativa
  StatusMeta status;
  List<EstadoCheck> checks; // só usado por qualitativa

  Meta({
    this.id,
    required this.titulo,
    required this.hobby,
    required this.tipo,
    required this.frequencia,
    this.valorAlvo = 0,
    this.progresso = 0,
    this.status = StatusMeta.emAndamento,
    List<EstadoCheck>? checks,
  }) : checks = checks ?? [];

  // Documento do Firestore -> objeto Meta.
  // `doc.data()` é o mapa de campos; `doc.id` é o id do documento.
  factory Meta.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Meta(
      id: doc.id,
      titulo: d['titulo'] as String? ?? '',
      // O hobby vem desnormalizado dentro da própria meta (campos hobby_*),
      // então não precisamos buscar na coleção `hobbies` pra montar o card.
      hobby: Hobby(
        id: d['hobby_id'] as String? ?? '',
        nome: d['hobby_nome'] as String? ?? '',
        iconeNome: d['hobby_icone'] as String? ?? '',
        cor: Color((d['hobby_cor'] as num?)?.toInt() ?? 0xFF8738F2),
      ),
      tipo: _enumFromName(
        TipoMeta.values,
        d['tipo'] as String?,
        TipoMeta.quantitativa,
      ),
      frequencia: Frequencia.fromMap(
        (d['frequencia'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      valorAlvo: (d['valor_alvo'] as num?)?.toInt() ?? 0,
      progresso: (d['progresso'] as num?)?.toInt() ?? 0,
      status: _enumFromName(
        StatusMeta.values,
        d['status'] as String?,
        StatusMeta.emAndamento,
      ),
      checks: ((d['checks'] as List?) ?? const [])
          .map((e) =>
              _enumFromName(EstadoCheck.values, e as String?, EstadoCheck.vazio))
          .toList(),
    );
  }

  // Objeto Meta -> mapa de campos pro Firestore (usado no add e no update).
  // `criado_em` NÃO entra aqui de propósito: ele é gravado só na criação
  // (na TelaMetas), pra um update não sobrescrever a data original.
  Map<String, dynamic> toMap(String email) => {
        'criado_por': email,
        'titulo': titulo,
        // Identidade visual do hobby copiada pra dentro da meta (desnormalização).
        'hobby_id': hobby.id,
        'hobby_nome': hobby.nome,
        'hobby_cor': hobby.cor.toARGB32(),
        'hobby_icone': hobby.iconeNome,
        'tipo': tipo.name,
        'frequencia': frequencia.toMap(),
        'valor_alvo': valorAlvo,
        'progresso': progresso,
        'status': status.name,
        'checks': checks.map((c) => c.name).toList(),
        'ultima_atualizacao': Timestamp.now(),
      };

  // Identidade visual derivada do hobby.
  IconData get icone => hobby.icone;
  Color get cor => hobby.cor;

  String get subtitulo => '${hobby.nome} · ${frequencia.descricao}';

  double get percentual {
    if (valorAlvo <= 0) return 0;
    final p = progresso / valorAlvo;
    return p > 1 ? 1 : p;
  }

  // Métrica usada pra eleger a meta "mais frequente do mês".
  // Pra quantitativa = progresso, pra qualitativa = nº de checks concluídos.
  int get pontuacaoProgresso => tipo == TipoMeta.quantitativa
      ? progresso
      : checks.where((c) => c == EstadoCheck.concluido).length;
}
