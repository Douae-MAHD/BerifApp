import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipe.dart';

class EquipeService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('equipes');

  Stream<List<Equipe>> getEquipes() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Equipe.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addEquipe(Equipe equipe) => _db.add(equipe.toMap());

  Future<void> deleteEquipe(String id) => _db.doc(id).delete();
}