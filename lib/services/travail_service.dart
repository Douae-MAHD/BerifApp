import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travail.dart';

class TravailService {
  final CollectionReference _db =
  FirebaseFirestore.instance.collection('travaux');

  /// 🔹 Lire tous les travaux (Temps réel)
  Stream<List<Travail>> getTravaux() {
    return _db.snapshots().map((snapshot) {
      print("🔥 Firestore → ${snapshot.docs.length} documents trouvés");

      return snapshot.docs.map((doc) {
        print("📄 ${doc.id} => ${doc.data()}");

        return Travail.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// 🔹 Ajouter un travail
  Future<String> addTravail(Travail travail) async {
    final doc = await _db.add(travail.toMap());
    return doc.id;
  }

  /// 🔹 Mettre à jour le statut d'un travail (ex: termine)
  Future<void> updateStatut(String id, String nouveauStatut) async {
    await _db.doc(id).update({'statut': nouveauStatut});
  }

  /// 🔹 Assigner une équipe à un travail
  Future<void> assignEquipe(String idTravail, String idEquipe) async {
    await _db.doc(idTravail).update({
      'idEquipe': idEquipe,
      'statut': 'assigne',
    });
  }

  // Ajouter cette méthode dans la classe TravailService
  Future<void> affecterEquipe(String travailId, String equipeId) async {
    await _db.doc(travailId).update({
      'id_equipe': equipeId,
      'statut': 'en_cours', // Passe en "En cours" dès qu'une équipe est sur le coup
    });
  }

  // Dans la classe TravailService

  /// 🔹 Modifier un travail existant
  Future<void> updateTravail(String id, Map<String, dynamic> data) async {
    await _db.doc(id).update(data);
  }

  /// 🔹 Supprimer un travail
  Future<void> deleteTravail(String id) async {
    await _db.doc(id).delete();
    // Optionnel : Supprimer aussi les suivis associés dans 'suivi_travaux'
  }

}