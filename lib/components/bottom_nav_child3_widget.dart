import '/components/nav_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bottom_nav_child3_model.dart';
export 'bottom_nav_child3_model.dart';

class BottomNavChild3Widget extends StatefulWidget {
  const BottomNavChild3Widget({super.key});

  @override
  State<BottomNavChild3Widget> createState() => _BottomNavChild3WidgetState();
}

class _BottomNavChild3WidgetState extends State<BottomNavChild3Widget> {
  late BottomNavChild3Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomNavChild3Model());

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
          model: _model.navItemModel1,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Accueil',
            icon: Icon(
              Icons.home_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'home',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel2,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Pharma.',
            icon: Icon(
              Icons.medical_services_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'pharmacy',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Sang',
            icon: Icon(
              Icons.water_drop_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'blood_bank',
            selected: true,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel4,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Médecins',
            icon: Icon(
              Icons.help,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'doctors',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel5,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Profil',
            icon: Icon(
              Icons.person_outline_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'profile',
            selected: false,
          ),
        ),
      ],
    );
  }
}
