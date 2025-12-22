import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final CollectionReference clients =
  FirebaseFirestore.instance.collection('clients');

  Future<void> addClient(Map<String, dynamic> data) async {
    await clients.add(data);
  }

  Stream<QuerySnapshot> getClients() {
    return clients.snapshots();
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    await clients.doc(id).update(data);
  }

  Future<void> deleteClient(String id) async {
    await clients.doc(id).delete();
  }
}
