import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String id;
  final String username;
  final String email;
  final String role; // admin | technicien
  final bool actif;
  final DateTime dateCreation;
  // Note : On évite de stocker le mot de passe en clair dans Firestore pour la sécurité.
  // Firebase Auth gère déjà le mot de passe de manière cryptée.

  Utilisateur({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.actif,
    required this.dateCreation,
  });

  // Usine (Factory) pour transformer un document Firestore en objet Utilisateur
  factory Utilisateur.fromMap(String id, Map<String, dynamic> data) {
    return Utilisateur(
      id: id,
      username: data['username'] ?? '', // Valeur par défaut si null
      email: data['email'] ?? '',
      role: data['role'] ?? 'technicien',
      actif: data['actif'] ?? true,
      // Conversion sécurisée du Timestamp Firebase en DateTime Dart
      dateCreation: data['dateCreation'] != null
          ? (data['dateCreation'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Méthode pour transformer l'objet en Map pour l'envoi vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'actif': actif,
      // Firebase préfère recevoir un FieldValue ou un DateTime pour ses Timestamps
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }
}