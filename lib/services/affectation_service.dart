import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/affectation.dart';

class AffectationService {
  // Référence à la collection "affectations"
  final CollectionReference<Map<String, dynamic>> _affectations =
  FirebaseFirestore.instance.collection('affectations');

  /// 🔹 AJOUTER une affectation (Lier un technicien à une équipe)
  Future<void> addAffectation(Affectation affectation) async {
    // Optionnel : Vérifier si l'affectation existe déjà pour éviter les doublons
    final existing = await _affectations
        .where('equipeId', isEqualTo: affectation.equipeId)
        .where('technicienId', isEqualTo: affectation.technicienId)
        .get();

    if (existing.docs.isEmpty) {
      await _affectations.add(affectation.toMap());
    }
  }

  /// 🔹 LIRE les affectations d'une équipe précise (Temps réel)
  Stream<List<Affectation>> getAffectationsByEquipe(String equipeId) {
    return _affectations
        .where('equipeId', isEqualTo: equipeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Affectation.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// 🔹 LIRE les affectations d'un technicien précis
  /// (Utile pour savoir à quelle(s) équipe(s) appartient un technicien)
  Stream<List<Affectation>> getAffectationsByTechnicien(String technicienId) {
    return _affectations
        .where('technicienId', isEqualTo: technicienId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Affectation.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// 🔹 SUPPRIMER une affectation précise (Retirer un tech d'une équipe)
  Future<void> removeTechnicienFromEquipe(String equipeId, String technicienId) async {
    final snapshot = await _affectations
        .where('equipeId', isEqualTo: equipeId)
        .where('technicienId', isEqualTo: technicienId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 🔹 SUPPRIMER TOUTES les affectations d'une équipe
  /// (Appelé lors de la suppression d'une équipe ou avant une mise à jour totale des membres)
  Future<void> removeAllAffectationsByEquipe(String equipeId) async {
    final snapshot = await _affectations
        .where('equipeId', isEqualTo: equipeId)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// 🔹 SUPPRIMER TOUTES les affectations d'un technicien
  /// (Appelé si un technicien quitte l'entreprise)
  Future<void> removeAllAffectationsByTechnicien(String technicienId) async {
    final snapshot = await _affectations
        .where('technicienId', isEqualTo: technicienId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}