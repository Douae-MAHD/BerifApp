import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/technicien.dart';

class TechnicienService {
  final CollectionReference _techniciens =
  FirebaseFirestore.instance.collection('techniciens');

  /// ➕ Ajouter un technicien (retourne l'id Firestore)
  Future<String> addTechnicien(Technicien technicien) async {
    final doc = await _techniciens.add(technicien.toMap());
    return doc.id;
  }

  /// 📥 Récupérer tous les techniciens
  Stream<List<Technicien>> getTechniciens() {
    return _techniciens.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Technicien.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// ❌ Supprimer un technicien
  Future<void> deleteTechnicien(String id) async {
    await _techniciens.doc(id).delete();
  }
}
