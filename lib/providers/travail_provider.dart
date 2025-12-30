import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/client.dart';
import '../models/suivi_travail.dart';
import '../models/type_travail.dart';
import '../services/travail_service.dart';
import '../services/technicien_service.dart';

import '../models/travail.dart';
import '../models/technicien.dart';
import '../services/type_travail_service.dart';
import 'client_provider.dart';

/// =======================
/// SERVICE PROVIDERS
/// =======================
final travailServiceProvider = Provider((ref) => TravailService());
final technicienServiceProvider = Provider((ref) => TechnicienService());

/// =======================
/// STREAMS TRAVAUX (temps réel)
/// =======================
final allTravauxProvider = StreamProvider<List<Travail>>((ref) {
  return ref.watch(travailServiceProvider).getTravaux();
});

/// Alias (compatibilité avec l’autre version)
final travauxStreamProvider = allTravauxProvider;

/// =======================
/// KPIs & COMPTEURS
/// =======================
final travailCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allTravauxProvider).whenData((list) => list.length);
});

/// Travaux "en cours" uniquement
final travauxEnCoursProvider = Provider<AsyncValue<List<Travail>>>((ref) {
  final travauxAsync = ref.watch(allTravauxProvider);
  return travauxAsync.whenData(
        (list) => list.where((t) => t.statut == 'en_cours').toList(),
  );
});

/// =======================
/// STATISTIQUES ADMIN (globales)
/// =======================
final adminStatsProvider = Provider((ref) {
  final travauxAsync = ref.watch(allTravauxProvider);

  return travauxAsync.maybeWhen(
    data: (travaux) => {
      'total': travaux.length,
      'non_assigne': travaux.where((t) => t.statut == 'non_assigne').length,
      'assigne': travaux.where((t) => t.statut == 'assigne').length,
      'termine': travaux.where((t) => t.statut == 'termine').length,
    },
    orElse: () => {
      'total': 0,
      'non_assigne': 0,
      'assigne': 0,
      'termine': 0,
    },
  );
});

/// =======================
/// STATISTIQUES MENSUELLES (Dashboard)
/// =======================
final monthlyStatsProvider = Provider((ref) {
  final travauxAsync = ref.watch(allTravauxProvider);

  return travauxAsync.maybeWhen(
    data: (travaux) {
      Map<int, Map<String, dynamic>> stats = {};

      // Initialiser les 12 mois
      for (int i = 1; i <= 12; i++) {
        stats[i] = {
          'clients': <String>{},
          'travaux': 0,
          'statut': 'termine',
        };
      }

      for (var t in travaux) {
        if (t.datePlanifiee != null) {
          int month = t.datePlanifiee!.month;

          stats[month]!['travaux']++;
          stats[month]!['clients'].add(t.clientId);

          // Statut dominant
          if (t.statut == 'non_assigne') {
            stats[month]!['statut'] = 'non_assigne';
          } else if (t.statut == 'assigne' &&
              stats[month]!['statut'] != 'non_assigne') {
            stats[month]!['statut'] = 'assigne';
          }
        }
      }

      return stats;
    },
    orElse: () => {},
  );
});

/// =======================
final typeTravailServiceProvider = Provider((ref) => TypeTravailService());

final allTypesProvider = StreamProvider<List<TypeTravail>>((ref) {
  return ref.watch(typeTravailServiceProvider).getTypes();
});

// Provider pour récupérer le dernier rapport du technicien pour un travail spécifique
// Récupère le dernier compte-rendu du technicien pour un travail précis
final dernierSuiviProvider = StreamProvider.family<SuiviTravail?, String>((ref, travailId) {
  return FirebaseFirestore.instance
      .collection('suivi_travaux')
      .where('id_travail', isEqualTo: travailId)
      .orderBy('date_suivi', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return SuiviTravail.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  });
});

// 1. État pour la barre de recherche (Texte vide par défaut)
final travailSearchQueryProvider = StateProvider<String>((ref) => "");

// 2. État pour le filtre de statut (null = tout afficher)
final travailStatusFilterProvider = StateProvider<String?>((ref) => null);

// 3. État pour le filtre par type de travail (null = tout afficher)
final travailTypeFilterProvider = StateProvider<String?>((ref) => null);

// 4. LE PROVIDER FILTRÉ (La logique magique)
// Ce provider combine les travaux, la recherche et les filtres en temps réel.
final filteredTravauxProvider = Provider<AsyncValue<List<Travail>>>((ref) {
  // On écoute la source de données brute (Firebase)
  final travauxAsync = ref.watch(allTravauxProvider);

  // On écoute les 3 états de filtres
  final searchQuery = ref.watch(travailSearchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(travailStatusFilterProvider);
  final typeFilter = ref.watch(travailTypeFilterProvider);

  // On récupère la liste des clients pour chercher par NOM du client et non par ID
  final clients = ref.watch(allClientsProvider).asData?.value ?? [];

  return travauxAsync.whenData((list) {
    return list.where((t) {
      // FILTRE 1 : Recherche par nom du client ou commentaire
      final client = clients.firstWhere(
              (c) => c.id == t.clientId,
          orElse: () => Client(id: '', nomClient: '', adresse: '', ville: '', telephone: '', email: '', typeContrat: '', periodiciteMaintenance: '', secteur: '')
      );
      final matchSearch = client.nomClient.toLowerCase().contains(searchQuery) ||
          t.commentaire.toLowerCase().contains(searchQuery);

      // FILTRE 2 : Statut (En attente, En cours, Terminé)
      final matchStatus = statusFilter == null || t.statut == statusFilter;

      // FILTRE 3 : Type de travail (Maintenance, Livraison, etc.)
      final matchType = typeFilter == null || t.typeId == typeFilter;

      // Le travail est gardé si il remplit les 3 conditions
      return matchSearch && matchStatus && matchType;
    }).toList();
  });
});