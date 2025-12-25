import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/technicien.dart';

class TechnicienService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('techniciens');

  Stream<List<Technicien>> getTechniciens() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Technicien.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addTechnicien(Technicien tech) => _db.add(tech.toMap());

  Future<void> deleteTechnicien(String id) => _db.doc(id).delete();
}