import 'package:flutter/material.dart';
import '../../widgets/card_travail.dart';
import '../../widgets/drawer_menu.dart';
import 'gestion_clients.dart';
import 'gestion_travaux.dart';
import '../technicien/suivi_travail_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _stats = [
    {'label': 'Travaux en cours', 'value': '12', 'icon': Icons.work, 'color': Colors.blue},
    {'label': 'Techniciens actifs', 'value': '8', 'icon': Icons.engineering, 'color': Colors.green},
    {'label': 'Clients', 'value': '45', 'icon': Icons.people, 'color': Colors.purple},
    {'label': 'Rendement', 'value': '92%', 'icon': Icons.trending_up, 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> _recentTravaux = [
    {
      'titre': 'Installation réseau',
      'client': 'Entreprise ABC',
      'date': '15 Déc 2024',
      'statut': 'En cours',
      'priorite': 'Haute',
    },
    {
      'titre': 'Maintenance serveur',
      'client': 'XYZ Corp',
      'date': '14 Déc 2024',
      'statut': 'Terminé',
      'priorite': 'Moyenne',
    },
    {
      'titre': 'Dépannage logiciel',
      'client': 'Particulier M. Dupont',
      'date': '13 Déc 2024',
      'statut': 'En attente',
      'priorite': 'Basse',
    },
  ];

  void _onDrawerItemSelected(String item) {
    Navigator.pop(context);
    switch (item) {
      case 'dashboard':
        break;
      case 'clients':
        Navigator.push(
          context,
          MaterialPageRoute(
            // CORRECTION: Enlever le 'const' ici
            builder: (context) => GestionClientsScreen(),
          ),
        );
        break;
      case 'travaux':
        Navigator.push(
          context,
          MaterialPageRoute(
            // CORRECTION: Enlever le 'const' ici
            builder: (context) => GestionTravauxScreen(),
          ),
        );
        break;
      case 'profil':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: DrawerMenu(
        userRole: 'admin',
        userName: 'Admin User',
        userEmail: 'admin@techwork.com',
        onItemSelected: _onDrawerItemSelected,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Aperçu général',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
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
                    childAspectRatio: 1.2,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: stat['color'].withOpacity(0.1),
                              child: Icon(
                                stat['icon'],
                                color: stat['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              stat['value'],
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              stat['label'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Travaux récents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final travail = _recentTravaux[index];
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
                          // CORRECTION: Ajouter 'const' ici si SuiviTravailScreen a un const constructor
                          builder: (context) => const SuiviTravailScreen(
                            travailId: '1', // Passer une valeur concrète
                            isTechnicien: false,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _recentTravaux.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
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
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Travaux',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}