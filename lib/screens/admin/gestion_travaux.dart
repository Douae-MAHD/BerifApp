import 'package:flutter/material.dart';
import '../../widgets/card_travail.dart';
import '../technicien/suivi_travail_screen.dart';

class GestionTravauxScreen extends StatefulWidget {
  const GestionTravauxScreen({super.key});

  @override
  State<GestionTravauxScreen> createState() => _GestionTravauxScreenState();
}

class _GestionTravauxScreenState extends State<GestionTravauxScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Tous', 'En cours', 'Terminés', 'En attente'];

  final List<Map<String, dynamic>> _travaux = [
    {
      'titre': 'Installation réseau fibre',
      'client': 'Entreprise ABC',
      'date': 'Aujourd\'hui',
      'statut': 'En cours',
      'priorite': 'Haute',
      'technicien': 'Jean Dupont',
    },
    {
      'titre': 'Maintenance serveur',
      'client': 'XYZ Corp',
      'date': 'Hier',
      'statut': 'Terminé',
      'priorite': 'Moyenne',
      'technicien': 'Marie Martin',
    },
    {
      'titre': 'Dépannage logiciel',
      'client': 'Particulier M. Durand',
      'date': '15 Déc',
      'statut': 'En attente',
      'priorite': 'Basse',
      'technicien': 'Pierre Lambert',
    },
    {
      'titre': 'Configuration VPN',
      'client': 'Startup Tech',
      'date': '14 Déc',
      'statut': 'En cours',
      'priorite': 'Haute',
      'technicien': 'Sophie Bernard',
    },
    {
      'titre': 'Audit sécurité',
      'client': 'Banque France',
      'date': '13 Déc',
      'statut': 'Terminé',
      'priorite': 'Haute',
      'technicien': 'Thomas Petit',
    },
  ];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les travaux'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  return RadioListTile<int>(
                    title: Text(filter),
                    value: index,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Travaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
            tooltip: 'Trier',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: const Text('Tous'),
                  icon: const Icon(Icons.all_inclusive),
                ),
                ButtonSegment(
                  value: 1,
                  label: const Text('En cours'),
                  icon: const Icon(Icons.play_arrow),
                ),
                ButtonSegment(
                  value: 2,
                  label: const Text('Terminés'),
                  icon: const Icon(Icons.check_circle),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _travaux.length,
              itemBuilder: (context, index) {
                final travail = _travaux[index];
                return CardTravail(
                  titre: travail['titre'],
                  client: travail['client'],
                  date: travail['date'],
                  statut: travail['statut'],
                  priorite: travail['priorite'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuiviTravailScreen(
                          travailId: index.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouveau travail'),
      ),
    );
  }
}