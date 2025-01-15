import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteDetailsScreen extends StatefulWidget {
  final int noteId;

  NoteDetailsScreen({required this.noteId});

  @override
  _NoteDetailsScreen createState() => _NoteDetailsScreen();
}

class _NoteDetailsScreen extends State<NoteDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();

 Future<Map<String, dynamic>> _fetchNoteDetails(int noteId) async {
  final response = await http.get(Uri.parse('http://localhost:8082/api/notes/un/$noteId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Échec de la récupération des détails de la note');
  }
}


  Widget buildFilePreview(String? fileUrl) {
    if (fileUrl == null) {
      return const Center(child: Text('Aperçu non disponible'));
    }

    String fileExtension = fileUrl.split('.').last.toLowerCase();

    if (fileExtension == 'txt') {
      return FutureBuilder<String>(
        future: http.read(Uri.parse(fileUrl)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur de lecture du fichier texte'));
          } else {
            return Container(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Text(
                  snapshot.data ?? '',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }
        },
      );
    } else if (fileExtension == 'pdf') {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text('Voir le PDF', style: TextStyle(color: Colors.black)),
          ],
        ),
      );
    } else if (fileExtension == 'jpg' || fileExtension == 'png') {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(fileUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return const Center(child: Text('Aperçu non disponible'));
    }
  }

  Future<void> _addComment(String noteId, String comment) async {
    final response = await http.post(
      Uri.parse('http://localhost:8082/api/commentaires'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contenu': comment,
        'note': {'id': noteId},
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commentaire ajouté avec succès!')),
      );
    } else {
      throw Exception('Erreur lors de l\'ajout du commentaire');
    }
  }

  Widget buildNoteDetails(Map<String, dynamic> noteData) {
    String title = noteData['title'] ?? 'Titre non disponible';
    String description = noteData['description'] ?? 'Description non disponible';
    String imageUrl = noteData['image'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(description, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        buildFilePreview(imageUrl),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Écrire un commentaire...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  _addComment('${widget.noteId + 1}', _commentController.text);
                },
              ),
            ],
          ),
        ),
        Divider(),
        // Gestion de l'affichage des commentaires
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Note ${widget.noteId + 1}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchNoteDetails(widget.noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur de récupération des détails'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          } else {
            final noteData = snapshot.data!;
            return buildNoteDetails(noteData);
          }
        },
      ),
    );
  }
}
