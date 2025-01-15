import 'package:flutter/material.dart';
import 'package:gestionnote/pages/ajouternote.dart';
import 'package:gestionnote/pages/constants.dart';
import 'package:gestionnote/pages/cours.dart';
import 'package:gestionnote/pages/mesnotes.dart';
import 'package:gestionnote/pages/parametres.dart';
import 'package:provider/provider.dart';
import 'package:gestionnote/pages/useProvider.dart';
import 'package:gestionnote/pages/bienvenue.dart';
import 'dart:convert'; // Pour décoder les réponses JSON
import 'package:http/http.dart' as http; // Pour effectuer des requêtes HTTP
import 'note_details_screen.dart'; // Importation de la page NoteDetails

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _currentIndex = 0;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResultsNotes = [];
  List<dynamic> _searchResultsUsers = [];

  final List<Widget> _pages = [
    AccueilContent(),
    CoursesPage(),
    AddNotesPage(),
    MesnotesPage(),
  ];

  Future<void> _rechercher(String query) async {
    late Uri urlNotes;
    late Uri urlUsers;
    if (_currentIndex == 1) {
      urlNotes = Uri.parse("http://localhost:8082/api/notes/rechercherparnotes?query=$query");
    } else if (_currentIndex != 1) {
      urlUsers = Uri.parse("http://localhost:8082/api/notes/rechercherparutilisateurs?query=$query");
    } else {
      return;
    }

    try {
      if (_currentIndex == 1) {
        final responseNotes = await http.get(urlNotes);
        if (responseNotes.statusCode == 200) {
          setState(() {
            _searchResultsNotes = json.decode(responseNotes.body);
          });
        } else {
          throw Exception("Erreur : ${responseNotes.reasonPhrase}");
        }
      } else if (_currentIndex != 1) {
        final responseUsers = await http.get(urlUsers);
        if (responseUsers.statusCode == 200) {
          setState(() {
            _searchResultsUsers = json.decode(responseUsers.body);
          });
        } else {
          throw Exception("Erreur : ${responseUsers.reasonPhrase}");
        }
      }
    } catch (e) {
      print("Erreur lors de la recherche : $e");
      setState(() {
        _searchResultsNotes = [];
        _searchResultsUsers = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  border: InputBorder.none,
                ),
                onChanged: (query) => _rechercher(query),
              )
            : const Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResultsNotes = [];
                  _searchResultsUsers = [];
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
     drawer: Drawer(
  child: Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.user;
      final imagePath = user?.imagePath;

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6F35A5)),
            child: user == null
                ? const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: imagePath != null && imagePath.isNotEmpty
                            ? NetworkImage(imagePath)
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.nom} ${user.prenom}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          user == null
              ? const ListTile(
                  title: Text('Veuillez vous connecter'),
                )
              : Column(
                  children: [
                    ListTile(
                      title: Text('Email: ${user.email}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Paramètres'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParametresPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Bienvenue(),
                ),
              );
            },
          ),
        ],
      );
    },
  ),
),

      body: _isSearching
    ? SingleChildScrollView(
        child: Column(
          children: [
            if (_searchResultsNotes.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResultsNotes.length,
                itemBuilder: (context, index) {
                  final item = _searchResultsNotes[index];
                  return ListTile(
                    title: Text(item["titre"] ?? ''),
                    subtitle: Text(
                    '${item["auteur"]?["nom"] ?? ''} - ${item["contenu"] ?? ''}',
                    style: TextStyle(fontSize: 14), // Ajout d'un style optionnel si nécessaire
                  ),
                    leading: item["auteur"] != null
                        ? item["auteur"]["imagePath"] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'http://localhost:8082/${item["auteur"]["imagePath"]}'),
                                radius: 25,
                              )
                            : null
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailsScreen(
                            noteId: item["id"].toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            if (_searchResultsUsers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResultsUsers.length,
                itemBuilder: (context, index) {
                  final item = _searchResultsUsers[index];
                  return ListTile(
                    title: Text(item["nom"] ?? ''),
                    subtitle: Text(item["email"] ?? ''),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'http://localhost:8082/${item["imagePath"]}'),
                      radius: 25,
                    ),
                  );
                },
              ),
          ],
        ),
      )
    : _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: kPrimaryColor, // Couleur de la bordure
              width: 0.3, // Épaisseur de la bordure
            ),
          ),
        ),
        child: BottomNavigationBar(
          selectedFontSize: 16,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _isSearching = false;
              _searchController.clear();
              _searchResultsNotes = [];
              _searchResultsUsers = [];
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cours'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Ajouter'),
            BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          ],
        ),
      ),
    );
  }
}


class AccueilContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue sur l\'application de Partage de Notes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              FeatureCard(
                  title: '📚 Explorer les Notes',
                  description: 'Consultez les notes organisées par cours.',
                  onPressed: () {}),
              FeatureCard(
                title: '📤 Partager des Notes',
                description: 'Téléchargez vos notes pour aider les autres.',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const FeatureCard({
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(title),
            subtitle: Text(description),
          ),
          OverflowBar(
            children: [
              TextButton(
                onPressed: onPressed,
                child: Text('Voir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
