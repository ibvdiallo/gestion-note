import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gestionnote/pages/bienvenue.dart';
import 'package:gestionnote/pages/constants.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class Inscription extends StatefulWidget {
  const Inscription({Key? key}) : super(key: key);

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  File? _image;

  Future<void> pickImage() async {
  // Demander les permissions de la caméra et de la bibliothèque de photos
  await Permission.camera.request();
  await Permission.photos.request();

  // Utilisation de image_picker pour sélectionner une image
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Charger l'image
    File originalImage = File(pickedFile.path);

    // Lire l'image en tant que bytes
    List<int> imageBytes = await originalImage.readAsBytes();

    // Décoder l'image
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

    // Si l'image est valide, compresser
    if (image != null) {
      // Redimensionner (facultatif) et compresser l'image
      img.Image compressedImage = img.copyResize(image, width: 800); // Redimensionner à une largeur de 800px
      List<int> compressedBytes = img.encodeJpg(compressedImage, quality: 85); // Compression de qualité 85%

      // Sauvegarder l'image compressée
      File compressedFile = await File(pickedFile.path).writeAsBytes(compressedBytes);

      // Mettre à jour l'état avec l'image compressée
      setState(() {
        _image = compressedFile;
      });
    }
  }
}

  // Méthode pour envoyer les données d'inscription
  Future<void> registerUser(BuildContext context, String lastName, String firstName, String email, String password, File? image) async {
  var uri = Uri.parse('http://localhost:8082/api/utilisateurs/inscription'); // URL de l'API Spring Boot
  var request = http.MultipartRequest('POST', uri);

  // Ajout des champs utilisateur
  request.fields['utilisateur'] = jsonEncode({
    'nom': lastName,       // Nom de famille
    'prenom': firstName,   // Prénom
    'email': email,
    'motDePasse': password, // Mot de passe
  });

  // Ajout de l'image si elle existe
  if (image != null) {
    var imageFile = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(imageFile);
  }

  // Affichage d'un indicateur de chargement pendant l'inscription
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(), // Affiche un indicateur de chargement
      );
    },
  );

  try {
    // Envoi de la requête
    var response = await request.send();

    // Masquer le dialogue de chargement
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      print("Inscription réussie !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inscription réussie !")),
      );

      // Redirection vers la page de bienvenue après un délai
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bienvenue()),
        );
      });
    } else {
      // Lire le contenu de la réponse pour obtenir plus de détails sur l'erreur
      String responseBody = await response.stream.bytesToString();
      print("Erreur lors de l'inscription : ${response.statusCode}");
      print("Détails de l'erreur : $responseBody");

      // Affichage d'un message d'erreur avec un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'inscription : ${response.statusCode}")),
      );
    }
  } catch (e) {
    // Si une erreur se produit, masquez le loader et afficher un message d'erreur
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Une erreur est survenue, veuillez réessayer.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Nom
                TextFormField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                    hintText: "Your last name",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                    hintText: "Your first name",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                    hintText: "Your email",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.email),
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: _obscurePassword,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Your password",
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

                // Confirmer mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  obscureText: _obscureConfirmPassword,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.lock),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),

                // Sélectionner une image
                 // Sélectionner une image
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text("Select Profile Picture"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),

              // Affichage de l'image sélectionnée
              if (_image != null)
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(
                    _image!,
                    width: 50,  // ajustez la largeur
                    height: 50, // ajustez la hauteur
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: defaultPadding * 2),

                // Bouton Sign Up
                ElevatedButton(
                  onPressed: () {
                    if (_passwordController.text == _confirmPasswordController.text) {
                      registerUser(
                        context,
                        _lastNameController.text,
                        _firstNameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _image,
                      );
                    } else {
                      print("Les mots de passe ne correspondent pas");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Sign Up".toUpperCase(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
