import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/client_provider.dart';
import '../../widgets/admin_client_card.dart';
import '../../widgets/premuim_add_button.dart';
import 'add_client_form.dart'; // Crée ce fichier pour ton formulaire d'ajout

class GestionClientsScreen extends ConsumerWidget {
  const GestionClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredClients = ref.watch(filteredClientsProvider);
    final clientsAsync = ref.watch(allClientsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Car le fond est géré par AdminMainLayout
      appBar: AppBar(
        title: const Text("Répertoire Clients", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Barre de recherche "Soft UI"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(clientSearchProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: "Rechercher un client ou une ville...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD32F2F)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

          // Liste dynamique
          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Erreur de chargement")),
              data: (_) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  return AdminClientCard(client: filteredClients[index],isManagementMode: true,);
                },
              ),
            ),
          ),
        ],
      ),
      // Bouton flottant pour ajouter un client
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10), // Un peu d'espace avec la nav bar
        child: PremiumAddButton(
          label: "Nouveau Client",
          onTap: () => _showAddForm(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddClientForm(), // Ton widget de formulaire
    );
  }
}