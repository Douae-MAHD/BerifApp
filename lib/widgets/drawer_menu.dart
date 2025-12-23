import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final String userRole;
  final String userName;
  final String userEmail;
  final ValueChanged<String> onItemSelected;

  const DrawerMenu({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () => onItemSelected('dashboard'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Gestion Travaux'),
                  onTap: () => onItemSelected('travaux'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  onTap: () => onItemSelected('profil'),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Paramètres'),
                  onTap: () => onItemSelected('parametres'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () => onItemSelected('deconnexion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}