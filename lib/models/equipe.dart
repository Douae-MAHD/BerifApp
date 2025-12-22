class Equipe {
  final String? id;
  final String nomEquipe;
  final bool disponibilite;

  Equipe({
    required this.id,
    required this.nomEquipe,
    required this.disponibilite,
  });

  factory Equipe.fromMap(String id, Map<String, dynamic> data) {
    return Equipe(
      id: id,
      nomEquipe: data['nom_equipe'],
      disponibilite: data['disponibilite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom_equipe': nomEquipe,
      'disponibilite': disponibilite,
    };
  }
}
