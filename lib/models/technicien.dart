class Technicien {
  final String id; // L'ID Firestore
  final String utilisateurId;
  final String nom;
  final String prenom;
  final String email; // ✅ AJOUTER CECI
  final String telephone;
  final String specialite;

  Technicien({
    required this.id,
    required this.utilisateurId,
    required this.nom,
    required this.prenom,
    required this.email, // ✅ AJOUTER CECI
    required this.telephone,
    required this.specialite,
  });

  factory Technicien.fromMap(String id, Map<String, dynamic> data) {
    return Technicien(
      id: id,
      utilisateurId: data['id_utilisateur'] ?? '',
      nom: data['nom'] ?? data['username'] ?? 'Sans nom',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '', // ✅ AJOUTER CECI
      telephone: data['telephone'] ?? '',
      specialite: data['specialite'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': utilisateurId,
      'nom': nom,
      'prenom': prenom,
      'email': email, // ✅ AJOUTER CECI
      'telephone': telephone,
      'specialite': specialite,
    };
  }
}