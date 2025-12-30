import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
// 1. AJOUTE CET IMPORT
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_main_layout.dart';
import 'screens/technicien/dashboard_technicien.dart';

import 'screens/admin/add_tech.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. AJOUTE CETTE LIGNE ICI (Indispensable pour le français)
  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: BerifApp(),
    ),
  );
}

class BerifApp extends StatelessWidget {
  const BerifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // 3. OPTIONNEL : Définit la locale par défaut de l'app
      locale: const Locale('fr', 'FR'),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => AdminMainLayout(),
        '/tech_dashboard': (context) => const DashboardTechnicien(),
        '/add_tech': (context) => const AddTechnicianScreen(),
      },
    );
  }
}