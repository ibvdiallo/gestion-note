import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestionnote/pages/inforperso.dart';
import 'package:gestionnote/pages/infosApp.dart';
import 'package:gestionnote/pages/langue.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestionnote/pages/useProvider.dart';
import 'dart:convert'; // Pour la gestion de JSON
import 'package:flutter/material.dart';
import 'package:gestionnote/pages/apparence.dart';
import 'package:gestionnote/pages/inscription.dart'; // Import de la page d'inscription
import 'package:gestionnote/pages/acceuil.dart'; // Import de la page d'accueil
import 'package:gestionnote/pages/useProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; 
class ParametresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF6F35A5),
      ),
      body: ListView(
        children: [
          // Informations personnelles
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Informations personnelles'),
            onTap: () {
              // Action pour afficher/modifier les informations personnelles
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InformationsPersonnellesPage(),
                ),
              );
            },
          ),
          const Divider(),

          // Apparence
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Apparence'),
            onTap: () {
              // Action pour modifier l'apparence
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApparencePage(),
                ),
              );
            },
          ),
          const Divider(),

          // Langues
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langues'),
            onTap: () {
              // Action pour modifier la langue
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguesPage(),
                ),
              );
            },
          ),
          const Divider(),

          // Infos App
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Infos App'),
            onTap: () {
              // Action pour afficher les informations de l'application
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfosAppPage(),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
