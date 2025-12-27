import 'package:flutter/material.dart';
import 'dashboard_admin.dart'; // Ton dashboard actuel (renommé en DashboardHome)
import 'gestion_clients.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  // Liste des différentes pages de l'Admin
  final List<Widget> _pages = [
    const DashboardAdminScreen(), // Index 0 : Board
    const GestionClientsScreen(), // Index 1 : Clients
    const Center(child: Text("Gestion Travaux")), // Index 2 : Placeholder
    const Center(child: Text("Gestion Équipes")), // Index 3 : Placeholder
    const Center(child: Text("Gestion Techniciens")), // Index 4 : Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack permet de garder l'état des pages quand on change d'onglet
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}