class Juz {
  final int numero;
  final int pageDebut;

  const Juz({required this.numero, required this.pageDebut});

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      numero: json['numero'] as int,
      pageDebut: json['pageDebut'] as int,
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
