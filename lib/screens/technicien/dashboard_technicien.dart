import 'package:flutter/material.dart';
import '../../widgets/card_travail.dart';

class DashboardTechnicienScreen extends StatefulWidget {
  const DashboardTechnicienScreen({super.key});

  @override
  State<DashboardTechnicienScreen> createState() =>
      _DashboardTechnicienScreenState();
}

class _DashboardTechnicienScreenState extends State<DashboardTechnicienScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _mesTravaux = [
    {
      'titre': 'Installation réseau fibre',
      'client': 'Entreprise ABC',
      'date': 'Aujourd\'hui, 14:00',
      'statut': 'En cours',
      'priorite': 'Haute',
      'adresse': '12 Rue de Paris, 75001',
      'duree': '2 heures',
    },
    {
      'titre': 'Maintenance serveur',
      'client': 'XYZ Corp',
      'date': 'Demain, 09:00',
      'statut': 'Planifié',
      'priorite': 'Moyenne',
      'adresse': '45 Avenue Lyon, 69002',
      'duree': '4 heures',
    },
    {
      'titre': 'Dépannage informatique',
      'client': 'M. Martin Durand',
      'date': 'Hier, 15:30',
      'statut': 'Terminé',
      'priorite': 'Basse',
      'adresse': '8 Rue des Lilas, 75018',
      'duree': '1.5 heures',
    },
  ];

  final List<Map<String, dynamic>> _stats = [
    {
      'label': 'Travaux ce mois',
      'value': '15',
      'icon': Icons.work_history,
      'progress': 0.75,
      'color': Colors.blue,
    },
    {
      'label': 'Taux de réussite',
      'value': '96%',
      'icon': Icons.star_rate,
      'progress': 0.96,
      'color': Colors.green,
    },
    {
      'label': 'Heures travaillées',
      'value': '120h',
      'icon': Icons.timer,
      'progress': 0.8,
      'color': Colors.orange,
    },
    {
      'label': 'Satisfaction clients',
      'value': '4.8/5',
      'icon': Icons.sentiment_satisfied,
      'progress': 0.96,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Technicien'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
            tooltip: 'Scanner QR Code',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // En-tête avec informations du technicien
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Text(
                        'JD',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jean Dupont',
                            style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Technicien réseau senior',
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Paris',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Disponible',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cartes de statistiques
                Text(
                  'Mes statistiques',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _stats.length,
                  itemBuilder: (context, index) {
                    final stat = _stats[index];
                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: stat['color'].withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    stat['icon'],
                                    color: stat['color'],
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  stat['value'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              stat['label'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: stat['progress'],
                              backgroundColor:
                              stat['color'].withOpacity(0.1),
                              color: stat['color'],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Travaux du jour
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes travaux',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voir planning'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // Liste des travaux
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final travail = _mesTravaux[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == _mesTravaux.length - 1 ? 0 : 12),
                    child: CardTravail(
                      titre: travail['titre'],
                      client: travail['client'],
                      date: travail['date'],
                      statut: travail['statut'],
                      priorite: travail['priorite'],
                      onTap: () {

                      },
                    ),
                  );
                },
                childCount: _mesTravaux.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),

      // Boutons d'action rapide
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'report',
            onPressed: () {
              _showRapportDialog();
            },
            child: const Icon(Icons.report),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'main',
            onPressed: () {
              _showActionsMenu(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),

      // Navigation inférieure
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            selectedIcon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            selectedIcon: Icon(Icons.work_outline),
            label: 'Travaux',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule),
            selectedIcon: Icon(Icons.schedule_outlined),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showRapportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Générer un rapport'),
          content: const Text(
            'Choisissez le type de rapport à générer :',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Rapport généré avec succès'),
                    action: SnackBarAction(
                      label: 'Télécharger',
                      onPressed: () {},
                    ),
                  ),
                );
              },
              child: const Text('Générer'),
            ),
          ],
        );
      },
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    context,
                    Icons.timer,
                    'Début travail',
                    Colors.blue,
                  ),
                  _buildActionButton(
                    context,
                    Icons.check_circle,
                    'Terminer',
                    Colors.green,
                  ),
                  _buildActionButton(
                    context,
                    Icons.camera_alt,
                    'Prendre photo',
                    Colors.purple,
                  ),
                  _buildActionButton(
                    context,
                    Icons.note_add,
                    'Ajouter note',
                    Colors.orange,
                  ),
                  _buildActionButton(
                    context,
                    Icons.location_on,
                    'Partager position',
                    Colors.red,
                  ),
                  _buildActionButton(
                    context,
                    Icons.help,
                    'Demander aide',
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      IconData icon,
      String label,
      Color color,
      ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action : $label'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}