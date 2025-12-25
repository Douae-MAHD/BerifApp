import 'package:cloud_firestore/cloud_firestore.dart';

class SuiviService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('suivis');

  // Ajouter un rapport d'intervention
  Future<void> addRapport(String idTravail, String idEquipe, String commentaire) async {
    await _db.add({
      'idTravail': idTravail,
      'idEquipe': idEquipe,
      'commentaire': commentaire,
      'date_suivi': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer l'historique d'un travail précis
  Stream<QuerySnapshot> getHistoriqueTravail(String idTravail) {
    return _db.where('idTravail', isEqualTo: idTravail)
        .orderBy('date_suivi', descending: true)
        .snapshots();
  }
}