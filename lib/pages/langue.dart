import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestionnote/pages/useProvider.dart';
class LanguesPage extends StatefulWidget {
  @override
  _LanguesPageState createState() => _LanguesPageState();
}

class _LanguesPageState extends State<LanguesPage> {
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langues'),
        backgroundColor: const Color(0xFF6F35A5),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Français'),
            trailing: Radio<String>(
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                // Mettez ici le code pour changer la langue de l'application
              },
            ),
          ),
          ListTile(
            title: const Text('English'),
            trailing: Radio<String>(
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                // Mettez ici le code pour changer la langue de l'application
              },
            ),
          ),
          // Ajoutez d'autres options de langue ici si nécessaire
        ],
      ),
    );
  }
}
