import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/utilisateur.dart';

// --- Les Providers sont en DEHORS de la classe ---
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

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
      DocumentSnapshot doc = await _db.collection('utilisateurs').doc(uid).get();

      if (!doc.exists) {
        throw Exception("Profil utilisateur introuvable");
      }

      return Utilisateur.fromMap(uid, doc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ================= CREATE TECH =================
  Future<void> adminCreateTechnician({
    required String email,
    required String password,
    required String username,
    required String telephone,
    required String prenom,
  }) async {
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempApp',
      options: Firebase.app().options,
    );

    final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
    final tempDb = FirebaseFirestore.instanceFor(app: tempApp);

    try {
      UserCredential result = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final uid = result.user!.uid;

      await tempDb.collection('utilisateurs').doc(uid).set({
        'username': username,
        'email': email.trim().toLowerCase(),
        'role': 'technicien',
        'actif': true,
        'dateCreation': FieldValue.serverTimestamp(),
      });

      await tempDb.collection('techniciens').doc(uid).set({
        'id_utilisateur': uid,
        'nom': username,
        'prenom': prenom,
        'email': email.trim().toLowerCase(),
        'telephone': telephone,
        'specialite': 'Général',
      });
    } finally {
      await tempApp.delete();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }
} // <--- FIN DE LA CLASSE (Une seule accolade ici)