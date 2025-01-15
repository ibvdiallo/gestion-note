import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestionnote/pages/useProvider.dart'; // Importez votre UserProvider

class AddNotesPage extends StatefulWidget {
  @override
  _AddNotesPageState createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCourse = 'Math';

  Future<void> _submitNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      // Afficher un message d'erreur si certains champs sont vides
      return;
    }

    // Récupérer l'utilisateur connecté depuis le UserProvider
    String? authorId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (authorId == null) {
      // Si l'utilisateur n'est pas connecté, afficher un message d'erreur
      print('Erreur: utilisateur non connecté');
      return;
    }

    // Formater les données à envoyer
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:8082/api/notes/ajouter'));
    request.fields['titre'] = _titleController.text;
    request.fields['contenu'] = _contentController.text;
    request.fields['cours'] = _selectedCourse;
    request.fields['auteurId'] = authorId;  // Utilisation de l'ID de l'utilisateur connecté

    try {
      // Envoyer la requête
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = json.decode(responseBody);
        print('Réponse du serveur: $responseJson');
        // Vous pouvez afficher un message de succès ou faire une autre action
      } else {
        print('Erreur lors de l\'envoi de la requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedCourse,
              items: ['Math', 'Physique', 'Informatique']
                  .map((course) =>
                      DropdownMenuItem(value: course, child: Text(course)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Cours',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitNote,
              child: Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}
