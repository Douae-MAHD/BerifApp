import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT DE TES FICHIERS (Vérifie bien les chemins) ---
import '../models/client.dart';
import '../providers/client_provider.dart';
import '../screens/admin/client_detail_screen.dart';
import '../screens/admin/add_client_form.dart';

class AdminClientCard extends ConsumerStatefulWidget {
  final Client client;
  final bool isManagementMode;

  const AdminClientCard({
    super.key,
    required this.client,
    this.isManagementMode = false,
  });

  @override
  ConsumerState<AdminClientCard> createState() => _AdminClientCardState();
}

class _AdminClientCardState extends ConsumerState<AdminClientCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientDetailScreen(client: widget.client))
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- AVATAR CLIENT ---
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.client.nomClient.isNotEmpty
                                ? widget.client.nomClient.substring(0, 1).toUpperCase()
                                : "?",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.client.nomClient,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 14, color: colorScheme.primary.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  widget.client.ville,
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.isManagementMode)
                        _buildPopupMenu(context, colorScheme)
                      else
                        _buildStatusBadge("À PLANIFIER", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- SECTION INFO TONALE ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildCompactInfo(Icons.description_outlined, widget.client.typeContrat, colorScheme),
                        Container(
                            height: 24,
                            width: 1,
                            color: colorScheme.outlineVariant,
                            margin: const EdgeInsets.symmetric(horizontal: 16)
                        ),
                        _buildCompactInfo(Icons.calendar_today_rounded, "Prochaine: N/A", colorScheme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- QUICK ACTIONS ---
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Action appel par exemple
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Contacter"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () {},
                        icon: const Icon(Icons.map_rounded),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String value, ColorScheme colorScheme) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: _buildMenuRow(Icons.edit_rounded, "Modifier", colorScheme.onSurface)),
        PopupMenuItem(value: 'delete', child: _buildMenuRow(Icons.delete_rounded, "Supprimer", colorScheme.error)),
      ],
      onSelected: (val) => _handleAction(val, context),
    );
  }

  Widget _buildMenuRow(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))
    ]);
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Text(
          text,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
      ),
    );
  }

  void _handleAction(String value, BuildContext context) {
    if (value == 'edit') {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddClientForm(client: widget.client)
      );
    } else if (value == 'delete') {
      _showDeleteDialog(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Supprimer ?"),
        content: Text("Voulez-vous supprimer ${widget.client.nomClient} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          FilledButton(
            onPressed: () {
              ref.read(clientServiceProvider).deleteClient(widget.client.id!);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}