import '/components/emergency_call_widget.dart';
import '/components/log_out_widget.dart';
import '/components/nav_bar_user_widget.dart';
import '/components/service_card_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'home_hub_widget.dart' show HomeHubWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeHubModel extends FlutterFlowModel<HomeHubWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Dropdown widget.
  String? dropdownValue;
  FormFieldController<String>? dropdownValueController;
  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  TextEditingController? searchController;
  int carouselCurrentIndex = 1;

  // Model for ServiceCard.
  late ServiceCardModel serviceCardModel1;
  // Model for ServiceCard.
  late ServiceCardModel serviceCardModel2;
  // Model for ServiceCard.
  late ServiceCardModel serviceCardModel3;
  // Model for ServiceCard.
  late ServiceCardModel serviceCardModel4;
  // Model for NavBarUser component.
  late NavBarUserModel navBarUserModel;

  @override
  void initState(BuildContext context) {
    serviceCardModel1 = createModel(context, () => ServiceCardModel());
    serviceCardModel2 = createModel(context, () => ServiceCardModel());
    serviceCardModel3 = createModel(context, () => ServiceCardModel());
    serviceCardModel4 = createModel(context, () => ServiceCardModel());
    navBarUserModel = createModel(context, () => NavBarUserModel());
  }

  @override
  void dispose() {
    serviceCardModel1.dispose();
    serviceCardModel2.dispose();
    serviceCardModel3.dispose();
    serviceCardModel4.dispose();
    navBarUserModel.dispose();
    searchController?.dispose();
  }
}
