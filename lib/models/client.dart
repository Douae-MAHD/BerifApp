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
      nomClient: data['nom_client'],
      adresse: data['adresse'],
      ville: data['ville'],
      telephone: data['telephone'],
      email: data['email'],
      typeContrat: data['typeContrat'],
      dateDebutContrat: data['dateDebutContrat']?.toDate(),
      periodiciteMaintenance: data['periodiciteMaintenance'],
      dateDernierIntervention: data['dateDernierIntervention']?.toDate(),
      secteur: data['secteur'],
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
