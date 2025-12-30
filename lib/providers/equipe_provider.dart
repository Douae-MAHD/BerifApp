import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import des Services
import '../services/equipe_service.dart';
import '../services/affectation_service.dart';
import '../services/technicien_service.dart';

// Import des Modèles
import '../models/equipe.dart';
import '../models/affectation.dart';
import '../models/technicien.dart';

/// ===========================================================================
/// 1. SERVICE PROVIDERS
/// ===========================================================================

final equipeServiceProvider = Provider((ref) => EquipeService());
final affectationServiceProvider = Provider((ref) => AffectationService());
final technicienServiceProvider = Provider((ref) => TechnicienService());

/// ===========================================================================
/// 2. STREAMS DE BASE (Temps réel depuis Firestore)
/// ===========================================================================

// Stream de toutes les équipes
final allEquipesProvider = StreamProvider<List<Equipe>>((ref) {
  return ref.watch(equipeServiceProvider).getEquipes();
});

// Stream de tous les techniciens (nécessaire pour mapper les noms dans les équipes)
final allTechniciensProvider = StreamProvider<List<Technicien>>((ref) {
  return ref.watch(technicienServiceProvider).getTechniciens();
});

/// ===========================================================================
/// 3. PROVIDERS DE RELATIONS (Le coeur de la logique membres/équipes)
/// ===========================================================================

/// 👥 Provider pour récupérer la liste réelle des techniciens d'une équipe précise.
/// Il écoute les affectations de l'équipe et cherche les techniciens correspondants.
final membresEquipeProvider = StreamProvider.family<List<Technicien>, String>((ref, equipeId) {
  // A. On écoute les affectations (liens equipe <-> technicien) pour cette équipe
  final affectationsStream = ref.watch(affectationServiceProvider).getAffectationsByEquipe(equipeId);

  // B. On écoute la liste complète des techniciens
  final allTechsAsync = ref.watch(allTechniciensProvider);

  return affectationsStream.map((affectations) {
    // Si les techniciens ne sont pas encore chargés, on renvoie une liste vide
    final allTechs = allTechsAsync.asData?.value ?? [];

    // On extrait les IDs des techniciens présents dans les affectations
    final idsInEquipe = affectations.map((a) => a.technicienId).toSet();

    // On retourne les objets Technicien complets dont l'ID est dans l'équipe
    return allTechs.where((t) => idsInEquipe.contains(t.id)).toList();
  });
});

/// 🔍 Provider pour savoir à quelle équipe appartient un technicien spécifique
/// (Utile pour le Dashboard Technicien)
final equipeDuTechnicienProvider = StreamProvider.family<Equipe?, String>((ref, technicienId) {
  final affectations = ref.watch(affectationServiceProvider).getAffectationsByTechnicien(technicienId);
  final allEquipes = ref.watch(allEquipesProvider);

  return affectations.map((list) {
    if (list.isEmpty) return null;
    final equipeId = list.first.equipeId;
    return allEquipes.asData?.value.firstWhere((e) => e.id == equipeId);
  });
});

/// ===========================================================================
/// 4. COMPTEURS ET STATISTIQUES (Pour le Dashboard Admin)
/// ===========================================================================

// Compteur total d'équipes
final equipeCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allEquipesProvider).whenData((list) => list.length);
});

// Liste des équipes disponibles (disponibilite == true)
final equipesDisponiblesProvider = Provider<AsyncValue<List<Equipe>>>((ref) {
  final equipesAsync = ref.watch(allEquipesProvider);
  return equipesAsync.whenData(
          (list) => list.where((e) => e.disponibilite == true).toList()
  );
});