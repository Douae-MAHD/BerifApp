import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientService {
  final CollectionReference<Map<String, dynamic>> clients =
  FirebaseFirestore.instance.collection('clients');

  /// ➕ Ajouter un client
  Future<String> addClient(Client client) async {
    final doc = await clients.add(client.toMap());
    return doc.id;
  }

  /// 📡 Récupérer les clients (Stream)
  Stream<List<Client>> getClients() {
    return clients.snapshots().map(
          (snapshot) {
        return snapshot.docs.map(
              (doc) {
            return Client.fromMap(
              doc.id,
              doc.data(),
            );
          },
        ).toList();
      },
    );
  }

  /// ✏️ Modifier un client
  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    await clients.doc(id).update(data);
  }

  /// ❌ Supprimer un client
  Future<void> deleteClient(String id) async {
    await clients.doc(id).delete();
  }
}
