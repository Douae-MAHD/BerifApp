import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/client.dart';
import 'models/equipe.dart';
import 'models/technicien.dart';
import 'models/travail.dart';
import 'models/suivi_travail.dart';

import 'services/client_service.dart';
import 'services/equipe_service.dart';
import 'services/technicien_service.dart';
import 'services/travail_service.dart';
import 'services/suivi_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Android OK
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestGlobalScreen(),
    );
  }
}

class TestGlobalScreen extends StatelessWidget {
  const TestGlobalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientService = ClientService();
    final equipeService = EquipeService();
    final technicienService = TechnicienService();
    final travailService = TravailService();
    final suiviService = SuiviTravailService();

    return Scaffold(
      appBar: AppBar(title: const Text('Test Global Firebase')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Tester TOUS les models'),
          onPressed: () async {
            /// 🔹 CLIENT
            final client = Client(
              id: null,
              nomClient: 'Client Global',
              adresse: 'Rue Test',
              ville: 'Rabat',
              telephone: '0600000000',
              email: 'global@test.com',
              typeContrat: 'Annuel',
              periodiciteMaintenance: 'Mensuelle',
              secteur: 'Industrie',
            );

            final clientId = await clientService.addClient(client);
            debugPrint('✅ Client créé : $clientId');

            /// 🔹 EQUIPE
            final equipe = Equipe(
              id: null,
              nomEquipe: 'Equipe Globale',
              disponibilite: true,
            );

            final equipeId = await equipeService.addEquipe(equipe);
            debugPrint('✅ Équipe créée : $equipeId');

            /// 🔹 TECHNICIEN
            final technicien = Technicien(
              id: null,
              utilisateurId: 'user_test',
              nom: 'Ali',
              prenom: 'Hassan',
              telephone: '0611111111',
              specialite: 'Réseau',
            );

            await technicienService.addTechnicien(technicien);
            debugPrint('✅ Technicien créé');

            /// 🔹 TRAVAIL
            final travail = Travail(
              id: null,
              clientId: clientId,
              equipeId: equipeId,
              typeId: 'type_test',
              commentaire: 'Installation',
              statut: 'en_attente',
              datePlanifiee: DateTime.now(),
            );

            final travailId = await travailService.addTravail(travail);
            debugPrint('✅ Travail créé : $travailId');

            /// 🔹 SUIVI TRAVAIL
            final suivi = SuiviTravail(
              id: null,
              travailId: travailId,
              equipeId: equipeId,
              commentaire: 'Début des travaux',
              dateSuivi: DateTime.now(),
            );

            await suiviService.addSuivi(suivi);
            debugPrint('✅ Suivi créé');
          },
        ),
      ),
    );
  }
}
