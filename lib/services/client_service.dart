import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final CollectionReference clientsRef =
  FirebaseFirestore.instance.collection('clients');

  Future<void> addTestClient() async {
    await clientsRef.add({
      'nomClient': 'Société ABC',
      'ville': 'Casablanca',
      'telephone': '0600000000',
      'email': 'contact@abc.ma',
      'typeContrat': 'Annuel',
      'dateDebutContrat': DateTime.now(),
      'dateDernierIntervention': DateTime.now(),
    });
  }
}
