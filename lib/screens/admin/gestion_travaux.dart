import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Tes imports d'architecture
import '../../providers/travail_provider.dart';
import '../../providers/client_provider.dart';
import '../../widgets/admin_travail_card.dart';
import 'add_travail_form.dart';
import 'details_travail_screen.dart';

class GestionTravauxScreen extends ConsumerStatefulWidget {
  const GestionTravauxScreen({super.key});

  @override
  ConsumerState<GestionTravauxScreen> createState() => _GestionTravauxScreenState();
}

class _GestionTravauxScreenState extends ConsumerState<GestionTravauxScreen> {
  bool _isFilterExpanded = false;

  // --- PALETTE DE COULEURS PREMIUM ---
  final Color bgColor = const Color(0xFFFBFBFD); // Fond Premium
  final Color brandRed = const Color(0xFFD32F2F); // Rouge Signature

  @override
  Widget build(BuildContext context) {
    final filteredTravauxAsync = ref.watch(filteredTravauxProvider);
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. APP BAR MATERIAL 3 LARGE + EFFECT ---
              _buildCreativeSliverAppBar(),

              // --- 2. KPI STYLE IMAGE (DYNAMIQUE) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _buildDashboardKpis(stats),
                ),
              ),

              // --- 3. SEARCH & FILTER TOOL ---
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

              // --- 5. LISTE DES MISSIONS ---
              filteredTravauxAsync.when(
                data: (travaux) {
                  if (travaux.isEmpty) return const SliverFillRemaining(child: _EmptyState());
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildAnimatedCard(travaux[index], index),
                        childCount: travaux.length,
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

  // --- COMPONENTS ---

  Widget _buildCreativeSliverAppBar() {
    return SliverAppBar.large(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        "Travaux",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w900,
          fontSize: 32,
          color: Colors.black,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildDashboardKpis(Map<String, dynamic> stats) {
    return Row(
      children: [
        _kpiBox("Total", stats['total'].toString(), Colors.white, Colors.black),
        _kpiBox("À faire", stats['non_assigne'].toString(), const Color(0xFFFFEBEE), const Color(0xFFD32F2F)),
        _kpiBox("Assigné", stats['assigne'].toString(), const Color(0xFFFFF3E0), const Color(0xFFFB8C00)),
        _kpiBox("Terminé", stats['termine'].toString(), const Color(0xFFE8F5E9), const Color(0xFF388E3C)),
      ],
    );
  }

  Widget _kpiBox(String label, String value, Color bg, Color txt) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [BoxShadow(color: txt.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: txt)),
            Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: txt.withOpacity(0.6))),
          ],
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
                onChanged: (val) => ref.read(travailSearchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: "Rechercher une mission...",
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
            _buildDropdown("STATUT", ref.watch(travailStatusFilterProvider), [
              const DropdownMenuItem(value: null, child: Text("Tous les statuts")),
              const DropdownMenuItem(value: "en_attente", child: Text("À faire")),
              const DropdownMenuItem(value: "en_cours", child: Text("En cours")),
              const DropdownMenuItem(value: "termine", child: Text("Terminés")),
            ], (v) => ref.read(travailStatusFilterProvider.notifier).state = v),
            const SizedBox(height: 15),
            ref.watch(allTypesProvider).when(
              data: (types) => _buildDropdown("TYPE DE TRAVAIL", ref.watch(travailTypeFilterProvider), [
                const DropdownMenuItem(value: null, child: Text("Tous les types")),
                ...types.map((t) => DropdownMenuItem(value: t.nomType, child: Text(t.nomType))),
              ], (v) => ref.read(travailTypeFilterProvider.notifier).state = v),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
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
            borderRadius: BorderRadius.circular(22), // SQUIRCLE SHAPE
            boxShadow: [
              BoxShadow(color: brandRed.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  // --- LOGIC & HELPERS ---

  Widget _buildDropdown(String label, dynamic value, List<DropdownMenuItem<dynamic>> items, Function(dynamic) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F3F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: value, items: items, onChanged: onChanged, isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(dynamic travail, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: AdminTravailCard(
              travail: travail,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsTravailScreen(travail: travail))),
            ),
          ),
        );
      },
    );
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AddTravailForm());
  }
}

// --- DELEGATE POUR LE HEADER FIXE ---
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
          Icon(Icons.layers_clear_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("Aucune mission trouvée", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}