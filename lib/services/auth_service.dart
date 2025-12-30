import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<Utilisateur?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final uid = result.user!.uid;

      DocumentSnapshot doc =
      await _db.collection('utilisateurs').doc(uid).get();

      if (!doc.exists) {
        throw Exception("Profil utilisateur introuvable");
      }

      return Utilisateur.fromMap(uid, doc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ================= CREATE TECH =================
  // Dans AuthService.dart
  Future<void> adminCreateTechnician({
    required String email,
    required String password,
    required String username,
    required String telephone,
    required String prenom,
  }) async {
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempApp',
      options: Firebase
          .app()
          .options,
    );

    final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
    final tempDb = FirebaseFirestore.instanceFor(app: tempApp);

    try {
      UserCredential result = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final uid = result.user!.uid;

      // 1. Créer le compte Utilisateur
      await tempDb.collection('utilisateurs').doc(uid).set({
        'username': username,
        'email': email.trim().toLowerCase(),
        'role': 'technicien',
        'actif': true,
        'dateCreation': FieldValue.serverTimestamp(),
      });

      // 2. Créer le profil Technicien (Relation 1:1 via l'ID)
      await tempDb.collection('techniciens').doc(uid).set({
        'id_utilisateur': uid,
        'nom': username,
        'prenom': prenom,
        'email': email.trim().toLowerCase(),
        'telephone': telephone,
        'specialite': 'Général', // Par défaut
      });
    } finally {
      await tempApp.delete();
    }
  }}