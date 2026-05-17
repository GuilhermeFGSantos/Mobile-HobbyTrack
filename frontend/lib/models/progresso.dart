class Progresso {
  final String id;
  final String hobbyId;
  final int valor;
  final String date;

  const Progresso({
    required this.id,
    required this.hobbyId,
    required this.valor,
    required this.date,
  });

  factory Progresso.fromJson(Map<String, dynamic> json) => Progresso(
        id: json['id'] as String,
        hobbyId: json['hobbyId'] as String? ?? '',
        valor: json['valor'] as int? ?? 0,
        date: json['date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hobbyId': hobbyId,
        'valor': valor,
        'date': date,
      };
}
