import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'package:berif_app/core/theme/app_theme.dart';
import 'package:berif_app/screens/technicien/dashboard_technicien.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des formats de date (FR)
  await initializeDateFormatting('fr_FR', null);

  // Initialisation Firebase (OBLIGATOIRE avant tout Firestore)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuration Firestore (optionnelle mais propre)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 🔍 Test rapide Firestore (DEBUG)
  FirebaseFirestore.instance
      .collection('travaux')
      .limit(1)
      .get()
      .then((snap) {
    print("🧪 Firestore OK → ${snap.docs.length} document(s)");
  }).catchError((e) {
    print("❌ Firestore ERROR → $e");
  });

  print("✅ Firebase & Firestore initialisés");

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechWork Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const DashboardTechnicien(),
    );
  }
}
