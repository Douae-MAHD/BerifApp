import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Obligatoire pour Riverpod
import 'package:firebase_core/firebase_core.dart';       // Obligatoire pour Firebase
import 'package:intl/date_symbol_data_local.dart';       // Pour le formatage des dates en Français
import 'firebase_options.dart';                          // Généré par FlutterFire CLI
import 'app.dart';

void main() async {
  // 1. Indispensable pour initialiser les plugins avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialisation des formats de date (pour afficher "Décembre 2025")
  await initializeDateFormatting('fr_FR', null);

  // 4. Lancement de l'application enveloppée dans ProviderScope
  runApp(
    const ProviderScope(
      child: BerifMVPApp(),
    ),
  );
}