import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/client_provider.dart';
import '../../widgets/admin_client_card.dart';
import 'add_client_form.dart';

class GestionClientsScreen extends ConsumerStatefulWidget {
  const GestionClientsScreen({super.key});

  @override
  ConsumerState<GestionClientsScreen> createState() => _GestionClientsScreenState();
}

class _GestionClientsScreenState extends ConsumerState<GestionClientsScreen> {
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filteredClients = ref.watch(filteredClientsProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Fond gris très léger pour le relief
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. APP BAR MODERNE ---
              SliverAppBar.large(
                expandedHeight: 140,
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                stretch: true,
                title: Text(
                  "Répertoire Clients",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -1.2,
                  ),
                ),
              ),

              // --- 2. BARRE DE RECHERCHE (Toujours visible) ---
              SliverPersistentHeader(
                pinned: true,
                delegate: _ModernSearchDelegate(
                  child: _buildSearchAndFilterConsole(colorScheme),
                ),
              ),

              // --- 3. LISTE DES CLIENTS ---
              clientsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text("Erreur de connexion : $e")),
                ),
                data: (_) {
                  if (filteredClients.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyState());
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildAnimatedClientCard(filteredClients[index], index),
                        childCount: filteredClients.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- 4. FAB DESIGN ---
          _buildCreativeAddButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterConsole(ColorScheme colorScheme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(const Color(0xFFF1F3F9)),
                  hintText: "Rechercher un client...",
                  onChanged: (val) => ref.read(clientSearchProvider.notifier).state = val,
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
                  leading: const Icon(Icons.search_rounded, color: Colors.grey),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterToggleButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _isFilterExpanded = !_isFilterExpanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54, width: 54,
        decoration: BoxDecoration(
          color: _isFilterExpanded ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          _isFilterExpanded ? Icons.close_rounded : Icons.tune_rounded,
          color: _isFilterExpanded ? Colors.white : colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCreativeAddButton(ColorScheme colorScheme) {
    return Positioned(
      bottom: 30,
      right: 25,
      child: FloatingActionButton.large(
        onPressed: () => _showAddForm(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.add_business_rounded, size: 32),
      ),
    );
  }

  Widget _buildAnimatedClientCard(dynamic client, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: AdminClientCard(client: client, isManagementMode: true),
          ),
        );
      },
    );
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddClientForm()
    );
  }
}

// Delegate pour fixer la barre de recherche
class _ModernSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _ModernSearchDelegate({required this.child});
  @override Widget build(context, shrinkOffset, overlapsContent) => child;
  @override double get maxExtent => 70;
  @override double get minExtent => 70;
  @override bool shouldRebuild(oldDelegate) => true;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 40, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
              "Aucun client trouvé",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}