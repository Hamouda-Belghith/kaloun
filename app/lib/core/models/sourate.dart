class Sourate {
  final int numero;
  final String nomAr;
  final String nomFr;
  final int pageDebut;
  final int nombreAyat;
  final bool estMecquoise;

  const Sourate({
    required this.numero,
    required this.nomAr,
    required this.nomFr,
    required this.pageDebut,
    required this.nombreAyat,
    required this.estMecquoise,
  });

  factory Sourate.fromJson(Map<String, dynamic> json) {
    return Sourate(
      numero: json['numero'] as int,
      nomAr: json['nom_ar'] as String,
      nomFr: json['nom_fr'] as String,
      pageDebut: json['pageDebut'] as int,
      nombreAyat: json['nombreAyat'] as int,
      estMecquoise: json['estMecquoise'] as bool,
    );
  }
}
