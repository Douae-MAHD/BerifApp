import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class SuiviService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 🔹 Ajouter un rapport simple (sans fichier)
  Future<void> addRapport(
      String idTravail,
      String idEquipe,
      String commentaire,
      ) async {
    await _db.collection('suivis').add({
      'idTravail': idTravail,
      'idEquipe': idEquipe,
      'commentaire': commentaire,
      'date_suivi': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Récupérer l’historique d’un travail précis
  Stream<QuerySnapshot> getHistoriqueTravail(String idTravail) {
    return _db
        .collection('suivis')
        .where('idTravail', isEqualTo: idTravail)
        .orderBy('date_suivi', descending: true)
        .snapshots();
  }

  /// 🔹 Mise à jour du statut + historique + PDF optionnel
  Future<void> mettreAJourStatut({
    required String travailId,
    required String nouveauStatut,
    required String commentaire,
    String? equipeId,
    String? localPath,
  }) async {
    String? fileUrl;

    // 1️⃣ Upload du PDF si fourni
    if (localPath != null) {
      File file = File(localPath);
      String fileName = p.basename(localPath);
      Reference ref =
      _storage.ref().child('rapports/$travailId/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      fileUrl = await snapshot.ref.getDownloadURL();
    }

    // 2️⃣ Mettre à jour le statut du travail
    await _db.collection('travaux').doc(travailId).update({
      'statut': nouveauStatut,
    });

    // 3️⃣ Créer l’historique détaillé
    await _db.collection('suivi_travaux').add({
      'id_travail': travailId,
      'id_equipe': equipeId,
      'commentaire': commentaire,
      'date_suivi': FieldValue.serverTimestamp(),
      'pdfUrl': fileUrl,
    });
  }
}