import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Modèles
import '../models/travail.dart';
import '../models/client.dart';
import '../models/equipe.dart';

// Providers & Services
import '../providers/client_provider.dart';
import '../providers/equipe_provider.dart';
import '../providers/travail_provider.dart';

class AdminTravailCard extends ConsumerWidget {
  final Travail travail;
  final VoidCallback onTap;

  const AdminTravailCard({
    super.key,
    required this.travail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Récupération des données pour transformer les IDs en Noms
    final clients = ref.watch(allClientsProvider).asData?.value ?? [];
    final equipes = ref.watch(allEquipesProvider).asData?.value ?? [];

    // 2. Recherche du client (avec fallback sécurisé)
    final client = clients.firstWhere(
          (c) => c.id == travail.clientId,
      orElse: () => Client(
        id: '',
        nomClient: "Client inconnu",
        adresse: "",
        ville: "",
        telephone: "",
        email: "",
        typeContrat: "",
        periodiciteMaintenance: "",
        secteur: "",
      ),
    );

    // 3. Recherche de l'équipe (si assignée)
    final equipe = equipes.firstWhere(
          (e) => e.id == travail.equipeId,
      orElse: () => Equipe(id: '', nomEquipe: "Non assignée", disponibilite: true),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LIGNE 1 : CLIENT + STATUT ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        client.nomClient,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatutBadge(travail.statut),
                  ],
                ),
                const SizedBox(height: 8),

                // --- LIGNE 2 : TYPE DE TRAVAIL ---
                Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                        travail.typeId,
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- INFOS DÉTAILLÉES ---
                _infoRow(Icons.groups_outlined, "Équipe : ",
                    travail.equipeId == null ? "À affecter" : equipe.nomEquipe,
                    isWarning: travail.equipeId == null),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.calendar_today_outlined,
                  "Prévu le : ",
                  travail.datePlanifiee != null
                      ? DateFormat('dd MMMM yyyy', 'fr_FR').format(travail.datePlanifiee!)
                      : "Non définie",
                ),

                const SizedBox(height: 20),

                // --- ACTIONS ---
                Row(
                  children: [
                    // Bouton Détails (Toujours présent)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Voir détails", style: TextStyle(color: Colors.black)),
                      ),
                    ),

                    // Bouton Affecter (Si pas d'équipe)
                    if (travail.equipeId == null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showEquipePicker(context, ref, equipes),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Affecter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS INTERNES ---

  Widget _infoRow(IconData icon, String label, String value, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isWarning ? Colors.orange : Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isWarning ? Colors.orange.shade800 : Colors.black87
            )
        ),
      ],
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'termine':
        color = const Color(0xFF34A853);
        label = "TERMINÉ";
        break;
      case 'en_cours':
        color = const Color(0xFF4285F4);
        label = "EN COURS";
        break;
      default:
        color = const Color(0xFFEA4335);
        label = "À FAIRE";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- DIALOGUE D'AFFECTATION D'ÉQUIPE ---
  void _showEquipePicker(BuildContext context, WidgetRef ref, List<Equipe> equipes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Affecter une équipe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (equipes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Aucune équipe disponible")),
              )
            else
              ...equipes.map((e) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.group)),
                title: Text(e.nomEquipe),
                subtitle: Text(e.disponibilite ? "Disponible" : "Occupée"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  // Appel au service pour mettre à jour Firestore
                  await ref.read(travailServiceProvider).affecterEquipe(travail.id!, e.id!);
                  if (context.mounted) Navigator.pop(context);
                },
              )).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}