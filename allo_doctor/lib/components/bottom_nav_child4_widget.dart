import '/components/nav_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bottom_nav_child4_model.dart';
export 'bottom_nav_child4_model.dart';

class BottomNavChild4Widget extends StatefulWidget {
  const BottomNavChild4Widget({super.key});

  @override
  State<BottomNavChild4Widget> createState() => _BottomNavChild4WidgetState();
}

class _BottomNavChild4WidgetState extends State<BottomNavChild4Widget> {
  late BottomNavChild4Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomNavChild4Model());

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
              Icons.home_outlined,
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
              Icons.medical_services_outlined,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'pharma',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Sang',
            icon: Icon(
              Icons.water_drop_outlined,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'sang',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel4,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Médecins',
            icon: Icon(
              Icons.medical_information,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            target: 'medecins',
            selected: true,
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
            target: 'profil',
            selected: false,
          ),
        ),
      ],
    );
  }
}
