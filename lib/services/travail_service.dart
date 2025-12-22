import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travail.dart';

class TravailService {
  final CollectionReference travaux =
  FirebaseFirestore.instance.collection('travaux');

  Future<String> addTravail(Travail travail) async {
    final doc = await travaux.add(travail.toMap());
    return doc.id;
  }
}
