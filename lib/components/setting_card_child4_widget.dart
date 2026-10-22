import '/components/setting_row_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'setting_card_child4_model.dart';
export 'setting_card_child4_model.dart';

class SettingCardChild4Widget extends StatefulWidget {
  const SettingCardChild4Widget({super.key});

  @override
  State<SettingCardChild4Widget> createState() =>
      _SettingCardChild4WidgetState();
}

class _SettingCardChild4WidgetState extends State<SettingCardChild4Widget> {
  late SettingCardChild4Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingCardChild4Model());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: _model.settingRowModel1,
          updateCallback: () => safeSetState(() {}),
          child: SettingRowWidget(
            icon: Icon(
              Icons.notifications_rounded,
              color: FlutterFlowTheme.of(context).primarytext80,
              size: 22.0,
            ),
            iconBg: Color(0xFFFFF4E5),
            subtitle: 'Rappels, commandes, alertes',
            title: 'Gérer les notifications',
            last: true,
          ),
        ),
        wrapWithModel(
          model: _model.settingRowModel2,
          updateCallback: () => safeSetState(() {}),
          child: SettingRowWidget(
            icon: Icon(
              Icons.lock_rounded,
              color: FlutterFlowTheme.of(context).primarytext80,
              size: 22.0,
            ),
            iconBg: Color(0xFFF0F4FF),
            subtitle: 'QR urgence, biométrie, consentements, RGPD',
            title: 'Sécurité & vie privée',
            last: true,
          ),
        ),
        wrapWithModel(
          model: _model.settingRowModel3,
          updateCallback: () => safeSetState(() {}),
          child: SettingRowWidget(
            icon: Icon(
              Icons.verified_user_rounded,
              color: FlutterFlowTheme.of(context).primarytext80,
              size: 22.0,
            ),
            iconBg: Color(0xFFE8F5E9),
            subtitle: 'Authentifier un médecin, une pharmacie, un labo',
            title: 'Vérifier un professionnel',
            last: true,
          ),
        ),
        wrapWithModel(
          model: _model.settingRowModel4,
          updateCallback: () => safeSetState(() {}),
          child: SettingRowWidget(
            icon: Icon(
              Icons.description_rounded,
              color: FlutterFlowTheme.of(context).primarytext80,
              size: 22.0,
            ),
            iconBg: Color(0xFFFFF9C4),
            subtitle: 'Tout votre historique santé en un fil',
            title: 'Mon parcours de soins',
            last: true,
          ),
        ),
        wrapWithModel(
          model: _model.settingRowModel5,
          updateCallback: () => safeSetState(() {}),
          child: SettingRowWidget(
            icon: Icon(
              Icons.info_rounded,
              color: FlutterFlowTheme.of(context).primarytext80,
              size: 22.0,
            ),
            iconBg: Color(0xFFE3F2FD),
            subtitle: 'Version 1.0 - Congo',
            title: 'À propos d\'Allô Docteur',
            last: true,
          ),
        ),
      ],
    );
  }
}
