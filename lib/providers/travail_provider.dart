import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/travail_service.dart';
import '../services/technicien_service.dart';
import '../models/travail.dart';
import '../models/technicien.dart';

// Service providers
final travailServiceProvider = Provider((ref) => TravailService());
final technicienServiceProvider = Provider((ref) => TechnicienService());

// Stream providers (Temps réel)
final travauxStreamProvider = StreamProvider<List<Travail>>((ref) {
  return ref.watch(travailServiceProvider).getTravaux();
});

// Optionnel : Pour filtrer les travaux "En cours" uniquement
final travauxEnCoursProvider = Provider<AsyncValue<List<Travail>>>((ref) {
  final allTravaux = ref.watch(travauxStreamProvider);
  return allTravaux.whenData((list) =>
      list.where((t) => t.statut == 'en_cours').toList()
  );
});