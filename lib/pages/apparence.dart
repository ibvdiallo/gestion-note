import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestionnote/pages/useProvider.dart';
class ApparencePage extends StatefulWidget {
  @override
  _ApparencePageState createState() => _ApparencePageState();
}

class _ApparencePageState extends State<ApparencePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apparence'),
        backgroundColor: const Color(0xFF6F35A5),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Mode Sombre'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // Vous pouvez aussi changer le thème ici si vous utilisez un Provider ou un autre gestionnaire d'état
              },
            ),
          ),
          // D'autres options pour personnaliser l'apparence peuvent être ajoutées ici
        ],
      ),
    );
  }
}
