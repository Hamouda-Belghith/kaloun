class TajwidResource {
  final String id;
  final String titre;
  final List<String> fichiers;

  const TajwidResource({
    required this.id,
    required this.titre,
    required this.fichiers,
  });

  factory TajwidResource.fromJson(Map<String, dynamic> json) {
    return TajwidResource(
      id: json['id'] as String,
      titre: json['titre'] as String,
      fichiers: (json['fichiers'] as List).cast<String>(),
    );
  }
}
