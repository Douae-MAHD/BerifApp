import 'package:cloud_firestore/cloud_firestore.dart';

class SuiviTravail {
  final String? id;
  final String travailId;
  final String? equipeId;
  final String commentaire;
  final DateTime dateSuivi;
  final String? pdfUrl; // ✅ AJOUTE CETTE LIGNE

  SuiviTravail({
    this.id,
    required this.travailId,
    this.equipeId,
    required this.commentaire,
    required this.dateSuivi,
    this.pdfUrl, // ✅ AJOUTE CETTE LIGNE
  });

  factory SuiviTravail.fromMap(String id, Map<String, dynamic> data) {
    return SuiviTravail(
      id: id,
      travailId: data['id_travail'] ?? '',
      equipeId: data['id_equipe'],
      commentaire: data['commentaire'] ?? '',
      // Gestion de la date selon si c'est un Timestamp Firestore ou une String
      dateSuivi: data['date_suivi'] is Timestamp
          ? (data['date_suivi'] as Timestamp).toDate()
          : DateTime.now(),
      pdfUrl: data['pdfUrl'], // ✅ RÉCUPÉRATION DEPUIS FIRESTORE
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_travail': travailId,
      'id_equipe': equipeId,
      'commentaire': commentaire,
      'date_suivi': dateSuivi,
      'pdfUrl': pdfUrl,
    };
  }
}