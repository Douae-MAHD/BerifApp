import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/technicien_service.dart';
import '../models/technicien.dart';

final technicienServiceProvider = Provider((ref) => TechnicienService());

// Stream de tous les techniciens
final allTechniciensProvider = StreamProvider<List<Technicien>>((ref) {
  return ref.watch(technicienServiceProvider).getTechniciens();
});

// Compteur de techniciens (pour KPI Grid)
final techCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allTechniciensProvider).whenData((list) => list.length);
});