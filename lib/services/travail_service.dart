import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travail.dart';

class TravailService {
  final CollectionReference travaux =
  FirebaseFirestore.instance.collection('travaux');

  /// 🔹 Lire tous les travaux
  Stream<List<Travail>> getTravaux() {
    return travaux.snapshots().map((snapshot) {
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
    final doc = await travaux.add(travail.toMap());
    return doc.id;
  }
}
