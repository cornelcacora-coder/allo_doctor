import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nav_bar_user_model.dart';
export 'nav_bar_user_model.dart';

/// the user main navbar
class NavBarUserWidget extends StatefulWidget {
  const NavBarUserWidget({super.key});

  @override
  State<NavBarUserWidget> createState() => _NavBarUserWidgetState();
}

class _NavBarUserWidgetState extends State<NavBarUserWidget> {
  late NavBarUserModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarUserModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = '';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation.toLowerCase();
    } catch (_) {}

    final isAccueil = currentRoute.isEmpty ||
        currentRoute.contains('home') ||
        currentRoute == '/';
    final isPharma = currentRoute.contains('pharma');
    final isSang = currentRoute.contains('blood') || currentRoute.contains('sang');
    final isProfil = currentRoute.contains('profile') || currentRoute.contains('profil');

    const activeColor = Color(0xFF007A55);
    const inactiveColor = Color(0xFF4A6B5E);

    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 12.0),
        child: Container(
          height: 72.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(36.0)),
            border: Border.fromBorderSide(
              BorderSide(
                color: Color(0xFFE3EDE7),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18.0,
                offset: Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Accueil
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (!isAccueil) {
                        context.pushNamed(HomeHubWidget.routeName);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          size: 24.0,
                          color: isAccueil ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Accueil',
                          style: GoogleFonts.outfit(
                            fontSize: 11.0,
                            fontWeight: isAccueil ? FontWeight.bold : FontWeight.w500,
                            color: isAccueil ? activeColor : inactiveColor,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (isAccueil)
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            width: 18.0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
                  ),
                ),

                // 2. Pharma
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(PharmaListWidget.routeName);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 23.0,
                          color: isPharma ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Pharma',
                          style: GoogleFonts.outfit(
                            fontSize: 11.0,
                            fontWeight: isPharma ? FontWeight.bold : FontWeight.w500,
                            color: isPharma ? activeColor : inactiveColor,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (isPharma)
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            width: 18.0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
                  ),
                ),

                // 3. Center Floating Action Button (Carnet de Santé)
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed(CarnetSanteWidget.routeName);
                  },
                  child: Container(
                    width: 54.0,
                    height: 54.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007A55), Color(0xFF00A86B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33007A55),
                          blurRadius: 10.0,
                          offset: Offset(0.0, 4.0),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),

                // 4. Sang
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(BloodBankListWidget.routeName);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 23.0,
                          color: isSang ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Sang',
                          style: GoogleFonts.outfit(
                            fontSize: 11.0,
                            fontWeight: isSang ? FontWeight.bold : FontWeight.w500,
                            color: isSang ? activeColor : inactiveColor,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (isSang)
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            width: 18.0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
                  ),
                ),

                // 5. Profil
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(ProfileUserWidget.routeName);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 23.0,
                          color: isProfil ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Profil',
                          style: GoogleFonts.outfit(
                            fontSize: 11.0,
                            fontWeight: isProfil ? FontWeight.bold : FontWeight.w500,
                            color: isProfil ? activeColor : inactiveColor,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (isProfil)
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            width: 18.0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
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
