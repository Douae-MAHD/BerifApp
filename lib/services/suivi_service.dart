import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class SuiviService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _analyzeBaseUrl = 'http://10.20.60.149:8000';

  /* ───────────────────────────────
     🔹 Mise à jour statut + PDF
     ─────────────────────────────── */
  Future<String?> mettreAJourStatut({
    required String travailId,
    required String nouveauStatut,
    required String commentaire,
    String? equipeId,
    String? localPath,
    Map<String, dynamic>? analyseResult, // ✅ On reçoit le résultat ici
  }) async {
    String? fileUrl;

    // 1️⃣ Upload PDF vers Firebase Storage
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        final fileName = p.basename(localPath);
        final ref = _storage.ref().child('rapports/$travailId/$fileName');
        final snapshot = await ref.putFile(file);
        fileUrl = await snapshot.ref.getDownloadURL();
      }
    }

    // 2️⃣ Mise à jour du statut du travail
    await _db.collection('travaux').doc(travailId).update({
      'statut': nouveauStatut,
    });

    // 3️⃣ Sauvegarde historique + résultat analyse
    // ✅ Utilisation du paramètre analyseResult reçu pour éviter l'erreur 422
    await _db.collection('suivi_travaux').add({
      'id_travail': travailId,
      'id_equipe': equipeId,
      'commentaire': commentaire,
      'date_suivi': FieldValue.serverTimestamp(),
      'pdfUrl': fileUrl,
      'analyse': analyseResult,
    });

    return fileUrl;
  }

  /* ───────────────────────────────
     🔹 Appel API /analyze (Utilisé si besoin)
     ─────────────────────────────── */
  Future<Map<String, dynamic>> analyzePdfService(File pdfFile) async {
    try {
      final uri = Uri.parse('$_analyzeBaseUrl/analyze');
      final request = http.MultipartRequest('POST', uri);

      // ✅ CORRECTION : 'indices_pdf' pour correspondre au backend
      request.files.add(
        await http.MultipartFile.fromPath('indices_pdf', pdfFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur serveur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur analyse PDF: $e');
    }
  }
}