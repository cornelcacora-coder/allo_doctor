import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_member_card_model.dart';
export 'clinic_member_card_model.dart';

class ClinicMemberCardWidget extends StatefulWidget {
  const ClinicMemberCardWidget({
    super.key,
    String? name,
    String? location,
    String? distance,
    this.specialty,
    this.photoProfile,
    this.bookMeet,
    this.contactClinic,
    this.onDelete,
    this.onToggleActive,
    this.isActive = true,
  })  : this.name = name ?? 'Praticien',
        this.location = location ?? 'Clinique',
        this.distance = distance ?? '1.2 km';

  final String name;
  final String location;
  final String distance;
  final String? specialty;
  final String? photoProfile;
  final Future Function()? bookMeet;
  final Future Function()? contactClinic;
  final Future Function()? onDelete;
  final Future Function(bool)? onToggleActive;
  final bool isActive;

  @override
  State<ClinicMemberCardWidget> createState() => _ClinicMemberCardWidgetState();
}

class _ClinicMemberCardWidgetState extends State<ClinicMemberCardWidget> {
  late ClinicMemberCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicMemberCardModel());

    _model.switchValue = widget.isActive;
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValidPhoto = widget.photoProfile != null &&
        widget.photoProfile!.trim().isNotEmpty &&
        !widget.photoProfile!.contains('gstatic.com') &&
        !widget.photoProfile!.contains('404') &&
        !widget.photoProfile!.contains('placeholder');

    final initial = widget.name.trim().isNotEmpty
        ? widget.name.trim()[0].toUpperCase()
        : 'M';

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─── Photo / Avatar propre ───
            Container(
              width: 45.0,
              height: 45.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: hasValidPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        widget.photoProfile!,
                        width: 45.0,
                        height: 45.0,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12.0),

            // ─── Nom & Spécialité ───
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontSize: 14.0,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    child: Text(
                      widget.specialty ?? 'Médecine générale',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F766E),
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Bouton Supprimer 🗑️ ───
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22.0),
                tooltip: 'Supprimer ce membre',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Supprimer ce membre', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      content: Text('Voulez-vous vraiment retirer "${widget.name}" du personnel ?', style: GoogleFonts.outfit()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Annuler', style: GoogleFonts.outfit(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Supprimer', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await widget.onDelete?.call();
                  }
                },
              ),

            // ─── Switch Actif/Inactif ───
            Switch.adaptive(
              value: _model.switchValue!,
              onChanged: (newValue) async {
                safeSetState(() => _model.switchValue = newValue);
                await widget.onToggleActive?.call(newValue);
              },
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF0F766E),
              inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
              inactiveThumbColor: FlutterFlowTheme.of(context).secondaryBackground,
            ),
          ],
        ),
      ),
    );
  }
}
