import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/equipe_service.dart';
import '../models/equipe.dart';

final equipeServiceProvider = Provider((ref) => EquipeService());

// Stream de toutes les équipes
final allEquipesProvider = StreamProvider<List<Equipe>>((ref) {
  return ref.watch(equipeServiceProvider).getEquipes();
});

// Compteur d'équipes (pour KPI Grid)
final equipeCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allEquipesProvider).whenData((list) => list.length);
});