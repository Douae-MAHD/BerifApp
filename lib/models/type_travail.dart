class TypeTravail {
  final String id;
  final String nomType;

  TypeTravail({
    required this.id,
    required this.nomType,
  });

  factory TypeTravail.fromMap(String id, Map<String, dynamic> data) {
    return TypeTravail(
      id: id,
      nomType: data['nom_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom_type': nomType,
    };
  }
}
