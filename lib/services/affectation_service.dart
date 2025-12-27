import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/affectation.dart';

class AffectationService {
  final CollectionReference<Map<String, dynamic>> _affectations =
  FirebaseFirestore.instance.collection('affectations');

  Future<void> addAffectation(Affectation affectation) async {
    await _affectations.add(affectation.toMap());
  }

  Stream<List<Affectation>> getAffectationsByEquipe(String equipeId) {
    return _affectations
        .where('equipeId', isEqualTo: equipeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Affectation.fromMap(doc.id, doc.data()))
        .toList());
  }
}
