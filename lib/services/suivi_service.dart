import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/suivi_travail.dart';

class SuiviTravailService {
  final CollectionReference suivis =
  FirebaseFirestore.instance.collection('suivi_travaux');

  Future<String> addSuivi(SuiviTravail suivi) async {
    final doc = await suivis.add(suivi.toMap());
    return doc.id;
  }
}
