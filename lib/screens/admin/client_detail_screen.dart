import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import 'add_client_form.dart'; // Import pour la modification

class ClientDetailScreen extends ConsumerWidget { // Changé en ConsumerWidget
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Détails du client",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // --- BOUTONS D'ACTIONS : MODIFIER ET SUPPRIMER ---
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () => _showEditForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- BLOC INFO CLIENT ---
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          client.nomClient,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusChip("Terminé", const Color(0xFF00BFA5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailItem(Icons.location_on_rounded, "Adresse", "${client.adresse}, ${client.ville}"),
                  _buildDetailItem(Icons.phone_rounded, "Téléphone", client.telephone),
                  _buildDetailItem(Icons.email_rounded, "Email", client.email),
                  _buildDetailItem(Icons.description_rounded, "Type de contrat", client.typeContrat),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // --- BLOC HISTORIQUE ---
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Historique des interventions",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildHistoryItem(
                      Icons.access_time_rounded,
                      "Dernière intervention",
                      client.dateDernierIntervention != null
                          ? DateFormat('dd MMMM yyyy', 'fr_FR').format(client.dateDernierIntervention!)
                          : "Aucune",
                      Colors.grey
                  ),
                  const SizedBox(height: 20),
                  _buildHistoryItem(
                      Icons.calendar_month_rounded,
                      "Prochaine intervention prévue",
                      // Ici on pourrait calculer la date dynamiquement selon le contrat
                      "À définir",
                      const Color(0xFFD32F2F)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour ouvrir le formulaire de modification
  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddClientForm(client: client), // On passe le client actuel
    );
  }

  // Boîte de dialogue pour confirmer la suppression
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer le client ?"),
        content: Text("Voulez-vous vraiment supprimer ${client.nomClient} ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (client.id != null) {
                await ref.read(clientServiceProvider).deleteClient(client.id!);
                if (context.mounted) {
                  Navigator.pop(context); // Fermer le dialogue
                  Navigator.pop(context); // Revenir à la liste
                }
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade500),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(IconData icon, String label, String date, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 2),
            Text(date, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}