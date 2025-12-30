import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Import de vos modèles et providers
import '../../models/equipe.dart';
import '../../models/technicien.dart';
import '../../providers/equipe_provider.dart';
import 'AddEquipeForm.dart';

class GestionEquipesScreen extends ConsumerWidget {
  const GestionEquipesScreen({super.key});

  // Méthode pour afficher le formulaire (utilisée pour Ajout et Modification)
  void _showEquipeForm(BuildContext context, Equipe? equipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEquipeForm(equipe: equipe),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final equipesAsync = ref.watch(allEquipesProvider);
    final totalEquipes = ref.watch(equipeCountProvider).asData?.value ?? 0;
    final equipesDispo = ref.watch(equipesDisponiblesProvider).asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- APPBAR MD3 ---
          SliverAppBar.large(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surfaceTint,
            title: Text(
              "Gestion des Équipes",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // --- SECTION KPI ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  _buildKpiCard(
                    context,
                    title: "Total",
                    value: totalEquipes.toString(),
                    icon: Icons.groups_rounded,
                    color: colorScheme.primary,
                  ),
                  _buildKpiCard(
                    context,
                    title: "Dispo",
                    value: equipesDispo.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  _buildKpiCard(
                    context,
                    title: "En mission",
                    value: (totalEquipes - equipesDispo).toString(),
                    icon: Icons.engineering_rounded,
                    color: Colors.orangeAccent,
                  ),
                ],
              ),
            ),
          ),

          // --- LISTE DES ÉQUIPES ---
          equipesAsync.when(
            data: (equipes) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _EquipeCard(
                    equipe: equipes[index],
                    // On passe la fonction de modification à la carte
                    onEdit: () => _showEquipeForm(context, equipes[index]),
                  ),
                  childCount: equipes.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text("Erreur : $err")),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEquipeForm(context, null),
        elevation: 4,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: Text(
          "NOUVELLE ÉQUIPE",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipeCard extends ConsumerWidget {
  final Equipe equipe;
  final VoidCallback onEdit; // Callback pour déclencher la modification

  const _EquipeCard({required this.equipe, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final membresAsync = ref.watch(membresEquipeProvider(equipe.id!));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      color: colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: equipe.disponibilite
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  child: Text(
                    equipe.nomEquipe.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: equipe.disponibilite
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipe.nomEquipe,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusIndicator(context, equipe.disponibilite),
                    ],
                  ),
                ),
                _buildActionMenu(context, ref),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      "Effectif",
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant
                      ),
                    ),
                  ],
                ),
                membresAsync.when(
                  data: (membres) => _buildAvatarStack(context, membres),
                  loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const Icon(Icons.error_outline, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, bool dispo) {
    final color = dispo ? const Color(0xFF10B981) : Colors.orange;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          dispo ? "Prêt pour mission" : "En cours d'intervention",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack(BuildContext context, List<Technicien> membres) {
    if (membres.isEmpty) {
      return Text("Aucun membre", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey));
    }
    const double size = 32;
    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: (membres.length > 3 ? 3 : membres.length) * 22.0 + 10,
            child: Stack(
              children: List.generate(
                membres.length > 3 ? 3 : membres.length,
                    (index) => Positioned(
                  left: index * 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: size / 2,
                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                      child: Text(
                        membres[index].prenom[0],
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onTertiaryContainer),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (membres.length > 3)
            Text(
              "+${membres.length - 3}",
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  // --- LOGIQUE DE SUPPRESSION ---
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Supprimer l'équipe ?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Voulez-vous vraiment supprimer '${equipe.nomEquipe}' ? Cette action supprimera également les affectations liées."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              // 1. Supprimer les affectations liées
              await ref.read(affectationServiceProvider).removeAllAffectationsByEquipe(equipe.id!);
              // 2. Supprimer l'équipe
              await ref.read(equipeServiceProvider).deleteEquipe(equipe.id!);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Équipe supprimée"), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: const Text("SUPPRIMER"),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit(); // Appelle la fonction de modification
        } else if (value == 'delete') {
          _showDeleteDialog(context, ref); // Appelle le dialogue de suppression
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text("Modifier"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text("Supprimer", style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}