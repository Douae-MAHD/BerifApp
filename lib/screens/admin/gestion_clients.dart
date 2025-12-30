import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Tes imports d'architecture
import '../../providers/client_provider.dart';
import '../../widgets/admin_client_card.dart';
import 'add_client_form.dart';
import 'client_detail_screen.dart'; // Si tu as un écran de détail

class GestionClientsScreen extends ConsumerStatefulWidget {
  const GestionClientsScreen({super.key});

  @override
  ConsumerState<GestionClientsScreen> createState() => _GestionClientsScreenState();
}

class _GestionClientsScreenState extends ConsumerState<GestionClientsScreen> {
  bool _isFilterExpanded = false;

  // --- PALETTE DE COULEURS UNIFIÉE ---
  final Color bgColor = const Color(0xFFFBFBFD);
  final Color brandRed = const Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final filteredClients = ref.watch(filteredClientsProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    final clientCount = ref.watch(clientCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. APP BAR MATERIAL 3 LARGE ---
              _buildCreativeSliverAppBar(),


              // --- 3. SEARCH & FILTER TOOL (Console Aero) ---
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeaderDelegate(
                  child: _buildSearchAndFilterConsole(),
                ),
              ),

              // --- 4. PANNEAU DE FILTRE (EXPANSION) ---
              SliverToBoxAdapter(
                child: _buildExpandableFilterPanel(),
              ),

              // --- 5. LISTE DES CLIENTS AVEC ANIMATION ---
              clientsAsync.when(
                data: (_) {
                  if (filteredClients.isEmpty) return const SliverFillRemaining(child: _EmptyState());
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildAnimatedClientCard(filteredClients[index], index),
                        childCount: filteredClients.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text("Erreur: $e"))),
              ),
            ],
          ),

          // --- 6. UNIQUE CREATIVE FAB ---
          _buildCreativeAddButton(),
        ],
      ),
    );
  }

  // --- COMPONENTS DESIGN ---

  Widget _buildCreativeSliverAppBar() {
    return SliverAppBar.large(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        "Clients",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w900,
          fontSize: 32,
          color: Colors.black,
          letterSpacing: -1,
        ),
      ),
    );
  }



  Widget _buildSearchAndFilterConsole() {
    return Container(
      color: bgColor.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (val) => ref.read(clientSearchProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: "Rechercher un client ou une ville...",
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _isFilterExpanded = !_isFilterExpanded);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 54, width: 54,
              decoration: BoxDecoration(
                color: _isFilterExpanded ? brandRed : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                _isFilterExpanded ? Icons.close_rounded : Icons.tune_rounded,
                color: _isFilterExpanded ? Colors.white : brandRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFilterPanel() {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FILTRES AVANCÉS", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            // Ici tu peux ajouter des filtres par Ville ou Type de Contrat
            const Text("Filtrage par secteur ou ville bientôt disponible", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      crossFadeState: _isFilterExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildCreativeAddButton() {
    return Positioned(
      bottom: 30,
      right: 25,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          _showAddForm(context);
        },
        child: Container(
          height: 65, width: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [brandRed, brandRed.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22), // SQUIRCLE
            boxShadow: [
              BoxShadow(color: brandRed.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildAnimatedClientCard(dynamic client, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: AdminClientCard(
              client: client,
              isManagementMode: true,
            ),
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

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _FilterHeaderDelegate({required this.child});
  @override
  Widget build(context, shrinkOffset, overlapsContent) => child;
  @override
  double get maxExtent => 70;
  @override
  double get minExtent => 70;
  @override
  bool shouldRebuild(oldDelegate) => true;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("Aucun client trouvé", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}