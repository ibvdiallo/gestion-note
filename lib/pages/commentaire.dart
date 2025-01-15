

class Commentaire {
  final String contenu;
  final String auteur;
  final String dateCreation;

  Commentaire({required this.contenu, required this.auteur, required this.dateCreation});

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
      contenu: json['contenu'],
      auteur: json['utilisateur']['nom'], // Assurez-vous que l'objet utilisateur est bien inclus
      dateCreation: json['dateCreation'],
    );
  }
}

