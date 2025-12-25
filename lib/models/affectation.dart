class Affectation {
  final String id;
  final String equipeId;
  final String technicienId;
  final DateTime dateAffectation;

  Affectation({
    required this.id,
    required this.equipeId,
    required this.technicienId,
    required this.dateAffectation,
  });

  factory Affectation.fromMap(String id, Map<String, dynamic> data) {
    return Affectation(
      id: id,
      equipeId: data['equipeId'],
      technicienId: data['technicienId'],
      dateAffectation: data['dateAffectation'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipeId': equipeId,
      'technicienId': technicienId,
      'dateAffectation': dateAffectation,
    };
  }
}
