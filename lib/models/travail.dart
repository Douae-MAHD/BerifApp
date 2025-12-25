import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ AJOUTE CETTE LIGNE

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
    String normalizeStatut(dynamic value) {
      if (value == null) return 'en_attente';
      return value
          .toString()
          .toLowerCase()
          .replaceAll(' ', '_');
    }

    return Travail(
      id: id,
      clientId: data['id_client']?.toString() ?? '',
      equipeId: data['id_equipe']?.toString(),
      typeId: data['id_type']?.toString() ?? 'standard',
      commentaire: data['commentaire']?.toString() ?? '',
      datePlanifiee: data['datePlanifiee'] is Timestamp
          ? (data['datePlanifiee'] as Timestamp).toDate()
          : null,
      dateRealisation: data['dateRealisation'] is Timestamp
          ? (data['dateRealisation'] as Timestamp).toDate()
          : null,
      statut: normalizeStatut(data['statut']),
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