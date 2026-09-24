class TajwidResource {
  final String id;
  final String titre;
  final String fichier;

  const TajwidResource({
    required this.id,
    required this.titre,
    required this.fichier,
  });

  factory TajwidResource.fromJson(Map<String, dynamic> json) {
    return TajwidResource(
      id: json['id'] as String,
      titre: json['titre'] as String,
      fichier: json['fichier'] as String,
    );
  }
}
