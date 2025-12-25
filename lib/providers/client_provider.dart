import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/client_service.dart';
import '../models/client.dart';

final clientServiceProvider = Provider((ref) => ClientService());

// 1. SOURCE DE VÉRITÉ : Le mois sélectionné dans l'interface (par défaut : mois actuel)
final selectedMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

// 2. Stream de tous les clients (Source brute Firebase)
final allClientsProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientServiceProvider).getClients();
});

// 3. PROVIDER CRUCIAL : Calcule les statistiques pour chaque mois de l'année (utilisé par le Year Modal)
// Il projette les contrats de 6 et 12 mois sur le calendrier complet
final monthlyStatsProvider = Provider<Map<int, Map<String, dynamic>>>((ref) {
  final allClientsAsync = ref.watch(allClientsProvider);

  // Initialisation d'une map vide pour les 12 mois
  Map<int, Map<String, dynamic>> statsMap = {};
  for (int i = 1; i <= 12; i++) {
    statsMap[i] = {
      'clients': <String>{}, // Utilisation d'un Set pour l'unicité
      'travaux': 0,
      'statut': 'termine',
    };
  }

  return allClientsAsync.maybeWhen(
    data: (clients) {
      for (var client in clients) {
        if (client.dateDebutContrat == null) continue;

        int m1 = client.dateDebutContrat!.month;

        // --- Mois de début (Toujours présent) ---
        _addClientToStats(statsMap, m1, client.id ?? "");

        // --- Mois secondaire (Si contrat 6 mois) ---
        if (client.typeContrat.contains("6")) {
          int m2 = (m1 + 6) > 12 ? (m1 + 6) - 12 : (m1 + 6);
          _addClientToStats(statsMap, m2, client.id ?? "");
        }
      }
      return statsMap;
    },
    orElse: () => statsMap,
  );
});

// 4. Provider pour obtenir la liste des clients du mois sélectionné
// (Utilisé par le Dashboard pour afficher les cartes)
final clientsDueForMonthProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final allClientsAsync = ref.watch(allClientsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  return allClientsAsync.whenData((clients) {
    return clients.where((client) {
      if (client.dateDebutContrat == null) return false;

      final m1 = client.dateDebutContrat!.month;
      if (client.typeContrat.contains("12")) {
        return selectedMonth == m1;
      } else if (client.typeContrat.contains("6")) {
        final m2 = (m1 + 6) > 12 ? (m1 + 6) - 12 : (m1 + 6);
        return selectedMonth == m1 || selectedMonth == m2;
      }
      return false;
    }).toList();
  });
});

// 5. Provider pour les tuiles de statistiques du Dashboard (Total, Non assigné...)
final statsForSelectedMonthProvider = Provider((ref) {
  final clientsAsync = ref.watch(clientsDueForMonthProvider);

  return clientsAsync.maybeWhen(
    data: (clients) => {
      'total': clients.length,
      'non_assigne': clients.length, // À croiser plus tard avec la collection Travaux
      'assigne': 0,
      'termine': 0,
    },
    orElse: () => {'total': 0, 'non_assigne': 0, 'assigne': 0, 'termine': 0},
  );
});

// --- KPI GÉNÉRAUX ET RECHERCHE ---

final clientCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allClientsProvider).whenData((list) => list.length);
});

final clientSearchProvider = StateProvider<String>((ref) => "");

final filteredClientsProvider = Provider<List<Client>>((ref) {
  final allClientsAsync = ref.watch(allClientsProvider);
  final searchQuery = ref.watch(clientSearchProvider).toLowerCase();

  return allClientsAsync.maybeWhen(
    data: (clients) {
      return clients.where((client) {
        return client.nomClient.toLowerCase().contains(searchQuery) ||
            client.ville.toLowerCase().contains(searchQuery);
      }).toList();
    },
    orElse: () => [],
  );
});

// Fonction utilitaire pour remplir la map globale
void _addClientToStats(Map<int, Map<String, dynamic>> map, int month, String clientId) {
  (map[month]!['clients'] as Set<String>).add(clientId);
  map[month]!['travaux']++;
  // Logique de statut simplifiée : si un client est ajouté, on considère qu'il y a du travail
  map[month]!['statut'] = 'non_assigne';
}