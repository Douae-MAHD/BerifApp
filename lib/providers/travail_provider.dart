import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/travail_service.dart';
import '../services/technicien_service.dart';

import '../models/travail.dart';
import '../models/technicien.dart';

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