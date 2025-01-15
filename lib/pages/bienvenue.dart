import 'dart:convert'; // Pour la gestion de JSON
import 'package:flutter/material.dart';
import 'package:gestionnote/pages/constants.dart';
import 'package:gestionnote/pages/inscription.dart'; // Import de la page d'inscription
import 'package:gestionnote/pages/acceuil.dart'; // Import de la page d'accueil
import 'package:gestionnote/pages/useProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import du modèle d'état

class Bienvenue extends StatefulWidget {
  const Bienvenue({Key? key}) : super(key: key);

  @override
  State<Bienvenue> createState() => _BienvenueState();
}

class _BienvenueState extends State<Bienvenue> {
  bool _obscurePassword = true; // Contrôle pour afficher/masquer le mot de passe
  bool _isLoading = false; // Variable pour indiquer si le chargement est en cours
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // URL de votre API Spring
  final String apiUrl = "http://localhost:8082/api/utilisateurs/login"; // Remplacez avec l'URL de votre API Spring

  // Fonction pour effectuer la requête de connexion
  Future<void> _login() async {
  final String email = _emailController.text;
  final String motDePasse = _passwordController.text;

  setState(() {
    _isLoading = true; // Début du chargement
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "motDePasse": motDePasse}),
    );

    setState(() {
      _isLoading = false; // Fin du chargement
    });

    if (response.statusCode == 200) {
      // Connexion réussie, récupérer les informations de l'utilisateur
      final responseData = json.decode(response.body); // Décodage de la réponse JSON
      final String id = responseData['id'].toString(); // Conversion de l'id en String
      final String email = responseData['email'];
    
      // Stocker l'utilisateur dans le UserProvider
      Provider.of<UserProvider>(context, listen: false).login(email, motDePasse); // Utiliser email et motDePasse ici

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AccueilPage()), // Redirection vers la page d'accueil
      );
    } else {
      // Si la réponse de l'API n'est pas réussie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion, vérifiez vos informations.")),
      );
    }
  } catch (e) {
    // Gestion des erreurs
    setState(() {
      _isLoading = false; // Fin du chargement en cas d'erreur
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur de connexion. Veuillez réessayer.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 120,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(height: defaultPadding),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Veuillez Vous connecter ! ",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  // Formulaire de connexion
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(defaultPadding),
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscurePassword, // Gère l'affichage du texte
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            hintText: "Mot de pass",
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(defaultPadding),
                              child: Icon(Icons.lock),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        // Si le chargement est en cours, afficher l'indicateur de chargement
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login, // Appel de la fonction de connexion
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 32),
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Connecter".toUpperCase(),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  // Texte pour rediriger vers la page d'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous avez pas de Compte ?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Inscription(); // Page d'inscription
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "S'Inscrire",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
