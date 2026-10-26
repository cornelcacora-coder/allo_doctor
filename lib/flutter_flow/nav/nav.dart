import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/Splash.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : WelcomeWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/Splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : WelcomeWidget(),
        ),
        FFRoute(
          name: TestWidget.routeName,
          path: TestWidget.routePath,
          builder: (context, params) => TestWidget(),
        ),
        FFRoute(
          name: LoginClinicWidget.routeName,
          path: LoginClinicWidget.routePath,
          builder: (context, params) => LoginClinicWidget(),
        ),
        FFRoute(
          name: OTPVerificationPatientWidget.routeName,
          path: OTPVerificationPatientWidget.routePath,
          builder: (context, params) => OTPVerificationPatientWidget(
            email: params.getParam('email', ParamType.String),
            mode: params.getParam('mode', ParamType.String),
            emailSent: params.getParam('emailSent', ParamType.bool),
            role: params.getParam('role', ParamType.String),
          ),
        ),
        FFRoute(
          name: HomeHubWidget.routeName,
          path: HomeHubWidget.routePath,
          builder: (context, params) => HomeHubWidget(),
        ),
        FFRoute(
          name: PharmaListWidget.routeName,
          path: PharmaListWidget.routePath,
          builder: (context, params) => PharmaListWidget(),
        ),
        FFRoute(
          name: UserProfileWidget.routeName,
          path: UserProfileWidget.routePath,
          builder: (context, params) => UserProfileWidget(),
        ),
        FFRoute(
          name: PharmacyManagementDashboardWidget.routeName,
          path: PharmacyManagementDashboardWidget.routePath,
          builder: (context, params) => PharmacyManagementDashboardWidget(),
        ),
        FFRoute(
          name: SignUpWidget.routeName,
          path: SignUpWidget.routePath,
          builder: (context, params) => SignUpWidget(
            role: params.getParam('role', ParamType.String) ?? 'patient',
          ),
        ),
        FFRoute(
          name: IntroWidget.routeName,
          path: IntroWidget.routePath,
          builder: (context, params) => IntroWidget(),
        ),
        FFRoute(
          name: WelcomeWidget.routeName,
          path: WelcomeWidget.routePath,
          builder: (context, params) => WelcomeWidget(),
        ),
        FFRoute(
          name: PharmacyPageWidget.routeName,
          path: PharmacyPageWidget.routePath,
          builder: (context, params) => PharmacyPageWidget(),
        ),
        FFRoute(
          name: PharmacyViewWidget.routeName,
          path: PharmacyViewWidget.routePath,
          builder: (context, params) => PharmacyViewWidget(),
        ),
        FFRoute(
          name: PharmaViewWidget.routeName,
          path: PharmaViewWidget.routePath,
          builder: (context, params) => PharmaViewWidget(),
        ),
        FFRoute(
          name: ProductViewWidget.routeName,
          path: ProductViewWidget.routePath,
          builder: (context, params) => ProductViewWidget(),
        ),
        FFRoute(
          name: DoctorViewWidget.routeName,
          path: DoctorViewWidget.routePath,
          builder: (context, params) => DoctorViewWidget(
            doctorName: params.getParam('doctorName', ParamType.String),
            specialty: params.getParam('specialty', ParamType.String),
            city: params.getParam('city', ParamType.String),
            phone: params.getParam('phone', ParamType.String),
            photoUrl: params.getParam('photoUrl', ParamType.String),
            docNumber: params.getParam('docNumber', ParamType.String),
            doctorId: params.getParam('doctorId', ParamType.String),
            isAvailable: params.getParam('isAvailable', ParamType.String),
            unavailabilityReason: params.getParam('unavailabilityReason', ParamType.String),
            availableAt: params.getParam('availableAt', ParamType.String),
          ),
        ),
        FFRoute(
          name: DoctorListWidget.routeName,
          path: DoctorListWidget.routePath,
          builder: (context, params) => DoctorListWidget(),
        ),
        FFRoute(
          name: BloodBankListWidget.routeName,
          path: BloodBankListWidget.routePath,
          builder: (context, params) => BloodBankListWidget(),
        ),
        FFRoute(
          name: ClinicListWidget.routeName,
          path: ClinicListWidget.routePath,
          builder: (context, params) => ClinicListWidget(),
        ),
        FFRoute(
          name: ProfileUserWidget.routeName,
          path: ProfileUserWidget.routePath,
          builder: (context, params) => ProfileUserWidget(),
        ),
        FFRoute(
          name: EditProfileInformationPageWidget.routeName,
          path: EditProfileInformationPageWidget.routePath,
          builder: (context, params) => EditProfileInformationPageWidget(),
        ),
        FFRoute(
          name: ProfileEditWidget.routeName,
          path: ProfileEditWidget.routePath,
          builder: (context, params) => ProfileEditWidget(
            role: params.getParam(
              'role',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: CarnetSanteWidget.routeName,
          path: CarnetSanteWidget.routePath,
          builder: (context, params) => CarnetSanteWidget(),
        ),
        FFRoute(
          name: SettingsWidget.routeName,
          path: SettingsWidget.routePath,
          builder: (context, params) => SettingsWidget(),
        ),
        FFRoute(
          name: HomePharmacyWidget.routeName,
          path: HomePharmacyWidget.routePath,
          builder: (context, params) => HomePharmacyWidget(),
        ),
        FFRoute(
          name: HomeDoctorWidget.routeName,
          path: HomeDoctorWidget.routePath,
          builder: (context, params) => HomeDoctorWidget(),
        ),
        FFRoute(
          name: ConsultationWidget.routeName,
          path: ConsultationWidget.routePath,
          builder: (context, params) => ConsultationWidget(),
        ),
        FFRoute(
          name: TeleconsultationWidget.routeName,
          path: TeleconsultationWidget.routePath,
          builder: (context, params) => TeleconsultationWidget(
            channelName: params.getParam('channelName', ParamType.String),
            token: params.getParam('token', ParamType.String),
            patientName: params.getParam('patientName', ParamType.String),
          ),
        ),
        FFRoute(
          name: DmpWidget.routeName,
          path: DmpWidget.routePath,
          builder: (context, params) => DmpWidget(),
        ),
        FFRoute(
          name: AgendaWidget.routeName,
          path: AgendaWidget.routePath,
          builder: (context, params) => AgendaWidget(),
        ),
        FFRoute(
          name: VisiteWidget.routeName,
          path: VisiteWidget.routePath,
          builder: (context, params) => VisiteWidget(),
        ),
        FFRoute(
          name: OrdonnanceWidget.routeName,
          path: OrdonnanceWidget.routePath,
          builder: (context, params) => OrdonnanceWidget(),
        ),
        FFRoute(
          name: TransactionWidget.routeName,
          path: TransactionWidget.routePath,
          builder: (context, params) => TransactionWidget(),
        ),
        FFRoute(
          name: OTPVerificationClinicWidget.routeName,
          path: OTPVerificationClinicWidget.routePath,
          builder: (context, params) => OTPVerificationClinicWidget(),
        ),
        FFRoute(
          name: PharmacyWalletPageWidget.routeName,
          path: PharmacyWalletPageWidget.routePath,
          builder: (context, params) => PharmacyWalletPageWidget(),
        ),
        FFRoute(
          name: PharmaWalletWidget.routeName,
          path: PharmaWalletWidget.routePath,
          builder: (context, params) => PharmaWalletWidget(),
        ),
        FFRoute(
          name: AddProductToWidget.routeName,
          path: AddProductToWidget.routePath,
          builder: (context, params) => AddProductToWidget(),
        ),
        FFRoute(
          name: HomeCliniqueWidget.routeName,
          path: HomeCliniqueWidget.routePath,
          builder: (context, params) => HomeCliniqueWidget(),
        ),
        FFRoute(
          name: ClinicAgendaWidget.routeName,
          path: ClinicAgendaWidget.routePath,
          builder: (context, params) => ClinicAgendaWidget(),
        ),
        FFRoute(
          name: ClinicWalletWidget.routeName,
          path: ClinicWalletWidget.routePath,
          builder: (context, params) => ClinicWalletWidget(),
        ),
        FFRoute(
          name: ClinicPatientsWidget.routeName,
          path: ClinicPatientsWidget.routePath,
          builder: (context, params) => ClinicPatientsWidget(),
        ),
        FFRoute(
          name: ClinicDMPWidget.routeName,
          path: ClinicDMPWidget.routePath,
          builder: (context, params) => ClinicDMPWidget(),
        ),
        FFRoute(
          name: ClinicLaboWidget.routeName,
          path: ClinicLaboWidget.routePath,
          builder: (context, params) => ClinicLaboWidget(),
        ),
        FFRoute(
          name: OTPVerificationPharmacyWidget.routeName,
          path: OTPVerificationPharmacyWidget.routePath,
          builder: (context, params) => OTPVerificationPharmacyWidget(),
        ),
        FFRoute(
          name: OTPVerificationDoctorWidget.routeName,
          path: OTPVerificationDoctorWidget.routePath,
          builder: (context, params) => OTPVerificationDoctorWidget(),
        ),
        FFRoute(
          name: LoginPharmacyWidget.routeName,
          path: LoginPharmacyWidget.routePath,
          builder: (context, params) => LoginPharmacyWidget(),
        ),
        FFRoute(
          name: LoginDoctorWidget.routeName,
          path: LoginDoctorWidget.routePath,
          builder: (context, params) => LoginDoctorWidget(),
        ),
        FFRoute(
          name: LoginPatientWidget.routeName,
          path: LoginPatientWidget.routePath,
          builder: (context, params) => LoginPatientWidget(),
        ),
        FFRoute(
          name: HomeAdminWidget.routeName,
          path: HomeAdminWidget.routePath,
          builder: (context, params) => HomeAdminWidget(),
        ),
        FFRoute(
          name: AdminUserListeWidget.routeName,
          path: AdminUserListeWidget.routePath,
          builder: (context, params) => AdminUserListeWidget(),
        ),
        FFRoute(
          name: IntroCopyWidget.routeName,
          path: IntroCopyWidget.routePath,
          builder: (context, params) => IntroCopyWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
