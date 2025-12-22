import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipe.dart';

class EquipeService {
  final CollectionReference<Map<String, dynamic>> equipes =
  FirebaseFirestore.instance.collection('equipes');

  /// ➕ Ajouter une équipe
  Future<String> addEquipe(Equipe equipe) async {
    final doc = await equipes.add(equipe.toMap());
    return doc.id;
  }

  /// 📡 Récupérer les équipes (Stream)
  Stream<List<Equipe>> getEquipes() {
    return equipes.snapshots().map(
          (snapshot) {
        return snapshot.docs.map(
              (doc) {
            return Equipe.fromMap(
              doc.id,
              doc.data(),
            );
          },
        ).toList();
      },
    );
  }

  /// ❌ Supprimer une équipe
  Future<void> deleteEquipe(String id) async {
    await equipes.doc(id).delete();
  }
}
