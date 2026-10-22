import '/components/article_card_widget.dart';
import '/components/info_tag_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'pharmacy_page_widget.dart' show PharmacyPageWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PharmacyPageModel extends FlutterFlowModel<PharmacyPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for InfoTag.
  late InfoTagModel infoTagModel1;
  // Model for InfoTag.
  late InfoTagModel infoTagModel2;
  // Model for InfoTag.
  late InfoTagModel infoTagModel3;
  // Model for ArticleCard.
  late ArticleCardModel articleCardModel1;
  // Model for ArticleCard.
  late ArticleCardModel articleCardModel2;
  // Model for ArticleCard.
  late ArticleCardModel articleCardModel3;

  @override
  void initState(BuildContext context) {
    infoTagModel1 = createModel(context, () => InfoTagModel());
    infoTagModel2 = createModel(context, () => InfoTagModel());
    infoTagModel3 = createModel(context, () => InfoTagModel());
    articleCardModel1 = createModel(context, () => ArticleCardModel());
    articleCardModel2 = createModel(context, () => ArticleCardModel());
    articleCardModel3 = createModel(context, () => ArticleCardModel());
  }

  @override
  void dispose() {
    infoTagModel1.dispose();
    infoTagModel2.dispose();
    infoTagModel3.dispose();
    articleCardModel1.dispose();
    articleCardModel2.dispose();
    articleCardModel3.dispose();
  }
}
