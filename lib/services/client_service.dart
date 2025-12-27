import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('clients');

  Stream<List<Client>> getClients() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Client.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addClient(Client client) => _db.add(client.toMap());

  Future<void> updateClient(String id, Map<String, dynamic> data) => _db.doc(id).update(data);

  Future<void> deleteClient(String id) => _db.doc(id).delete();
}