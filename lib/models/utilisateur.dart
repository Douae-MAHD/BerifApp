class Utilisateur {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role; // admin | technicien
  final bool actif;
  final DateTime dateCreation;

  Utilisateur({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.actif,
    required this.dateCreation,
  });

  factory Utilisateur.fromMap(String id, Map<String, dynamic> data) {
    return Utilisateur(
      id: id,
      username: data['username'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
      actif: data['actif'],
      dateCreation: data['dateCreation'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'actif': actif,
      'dateCreation': dateCreation,
    };
  }
}
