class Resenia {
  final int? id;
  final int recetaId;
  final String texto;
  final DateTime fecha;

  const Resenia({
    this.id,
    required this.recetaId,
    required this.texto,
    required this.fecha,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'recetaId': recetaId,
      'texto': texto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Resenia.fromMap(Map<String, Object?> map) {
    return Resenia(
      id: map['id'] as int?,
      recetaId: map['recetaId'] as int,
      texto: map['texto'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }
}
