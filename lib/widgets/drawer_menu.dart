import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isAdmin;
  const AppDrawer({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Session BERIF"),
            accountEmail: Text("Connecté"),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Tableau de bord"),
            onTap: () => Navigator.pushReplacementNamed(context, isAdmin ? '/admin_dashboard' : '/tech_dashboard'),
          ),
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Gérer les Techniciens"),
              onTap: () => Navigator.pushNamed(context, '/gestion_techs'),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Gérer les Clients"),
              onTap: () {},
            ),
          ],
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}