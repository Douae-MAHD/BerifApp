import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  // 🔹 Obligatoire avant toute initialisation
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Configuration Firestore (cache activé)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 🔹 Initialisation formats de date (FR)
  await initializeDateFormatting('fr_FR', null);

  // 🔍 Test Firestore (debug uniquement)
  FirebaseFirestore.instance
      .collection('travaux')
      .limit(1)
      .get()
      .then((snap) {
    print("🧪 Firestore OK → ${snap.docs.length} document(s)");
  }).catchError((e) {
    print("❌ Firestore ERROR → $e");
  });

  print("✅ Application initialisée avec succès");

  // 🔹 Lancement de l'application
  runApp(
    const ProviderScope(
      child: BerifMVPApp(),
    ),
  );
}