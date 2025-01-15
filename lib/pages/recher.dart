import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RechercherParUtilisateurPage extends StatefulWidget {
  final String query;

  RechercherParUtilisateurPage({required this.query});

  @override
  _RechercherParUtilisateurPageState createState() =>
      _RechercherParUtilisateurPageState();
}

class _RechercherParUtilisateurPageState
    extends State<RechercherParUtilisateurPage> {
  late List<dynamic> _searchResults;

  @override
  void initState() {
    super.initState();
    _rechercherUtilisateur(widget.query);
  }

  Future<void> _rechercherUtilisateur(String query) async {
    Uri url = Uri.parse("http://localhost:8082/api/notes/rechercherparutilisateurs?query=$query");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      } else {
        throw Exception("Erreur : ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Erreur lors de la recherche : $e");
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats de la recherche'),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final utilisateur = _searchResults[index];
          return ListTile(
            leading: utilisateur["imagePath"] != null && utilisateur["imagePath"].isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                        'http://localhost:8082${utilisateur["imagePath"]}'),
                  )
                : null,
            title: Text('${utilisateur["nom"]} ${utilisateur["prenom"]}'),
            subtitle: Text(utilisateur["email"]),
          );
        },
      ),
    );
  }
}
