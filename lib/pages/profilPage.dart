import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilPage extends StatelessWidget {
  final String userId;

  ProfilPage({required this.userId});

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await http.get(
        Uri.parse('http://localhost:8082/api/utilisateurs/$userId/profil'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Impossible de charger le profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil de l\'utilisateur'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else {
            final profil = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 🎨 En-tête avec Image de Profil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              'http://localhost:8082/${profil['imageProfil']!}'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${profil['prenom']} ${profil['nom']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📊 Détails du Profil
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.email, color: Colors.deepPurple),
                          title: Text('Email : ${profil['email']}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.library_books,
                              color: Colors.deepPurple),
                          title: Text(
                              'Nombre de notes ajoutées : ${profil['nombreNotes']}'),
                          trailing: SizedBox(
                            width:
                                100, // ✅ Limite la taille du bouton pour éviter l'erreur
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NotesUtilisateurPage(userId: userId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Voir',
                                  style: TextStyle(fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// 📄 Page des Notes de l'Utilisateur
class NotesUtilisateurPage extends StatelessWidget {
  final String userId;

  NotesUtilisateurPage({required this.userId});

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final response = await http.get(
        Uri.parse('http://localhost:8082/api/notes/utilisateur/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else if (response.statusCode == 204) {
      return []; // Aucune note à afficher
    } else {
      throw Exception('Erreur de récupération des notes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune note trouvée'));
          } else if (snapshot.hasData) {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['titre']),
                  subtitle: Text(note['contenu']),
                  trailing: Text(note['dateAjout']),
                );
              },
            );
          } else {
            return const Center(child: Text('Aucune note trouvée'));
          }
        },
      ),
    );
  }
}
