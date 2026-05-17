class Hobby {
  final String id;
  final String name;
  final String emoji;
  final int metaValue;
  final String unit;
  final bool repeat;
  final List<int> days;
  final int reminderHour;
  final int reminderMin;
  final bool notification;
  final bool paused;
  final String? categoriaId;
  final String userId;
  final String createdAt;
  final String updatedAt;

  const Hobby({
    required this.id,
    required this.name,
    required this.emoji,
    required this.metaValue,
    required this.unit,
    required this.repeat,
    required this.days,
    required this.reminderHour,
    required this.reminderMin,
    required this.notification,
    required this.paused,
    required this.categoriaId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hobby.fromJson(Map<String, dynamic> json) => Hobby(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '',
        metaValue: json['metaValue'] as int? ?? 0,
        unit: json['unit'] as String? ?? '',
        repeat: json['repeat'] as bool? ?? false,
        days: (json['days'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        reminderHour: json['reminderHour'] as int? ?? 0,
        reminderMin: json['reminderMin'] as int? ?? 0,
        notification: json['notification'] as bool? ?? false,
        paused: json['paused'] as bool? ?? false,
        categoriaId: json['categoriaId'] as String?,
        userId: json['userId'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'metaValue': metaValue,
        'unit': unit,
        'repeat': repeat,
        'days': days,
        'reminderHour': reminderHour,
        'reminderMin': reminderMin,
        'notification': notification,
        'paused': paused,
        'categoriaId': categoriaId,
        'userId': userId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Hobby copyWith({
    String? name,
    String? emoji,
    int? metaValue,
    String? unit,
    bool? repeat,
    List<int>? days,
    int? reminderHour,
    int? reminderMin,
    bool? notification,
    bool? paused,
    String? categoriaId,
  }) =>
      Hobby(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        metaValue: metaValue ?? this.metaValue,
        unit: unit ?? this.unit,
        repeat: repeat ?? this.repeat,
        days: days ?? this.days,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMin: reminderMin ?? this.reminderMin,
        notification: notification ?? this.notification,
        paused: paused ?? this.paused,
        categoriaId: categoriaId ?? this.categoriaId,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
