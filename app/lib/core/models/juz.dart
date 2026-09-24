class Juz {
  final int numero;
  final int pageDebut;

  /// Nom du Juz' tel qu'il apparaît dans l'en-tête de chaque page du
  /// Mosshaf (ex. "الأول", "الحادي عشر", "الثلاثون").
  final String nom;

  const Juz({required this.numero, required this.pageDebut, required this.nom});

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      numero: json['numero'] as int,
      pageDebut: json['pageDebut'] as int,
      nom: json['nom'] as String,
    );
  }
}

class Hizb {
  final int numero;
  final int pageDebut;

  const Hizb({required this.numero, required this.pageDebut});

  factory Hizb.fromJson(Map<String, dynamic> json) {
    return Hizb(
      numero: json['numero'] as int,
      pageDebut: json['pageDebut'] as int,
    );
  }
}
