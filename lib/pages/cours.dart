import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestionnote/pages/profilPage.dart';
import 'package:gestionnote/pages/useProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'note.dart'; // Assurez-vous d'importer votre modèle Note
import 'package:gestionnote/pages/note_details_screen.dart';
import 'package:path_provider/path_provider.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  TextEditingController _commentController = TextEditingController();

  Map<String, TextEditingController> _commentControllers = {};

  Future<List<Note>> _fetchNotes() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.118:8082/api/notes'));
    //http.get(Uri.parse('http://localhost:8082/api/notes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((noteJson) {
        return Note.fromJson(noteJson);
      }).toList();
    } else {
      throw Exception('Échec de la récupération des notes');
    }
  }

  Future<String?> _fetchUserImage(String userId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8082/api/utilisateurs/$userId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> userJson = json.decode(response.body);
      return userJson[
          'imagePath']; // Supposons que l'image de l'utilisateur est dans le champ 'imagePath'
    } else {
      throw Exception(
          'Erreur de récupération des informations de l\'utilisateur');
    }
  }

  // Fonction pour ajouter un commentaire

  Future<void> _addComment(
      BuildContext context, String noteId, String comment) async {
    // Récupération de l'utilisateur connecté via le UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final utilisateurConnecte = userProvider.user;

    if (utilisateurConnecte == null) {
      // Si aucun utilisateur connecté, afficher un message ou effectuer une autre action
      print("Aucun utilisateur connecté !");
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8082/api/commentaires'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contenu': comment,
        'utilisateur': {
          'id': utilisateurConnecte
              .id, // Utilisation de l'ID de l'utilisateur connecté
        },
        'note': {
          'id': noteId, // ID de la note
        },
      }),
    );

    if (response.statusCode == 200) {
      print("Commentaire ajouté avec succès !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commentaire Ajoute avec succès')),
      );
    } else {
      print("Erreur lors de l'ajout du commentaire : ${response.body}");
    }
  }

  Future<void> _shareNoteWithUser(String noteId, String userId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8082/api/notes/$noteId/partager/$userId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note partagée avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du partage de la note')),
      );
    }
  }

  Future<List<Map<String, String>>> _fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://localhost:8082/api/utilisateurs'));
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((dynamic user) {
        // Cast user as dynamic for explicit type handling
        return {
          'id': user['id'].toString(),
          'nom': "${user['prenom']} ${user['nom']}",
          'imagePath': user['imagePath']?.toString() ??
              '', // Assure-toi que l'imagePath est converti correctement en String
        };
      }).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  void _showSharePopup(String noteId) {
    List<Map<String, String>> selectedUsers =
        []; // Liste pour les utilisateurs sélectionnés

    // Récupère les utilisateurs une fois avant d'afficher le popup
    _fetchUsers().then((users) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(
                  maxHeight: 400), // Limite la hauteur du dialogue
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partager la note',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isSelected = selectedUsers.contains(user);

                            return ListTile(
                              leading: user['imagePath'] != null &&
                                      user['imagePath']!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          'http://localhost:8082/${user['imagePath']!}'),
                                    )
                                  : null,
                              title: Text(
                                user['nom']!,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              tileColor: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedUsers.remove(user);
                                  } else {
                                    selectedUsers.add(user);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      if (selectedUsers
                          .isNotEmpty) // Affiche le bouton si au moins 1 utilisateur est sélectionné
                        ElevatedButton(
                          onPressed: () {
                            for (var user in selectedUsers) {
                              _shareNoteWithUser(noteId, user['id']!);
                            }
                            Navigator.pop(
                                context); // Ferme le popup après partage
                          },
                          child: Text('Partager (${selectedUsers.length})'),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(
                            context), // Annuler et fermer le popup
                        child: Text('Annuler'),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Impossible de charger les utilisateurs : $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> telechargerNote(String noteId, String noteTitre) async {
    final url =
        Uri.parse("http://localhost:8082/api/notes/$noteId/telecharger");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$noteTitre.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print("Note téléchargée : $filePath");
      } else {
        throw Exception(
            "Erreur lors du téléchargement : ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception : $e");
      throw Exception("Erreur lors du téléchargement : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Note>>(
        future: _fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Aucune note disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                // Créer un TextEditingController pour chaque note si non existant
                if (!_commentControllers.containsKey(note.id)) {
                  _commentControllers[note.id] = TextEditingController();
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 8, // Shadow to create depth
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: _fetchUserImage(note.userId),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (userSnapshot.hasError) {
                              return const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.person, color: Colors.white),
                              );
                            } else if (userSnapshot.hasData) {
                              String? imagePath = userSnapshot.data;
                              return ListTile(
                                tileColor: Colors
                                    .deepPurple[50], // Subtle background color
                                leading: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfilPage(userId: note.userId),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: imagePath != null
                                        ? NetworkImage(imagePath)
                                        : null,
                                    child: imagePath == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                ),
                                title: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfilPage(userId: note.userId),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    note.auteur,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  'Publié le ${note.dateAjout} \n${note.titre}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) async {
                                    if (value == 'Partager') {
                                      _showSharePopup(note.id.toString());
                                    } else if (value == 'Télécharger') {
                                      try {
                                        await telechargerNote(
                                            note.id.toString(), note.titre);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "La note '${note.titre}' a été téléchargée avec succès !")),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Erreur lors du téléchargement : $e")),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Partager',
                                      child: ListTile(
                                        leading: Icon(Icons.share),
                                        title: Text('Partager'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Télécharger',
                                      child: ListTile(
                                        leading: Icon(Icons.download),
                                        title: Text('Télécharger'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NoteDetailsScreen(noteId: note.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            child: Text(note.contenu,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentControllers[note.id],
                                  decoration: InputDecoration(
                                    hintText: 'Écrire un commentaire...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.send, color: Colors.blue),
                                onPressed: () {
                                  String comment =
                                      _commentControllers[note.id]?.text ?? '';
                                  if (comment.isNotEmpty) {
                                    _addComment(context, note.id, comment);
                                    // Ajouter le commentaire
                                    _commentControllers[note.id]?.clear();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Le commentaire ne peut pas être vide')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
