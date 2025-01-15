class User {
  final String id;  // Ajout de l'ID utilisateur
  final String nom;
  final String prenom;
  final String email;
  final String? imagePath;

  User({
    required this.id, // Le constructeur attend un ID
    required this.nom,
    required this.prenom,
    required this.email,
    this.imagePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Supposons que l'API renvoie un champ 'id'
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      imagePath: json['imagePath'],
    );
  }
}
