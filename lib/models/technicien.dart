class Technicien {
  final String id;
  final String utilisateurId;
  final String nom;
  final String prenom;
  final String telephone;
  final String specialite;

  Technicien({
    required this.id,
    required this.utilisateurId,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.specialite,
  });

  factory Technicien.fromMap(String id, Map<String, dynamic> data) {
    return Technicien(
      id: id,
      utilisateurId: data['id_utilisateur'],
      nom: data['nom'],
      prenom: data['prenom'],
      telephone: data['telephone'],
      specialite: data['specialite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': utilisateurId,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'specialite': specialite,
    };
  }
}
