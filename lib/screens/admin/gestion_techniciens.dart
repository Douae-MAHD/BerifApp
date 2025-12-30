import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_technician_screen.dart';
import '../../models/technicien.dart';

// --- SERVICE TECHNIQUE ---
class TechnicienService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('utilisateurs');
  Future<void> deleteTechnicien(String id) => _db.doc(id).delete();
  Future<void> updateTechnicien(String id, Map<String, dynamic> data) => _db.doc(id).update(data);
}

class GestionTechniciens extends StatefulWidget {
  const GestionTechniciens({super.key});

  @override
  State<GestionTechniciens> createState() => _GestionTechniciensState();
}

class _GestionTechniciensState extends State<GestionTechniciens> {
  final TechnicienService _service = TechnicienService();
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- APPBAR LARGE ---
          SliverAppBar.large(
            expandedHeight: 170,
            stretch: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                "Techniciens",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -1.2,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colorScheme.primary.withOpacity(0.05), colorScheme.surface],
                  ),
                ),
              ),
            ),
          ),

          // --- BARRE DE RECHERCHE GLASSMORPHISM ---
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: colorScheme.surface.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: SearchBar(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceVariant.withOpacity(0.4)),
                      hintText: "Rechercher par nom ou email...",
                      hintStyle: WidgetStatePropertyAll(TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.6))),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
                      leading: Icon(Icons.search_rounded, color: colorScheme.primary, size: 22),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- LISTE DES TECHNICIENS ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('utilisateurs')
                .where('role', isEqualTo: 'technicien')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator.adaptive()));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(colorScheme));
              }

              final filteredTechs = snapshot.data!.docs
                  .map((doc) => Technicien.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                  .where((tech) =>
              tech.nom.toLowerCase().contains(searchQuery) ||
                  tech.prenom.toLowerCase().contains(searchQuery) ||
                  tech.email.toLowerCase().contains(searchQuery))
                  .toList();

              if (filteredTechs.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(colorScheme, message: "Aucun résultat trouvé"));
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final tech = filteredTechs[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 60)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: _buildPremiumTechCard(context, tech, colorScheme),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredTechs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // --- FAB CORRIGÉ ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add_tech'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4, // Ombre standard M3 (plus propre)
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: Text("Ajouter", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildPremiumTechCard(BuildContext context, Technicien tech, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () => _showActionMenu(context, tech, colorScheme),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _buildModernAvatar(tech.nom, colorScheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tech.prenom,
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500, fontSize: 16, color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tech.nom,
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800, fontSize: 16, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tech.email,
                        style: GoogleFonts.plusJakartaSans(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTonalBadge(colorScheme),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, Technicien tech, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 45, height: 5, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Options Technicien", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 28),
              title: Text("Modifier le profil", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditTechnicianScreen(technicien: tech)));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep_rounded, color: colorScheme.error, size: 28),
              title: Text("Supprimer du répertoire", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletion(context, tech.id!, "${tech.prenom} ${tech.nom}", colorScheme);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAvatar(String name, ColorScheme colorScheme) {
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "?";
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildTonalBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded, size: 12, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            "COMPTE ACTIF",
            style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context, String id, String name, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Supprimer ?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text("Êtes-vous sûr de vouloir retirer $name de la base de données ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () async {
              await _service.deleteTechnicien(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, {String message = "Aucun technicien"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_outlined, size: 60, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.plusJakartaSans(color: colorScheme.outline, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SearchHeaderDelegate({required this.child});
  @override Widget build(context, double shrinkOffset, bool overlapsContent) => child;
  @override double get maxExtent => 80;
  @override double get minExtent => 80;
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}