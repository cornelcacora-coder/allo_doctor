import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../backend/offline_service.dart';

/// Bandeau "Mode Hors-ligne" affiché en haut de l'écran quand
/// le patient n'a plus de connexion internet.
///
/// Ce widget écoute [OfflineService] et s'affiche/disparaît
/// automatiquement selon l'état du réseau.
class OfflineBannerWidget extends StatefulWidget {
  /// Widget enfant à afficher sous le bandeau.
  final Widget child;

  const OfflineBannerWidget({super.key, required this.child});

  @override
  State<OfflineBannerWidget> createState() => _OfflineBannerWidgetState();
}

class _OfflineBannerWidgetState extends State<OfflineBannerWidget>
    with SingleTickerProviderStateMixin {
  final OfflineService _offlineService = OfflineService();
  late AnimationController _animController;
  late Animation<double> _slideAnim;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _offlineService.addListener(_onConnectivityChange);
    _showBanner = _offlineService.isOffline;
    if (_showBanner) _animController.forward();
  }

  void _onConnectivityChange() {
    if (_offlineService.isOffline && !_showBanner) {
      setState(() => _showBanner = true);
      _animController.forward();
    } else if (_offlineService.isOnline && _showBanner) {
      _animController.reverse().then((_) {
        if (mounted) setState(() => _showBanner = false);
      });
    }
  }

  @override
  void dispose() {
    _offlineService.removeListener(_onConnectivityChange);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Bandeau hors-ligne ───────────────────────────────────────────
        if (_showBanner)
          SlideTransition(
            position: _slideAnim.drive(
              Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
            ),
            child: _buildOfflineBanner(),
          ),

        // ── Contenu principal ────────────────────────────────────────────
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Icône pulsante
            _PulsingDot(color: const Color(0xFFFF6B6B)),
            const SizedBox(width: 10),

            // Texte principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mode Hors-ligne',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Données affichées : ${_offlineService.lastSyncLabel}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // Icône WiFi barré
            const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFFFF6B6B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget d'icône "point" pulsant
// ─────────────────────────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget carte "accès hors-ligne" affiché dans le carnet de santé
// ─────────────────────────────────────────────────────────────────────────────
class OfflineAccessCard extends StatelessWidget {
  const OfflineAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineSvc = OfflineService();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3460).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Color(0xFF4FC3F7),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accès Hors-ligne',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Vos ordonnances et RDV sont disponibles sans internet.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 13, color: Color(0xFF4FC3F7)),
                    const SizedBox(width: 4),
                    Text(
                      'Dernière sync : ${offlineSvc.lastSyncLabel}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: const Color(0xFF4FC3F7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bouton sync manuelle
          InkWell(
            onTap: () async {
              await offlineSvc.forceSyncNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Données synchronisées avec succès',
                      style: GoogleFonts.outfit(),
                    ),
                    backgroundColor: const Color(0xFF16C583),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
