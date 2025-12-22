class Travail {
  final String? id;
  final String clientId;
  final String? equipeId;
  final String typeId;
  final String commentaire;
  final DateTime? datePlanifiee;
  final DateTime? dateRealisation;
  final String statut;

  Travail({
    required this.id,
    required this.clientId,
    this.equipeId,
    required this.typeId,
    required this.commentaire,
    this.datePlanifiee,
    this.dateRealisation,
    required this.statut,
  });

  factory Travail.fromMap(String id, Map<String, dynamic> data) {
    return Travail(
      id: id,
      clientId: data['id_client'],
      equipeId: data['id_equipe'],
      typeId: data['id_type'],
      commentaire: data['commentaire'],
      datePlanifiee: data['datePlanifiee']?.toDate(),
      dateRealisation: data['dateRealisation']?.toDate(),
      statut: data['statut'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_client': clientId,
      'id_equipe': equipeId,
      'id_type': typeId,
      'commentaire': commentaire,
      'datePlanifiee': datePlanifiee,
      'dateRealisation': dateRealisation,
      'statut': statut,
    };
  }
}
