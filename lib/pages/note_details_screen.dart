import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'useProvider.dart';

class NoteDetailsScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailsScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  _NoteDetailsScreenState createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments(widget.noteId);
  }

  Future<Map<String, dynamic>> _fetchNoteDetails(String noteId) async {
    final response =
        await http.get(Uri.parse('http://localhost:8082/api/notes/un/$noteId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la récupération des détails de la note');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchComments(String noteId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8082/api/commentaires/note/$noteId'));
    if (response.statusCode == 200) {
      final List<dynamic> comments = json.decode(response.body);
      return comments.isEmpty ? [] : List<Map<String, dynamic>>.from(comments);
    } else {
      print('Erreur HTTP: ${response.statusCode} - ${response.body}');
      throw Exception('Échec de la récupération des commentaires');
    }
  }

  Future<void> _addComment(
      BuildContext context, String noteId, String comment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final utilisateurConnecte = userProvider.user;

    if (utilisateurConnecte == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8082/api/commentaires'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contenu': comment,
        'utilisateur': {'id': utilisateurConnecte.id},
        'note': {'id': noteId},
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté avec succès')),
      );

      setState(() {
        _commentsFuture = _fetchComments(noteId);
      });

      _commentController.clear();
    } else {
      print("Erreur lors de l'ajout du commentaire : ${response.body}");
    }
  }

  String constructImageUrl(String? imagePath) {
    const String baseUrl = 'http://localhost:8082/';
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    return imagePath.startsWith('http') ? imagePath : '$baseUrl$imagePath';
  }

  Widget buildNoteDetails(Map<String, dynamic> noteData) {
    String title = noteData['titre'] ?? 'Titre non disponible';
    String description = noteData['contenu'] ?? 'Description non disponible';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 16)),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
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
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  if (_commentController.text.trim().isEmpty) {
                    print("Le commentaire est vide !");
                    return;
                  }
                  _addComment(
                      context, widget.noteId, _commentController.text.trim());
                },
              ),
            ],
          ),
          const Divider(),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Erreur de récupération des commentaires'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('Aucun commentaire disponible'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data![index];
                    String username =
                        comment['utilisateur']['nom'] ?? 'Utilisateur inconnu';
                    String date = comment['dateCreation'] ?? 'Date inconnue';
                    String content = comment['contenu'] ?? 'Aucun contenu';
                    String imageUrl = constructImageUrl(
                        comment['utilisateur']['imagePath']?.toString());

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/avatar_placeholder.png')
                                as ImageProvider,
                      ),
                      title: Text(username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text(content),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la Note')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchNoteDetails(widget.noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de récupération des détails'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          } else {
            return buildNoteDetails(snapshot.data!);
          }
        },
      ),
    );
  }
}
