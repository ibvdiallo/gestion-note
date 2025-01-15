import 'package:intl/intl.dart';

class Note {
  final String id;
  final String titre;
  final String contenu;
  final String cours;
  final String userId; // L'ID de l'utilisateur
  final String auteur;
  final int nombreTelechargements;
  final String dateAjout;

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.cours,
    required this.userId,
    required this.auteur,
    required this.nombreTelechargements,
    required this.dateAjout,
  });

  // Factory pour convertir JSON -> Note
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      titre: json['titre'],
      contenu: json['contenu'],
      cours: json['cours'],
      auteur: json['auteur'] != null ? json['auteur']['nom'] : 'Inconnu',
      userId: json['auteur']['id'].toString(), // L'ID de l'auteur
      nombreTelechargements: json['nombreTelechargements'],
      dateAjout: json['dateAjout'] ?? '',
    );
  }

  // Formater la d

  // Convertir la date au format souhaité
  String formatDate(String dateString) {
    try {
      // Parse la date ISO 8601
      DateTime date = DateTime.parse(dateString);
      // Formate la date en dd/MM/yyyy
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Date invalide'; // Si l'analyse échoue, retournez une valeur par défaut
    }
  }
}
