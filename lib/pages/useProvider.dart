import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _errorMessage = '';

  User? get user => _user;
  String get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://localhost:8082/api/utilisateurs/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'motDePasse': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      
      final imagePath = data['imagePath'];

      _user = User(
         id: data['id'].toString(), 
        nom: data['nom'],
        prenom: data['prenom'],
        email: data['email'],
        imagePath: imagePath, 
      );

      _errorMessage = '';
      notifyListeners();
    } else {
      _errorMessage = 'Identifiants incorrects';
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _errorMessage = '';
    notifyListeners();
  }
}
