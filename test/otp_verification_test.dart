import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allo_doctor/app_state.dart';
import 'package:allo_doctor/connect/o_t_p_verification_patient/o_t_p_verification_patient_widget.dart';
import 'package:allo_doctor/flutter_flow/nav/nav.dart';
import 'package:allo_doctor/main.dart';

const _avertissement =
    'L\'email de vérification n\'a pas pu être envoyé';

void main() {
  /// Laisse expirer les timers internes (cooldown de renvoi, splash).
  Future<void> drainer(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 61));
  }

  testWidgets('L\'écran OTP signale un email non envoyé',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: OTPVerificationPatientWidget(
        email: 'patient@example.com',
        emailSent: false,
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining(_avertissement), findsOneWidget);
    expect(find.text('patient@example.com'), findsOneWidget);

    await drainer(tester);
  });

  testWidgets('Aucun avertissement quand l\'email a bien été envoyé',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: OTPVerificationPatientWidget(
        email: 'patient@example.com',
        emailSent: true,
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining(_avertissement), findsNothing);

    await drainer(tester);
  });

  testWidgets('La route transmet email / mode / emailSent à l\'écran OTP',
      (WidgetTester tester) async {
    AppStateNotifier.instance.stopShowingSplashImage();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FFAppState(),
        child: MyApp(),
      ),
    );
    await tester.pump();

    final navigatorContext = appNavigatorKey.currentContext!;
    final router = GoRouter.of(navigatorContext);
    router.pushNamed(
      'OTPVerificationPatient',
      queryParameters: {
        'email': 'patient@example.com',
        'emailSent': 'false',
      },
    );
    await tester.pump();
    await tester.pump();

    // Les query parameters atteignent bien le widget.
    expect(find.text('patient@example.com'), findsOneWidget);
    expect(find.textContaining(_avertissement), findsOneWidget);

    await drainer(tester);
  });
}
