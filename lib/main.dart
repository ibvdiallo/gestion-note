import 'package:flutter/material.dart';
import 'package:gestionnote/pages/acceuil.dart';
import 'package:gestionnote/pages/inscription.dart';
import 'package:provider/provider.dart'; // Importez le package provider
import 'package:gestionnote/pages/bienvenue.dart'; // Importez la page Bienvenue
import 'package:gestionnote/pages/constants.dart';
import 'package:gestionnote/pages/useProvider.dart'; // Importez le UserProvider

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => UserProvider(), 
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connexion',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AccueilPage(),
    );
  }
}
