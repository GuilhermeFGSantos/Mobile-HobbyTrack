import 'api_client.dart';

class Stats {
  final int sequenciaAtual;
  final int totalSemana;
  final int totalSemanaPassada;

  const Stats({
    required this.sequenciaAtual,
    required this.totalSemana,
    required this.totalSemanaPassada,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        sequenciaAtual: json['sequenciaAtual'] as int? ?? 0,
        totalSemana: json['totalSemana'] as int? ?? 0,
        totalSemanaPassada: json['totalSemanaPassada'] as int? ?? 0,
      );

  int get evolucaoPercent {
    if (totalSemanaPassada == 0) return totalSemana > 0 ? 100 : 0;
    return (((totalSemana - totalSemanaPassada) / totalSemanaPassada) * 100)
        .round();
  }
}

class StatsService {
  static Future<Stats> get() async {
    final res = await ApiClient.dio.get('/stats');
    return Stats.fromJson(res.data as Map<String, dynamic>);
  }
}
