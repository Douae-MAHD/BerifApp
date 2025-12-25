import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_provider.dart';
import '../providers/equipe_provider.dart';
import '../providers/travail_provider.dart';
import '../providers/user_provider.dart';


class AdminKpiGrid extends ConsumerWidget {
  const AdminKpiGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper pour extraire la valeur ou afficher l'erreur en console
    String getAsyncValue(AsyncValue<int> asyncValue, String label) {
      return asyncValue.when(
        data: (count) => count.toString(),
        loading: () => '...', // Affiche des points pendant le chargement
        error: (err, stack) {
          debugPrint('❌ Erreur KPI $label: $err'); // Regarde ta console debug !
          return '!'; // Affiche un point d'exclamation si ça plante
        },
      );
    }

    // On écoute les providers de compteurs
    final String techCount = getAsyncValue(ref.watch(techCountProvider), 'Techs');
    final String clientCount = getAsyncValue(ref.watch(clientCountProvider), 'Clients');
    final String equipeCount = getAsyncValue(ref.watch(equipeCountProvider), 'Equipes');
    final String travailCount = getAsyncValue(ref.watch(travailCountProvider), 'Travaux');

    final List<Map<String, dynamic>> kpis = [
      {
        'value': techCount,
        'label': 'Techniciens',
        'icon': Icons.engineering_rounded,
        'colors': [const Color(0xFFEF5350), const Color(0xFFC62828)],
      },
      {
        'value': clientCount,
        'label': 'Clients',
        'icon': Icons.business_rounded,
        'colors': [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
      },
      {
        'value': equipeCount,
        'label': 'Équipes',
        'icon': Icons.group_work_rounded,
        'colors': [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
      },
      {
        'value': travailCount,
        'label': 'Travaux',
        'icon': Icons.assignment_rounded,
        'colors': [const Color(0xFFFFA726), const Color(0xFFEF6C00)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 100)),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _KpiGradientCard(
                  value: kpis[index]['value'],
                  label: kpis[index]['label'],
                  icon: kpis[index]['icon'],
                  colors: kpis[index]['colors'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ... Ton widget _KpiGradientCard reste le même (il est déjà très bien)

class _KpiGradientCard extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> colors;

  const _KpiGradientCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  State<_KpiGradientCard> createState() => _KpiGradientCardState();
}

class _KpiGradientCardState extends State<_KpiGradientCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    widget.icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      // FittedBox gère l'overflow si le chiffre devient trop grand (ex: 1000)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Text simple avec ellipsis pour le label
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}