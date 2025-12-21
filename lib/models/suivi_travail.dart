class SuiviTravail {
  final String id;
  final String travailId;
  final String equipeId;
  final String commentaire;
  final DateTime dateSuivi;

  SuiviTravail({
    required this.id,
    required this.travailId,
    required this.equipeId,
    required this.commentaire,
    required this.dateSuivi,
  });

  factory SuiviTravail.fromMap(String id, Map<String, dynamic> data) {
    return SuiviTravail(
      id: id,
      travailId: data['id_travail'],
      equipeId: data['id_equipe'],
      commentaire: data['commentaire'],
      dateSuivi: data['date_suivi'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_travail': travailId,
      'id_equipe': equipeId,
      'commentaire': commentaire,
      'date_suivi': dateSuivi,
    };
  }
}
