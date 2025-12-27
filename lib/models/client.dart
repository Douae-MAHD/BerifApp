class Client {
  final String? id;
  final String nomClient;
  final String adresse;
  final String ville;
  final String telephone;
  final String email;
  final String typeContrat;
  final DateTime? dateDebutContrat;
  final String periodiciteMaintenance;
  final DateTime? dateDernierIntervention;
  final String secteur;

  Client({
    required this.id,
    required this.nomClient,
    required this.adresse,
    required this.ville,
    required this.telephone,
    required this.email,
    required this.typeContrat,
    this.dateDebutContrat,
    required this.periodiciteMaintenance,
    this.dateDernierIntervention,
    required this.secteur,
  });

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(
      id: id,
      // On sécurise chaque champ String avec ?? ''
      nomClient: data['nom_client']?.toString() ?? 'Sans nom',
      adresse: data['adresse']?.toString() ?? 'Pas d\'adresse',
      ville: data['ville']?.toString() ?? '',
      telephone: data['telephone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      typeContrat: data['typeContrat']?.toString() ?? 'Standard',
      periodiciteMaintenance: data['periodiciteMaintenance']?.toString() ?? 'Mensuelle',
      secteur: data['secteur']?.toString() ?? 'Général',

      // Sécurisation des dates (si le champ n'existe pas ou n'est pas un Timestamp)
      dateDebutContrat: data['dateDebutContrat'] != null
          ? (data['dateDebutContrat'] as dynamic).toDate()
          : null,
      dateDernierIntervention: data['dateDernierIntervention'] != null
          ? (data['dateDernierIntervention'] as dynamic).toDate()
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nom_client': nomClient,
      'adresse': adresse,
      'ville': ville,
      'telephone': telephone,
      'email': email,
      'typeContrat': typeContrat,
      'dateDebutContrat': dateDebutContrat,
      'periodiciteMaintenance': periodiciteMaintenance,
      'dateDernierIntervention': dateDernierIntervention,
      'secteur': secteur,
    };
  }
}