import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';
import '../screens/admin/client_detail_screen.dart';
import '../screens/admin/add_client_form.dart';

class AdminClientCard extends ConsumerStatefulWidget {
  final Client client;
  final bool isManagementMode; // true = Écran de gestion (3 points), false = Dashboard (Badge)

  const AdminClientCard({
    super.key,
    required this.client,
    this.isManagementMode = false, // Par défaut, on affiche le badge (Dashboard)
  });

  @override
  ConsumerState<AdminClientCard> createState() => _AdminClientCardState();
}

class _AdminClientCardState extends ConsumerState<AdminClientCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color statusColor = Color(0xFFF57C00); // Orange

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER CONDITIONNEL ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.client.nomClient,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1C1E),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // LOGIQUE ICI :
                        if (widget.isManagementMode)
                        // SI MODE GESTION -> ON AFFICHE LES 3 POINTS
                          _buildPopupMenu(context)
                        else
                        // SI MODE DASHBOARD -> ON AFFICHE LE BADGE
                          _buildStatusBadge("Équipe assignée", statusColor),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- ADRESSE ---
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${widget.client.adresse}, ${widget.client.ville}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- INFO BOX ---
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.description_outlined, "Contrat", widget.client.typeContrat),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, thickness: 0.5)),
                          _buildInfoRow(Icons.event_available_outlined, "Intervention", "À planifier"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- BOUTON D'ACTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFD32F2F)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientDetailScreen(client: widget.client))),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Détails du client", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les 3 points
  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (val) => _handleAction(val, context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 10), Text("Modifier")])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 10), Text("Supprimer", style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  // Widget pour le badge orange
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2), width: 1)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  void _handleAction(String value, BuildContext context) {
    if (value == 'edit') {
      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddClientForm(client: widget.client));
    } else if (value == 'delete') {
      _showDeleteDialog(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: Text("Voulez-vous supprimer ${widget.client.nomClient} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(onPressed: () { ref.read(clientServiceProvider).deleteClient(widget.client.id!); Navigator.pop(context); }, child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text("$label : ", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
      ],
    );
  }
}