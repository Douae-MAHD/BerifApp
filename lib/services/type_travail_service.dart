import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/type_travail.dart';

class TypeTravailService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('types_travaux');

  Stream<List<TypeTravail>> getTypes() {
    return _collection.snapshots().map((snap) =>
        snap.docs.map((doc) => TypeTravail.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addType(String nom) {
    return _collection.add({'nom_type': nom});
  }
  Future<void> seedTypes() async {
    List<String> types = [
      "Maintenance",
      "Livraison",
      "Recouvrement",
      "Dépôts de factures",
      "Rendez-vous"
    ];

    for (String type in types) {
      // On vérifie si le type existe déjà pour éviter les doublons
      final query = await _collection.where('nom_type', isEqualTo: type).get();
      if (query.docs.isEmpty) {
        await _collection.add({'nom_type': type});
      }
    }
  }
}