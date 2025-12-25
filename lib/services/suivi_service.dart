import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class SuiviService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> mettreAJourStatut({
    required String travailId,
    required String nouveauStatut,
    required String commentaire, // ✅ Doit être une simple String ici
    String? equipeId,
    String? localPath,
  }) async {
    String? fileUrl;

    // 1. Upload du PDF si sélectionné
    if (localPath != null) {
      File file = File(localPath);
      String fileName = p.basename(localPath);
      Reference ref = _storage.ref().child('rapports/$travailId/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      fileUrl = await snapshot.ref.getDownloadURL();
    }

    // 2. Mettre à jour le statut global du travail
    await _db.collection('travaux').doc(travailId).update({
      'statut': nouveauStatut,
    });

    // 3. Créer l'historique dans suivi_travaux
    await _db.collection('suivi_travaux').add({
      'id_travail': travailId,
      'id_equipe': equipeId,
      'commentaire': commentaire, // ✅ On enregistre le texte reçu de l'UI
      'date_suivi': FieldValue.serverTimestamp(),
      'pdfUrl': fileUrl,
    });
  }
}