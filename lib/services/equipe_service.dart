import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipe.dart';

class EquipeService {
  // Référence à la collection "equipes" dans Firestore
  final CollectionReference _db = FirebaseFirestore.instance.collection('equipes');

  /// 🔹 LIRE toutes les équipes (Flux en temps réel)
  Stream<List<Equipe>> getEquipes() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Equipe.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>
        );
      }).toList();
    });
  }

  /// 🔹 AJOUTER une nouvelle équipe (Create)
  Future<String> addEquipe(Equipe equipe) async {
    final docRef = await _db.add(equipe.toMap());
    return docRef.id;
  }

  /// 🔹 MODIFIER une équipe (Update)
  /// Permet de changer le nom ou l'état de disponibilité
  Future<void> updateEquipe(String id, Map<String, dynamic> data) async {
    await _db.doc(id).update(data);
  }

  /// 🔹 SUPPRIMER une équipe (Delete)
  /// Note : Pense à supprimer aussi les "affectations" liées dans AffectationService
  Future<void> deleteEquipe(String id) async {
    await _db.doc(id).delete();
  }

  /// 🔹 CHANGER LA DISPONIBILITÉ RAPIDEMENT
  Future<void> toggleDisponibilite(String id, bool estDisponible) async {
    await _db.doc(id).update({'disponibilite': estDisponible});
  }
}