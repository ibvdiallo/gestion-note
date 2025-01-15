import 'package:flutter/material.dart';
import 'package:gestionnote/pages/useProvider.dart'; // Importation du UserProvider
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class MesnotesPage extends StatelessWidget {
  // Méthode pour récupérer les notes partagées avec l'utilisateur
  Future<List<Map<String, dynamic>>> fetchNotesPartagees(String userId) async {
    final response = await http.get(Uri.parse('http://localhost:8082/api/notes/$userId/partagees'));
    if (response.statusCode == 200) {
      List<dynamic> notesJson = json.decode(response.body);
      return notesJson.cast<Map<String, dynamic>>().toList();
    } else {
      throw Exception('Échec de la récupération des notes partagées');
    }
  }

  // Méthode pour récupérer les notes que l'utilisateur a ajoutées
  Future<List<Map<String, dynamic>>> fetchNotesAjoutes(String userId) async {
    final response = await http.get(Uri.parse('http://localhost:8082/api/notes'));
    if (response.statusCode == 200) {
      List<dynamic> notesJson = json.decode(response.body);
      return notesJson
          .where((note) =>
              note['auteur'] != null &&
              note['auteur']['id'].toString() == userId)
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception('Échec de la récupération des notes ajoutées');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final utilisateurConnecte = userProvider.user;

    if (utilisateurConnecte == null) {
      return Center(
        child: Text('Veuillez vous connecter pour voir vos notes.',
            style: TextStyle(fontSize: 16)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchNotesPartagees(utilisateurConnecte.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucune note partagée.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            List<Map<String, dynamic>> notesPartagees = snapshot.data!;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchNotesAjoutes(utilisateurConnecte.id),
              builder: (context, ajoutsSnapshot) {
                if (ajoutsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (ajoutsSnapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${ajoutsSnapshot.error}'),
                  );
                } else if (!ajoutsSnapshot.hasData || ajoutsSnapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune note ajoutée.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                } else {
                  List<Map<String, dynamic>> notesAjoutes = ajoutsSnapshot.data!;

                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      if (notesPartagees.isNotEmpty) ...[
                        Text(
                          'Notes Partagées',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...notesPartagees.map((note) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              color: Colors.grey[200],
                              child: ListTile(
                                title: Text(
                                  note['titre'] ?? 'Titre indisponible',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(note['contenu'] ?? ''),
                                    Text(
                                      note['cours'] ?? '',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (note['sharedBy']?['nom'] != null)
                                      Text(
                                        'Partagé par ${note['sharedBy']['nom']}',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                      if (notesAjoutes.isNotEmpty) ...[
                        Text(
                          'Mes Notes Ajoutées',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...notesAjoutes.map((note) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                  note['titre'] ?? 'Titre indisponible',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(note['contenu'] ?? ''),
                                    Text(
                                      note['cours'] ?? '',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
