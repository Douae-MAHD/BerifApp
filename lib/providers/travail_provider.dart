import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/travail_service.dart';
import '../models/travail.dart';

final travailServiceProvider = Provider((ref) => TravailService());

// Stream de tous les travaux
final allTravauxProvider = StreamProvider<List<Travail>>((ref) {
  return ref.watch(travailServiceProvider).getTravaux();
});

// Provider pour le compteur simple (utilisé dans KPI Grid)
final travailCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allTravauxProvider).whenData((list) => list.length);
});

// Provider de calcul des statistiques pour le widget AdminMonthStats
final adminStatsProvider = Provider((ref) {
  final travauxAsync = ref.watch(allTravauxProvider);

  return travauxAsync.maybeWhen(
    data: (travaux) => {
      'total': travaux.length,
      'non_assigne': travaux.where((t) => t.statut == 'non_assigne').length,
      'assigne': travaux.where((t) => t.statut == 'assigne').length,
      'termine': travaux.where((t) => t.statut == 'termine').length,
    },
    orElse: () => {'total': 0, 'non_assigne': 0, 'assigne': 0, 'termine': 0},
  );
});

final monthlyStatsProvider = Provider((ref) {
  final travauxAsync = ref.watch(allTravauxProvider);

  return travauxAsync.maybeWhen(
    data: (travaux) {
      Map<int, Map<String, dynamic>> stats = {};

      // Initialiser les 12 mois
      for (int i = 1; i <= 12; i++) {
        stats[i] = {'clients': <String>{}, 'travaux': 0, 'statut': 'termine'};
      }

      for (var t in travaux) {
        if (t.datePlanifiee != null) {
          int month = t.datePlanifiee!.month;

          // Compter les travaux
          stats[month]!['travaux']++;

          // Ajouter le client au Set (pour avoir l'unicité)
          stats[month]!['clients'].add(t.clientId);

          // Déterminer le statut dominant du mois
          // Si un seul travail est "non_assigne", le mois devient rouge
          if (t.statut == 'non_assigne') {
            stats[month]!['statut'] = 'non_assigne';
          } else if (t.statut == 'assigne' && stats[month]!['statut'] != 'non_assigne') {
            stats[month]!['statut'] = 'assigne';
          }
        }
      }
      return stats;
    },
    orElse: () => {},
  );
});