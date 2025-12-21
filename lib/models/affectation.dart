class Affectation {
  final String equipeId;
  final String technicienId;
  final DateTime dateAffectation;

  Affectation({
    required this.equipeId,
    required this.technicienId,
    required this.dateAffectation,
  });

  factory Affectation.fromMap(Map<String, dynamic> data) {
    return Affectation(
      equipeId: data['id_equipe'],
      technicienId: data['id_technicien'],
      dateAffectation: data['date_affectation'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_equipe': equipeId,
      'id_technicien': technicienId,
      'date_affectation': dateAffectation,
    };
  }
}
