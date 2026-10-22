import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allo_doctor/connect/login_clinic/login_clinic_widget.dart';
import 'package:allo_doctor/auth/role_guard.dart';
import 'package:allo_doctor/connect/login_doctor/login_doctor_widget.dart';
import 'package:allo_doctor/index.dart';
import 'package:allo_doctor/connect/login_patient/login_patient_widget.dart';
import 'package:allo_doctor/connect/login_pharmacy/login_pharmacy_widget.dart';
import 'package:allo_doctor/connect/sign_up/sign_up_widget.dart';

/// Les 5 ecrans de connexion de l'application Allo Doctor.
const _authScreens = <String, Widget>{
  'LoginDoctor': LoginDoctorWidget(),
  'LoginPatient': LoginPatientWidget(),
  'LoginPharmacy': LoginPharmacyWidget(),
  'LoginClinic': LoginClinicWidget(),
  'SignUp': SignUpWidget(),
};

/// Le champ mot de passe est le seul EditableText masque de l'ecran.
Finder _maskedPasswordField() => find.byWidgetPredicate(
      (w) => w is EditableText && w.obscureText,
      description: 'champ mot de passe masque',
    );

void main() {
  group('Modeles de connexion', () {
    // Regression : un champ declare `late` leve un LateInitializationError
    // des que l'ecran est construit, si initState n'a pas encore tourne
    // (modele reutilise apres un hot reload, instance recreee...).
    test('passwordVisibility est lisible sans initState', () {
      expect(LoginDoctorModel().passwordVisibility, isFalse);
      expect(LoginPatientModel().passwordVisibility, isFalse);
      expect(LoginPharmacyModel().passwordVisibility, isFalse);
      expect(LoginClinicModel().passwordVisibility, isFalse);
      expect(SignUpModel().passwordVisibility, isFalse);
    });
  });

  group('Ecrans de connexion', () {
    for (final entry in _authScreens.entries) {
      testWidgets('${entry.key} se construit sans exception',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: entry.value));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('${entry.key} : le mot de passe est masque puis visible',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: entry.value));
        await tester.pump();

        // Le mot de passe est masque par defaut.
        expect(_maskedPasswordField(), findsOneWidget);

        // L'icone oeil bascule la visibilite du mot de passe.
        final eye = find.byIcon(Icons.visibility_off_outlined);
        expect(eye, findsOneWidget);

        await tester.ensureVisible(eye);
        await tester.tap(eye);
        await tester.pump();

        expect(_maskedPasswordField(), findsNothing);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      });
    }
  });

  group('Inscription', () {
    testWidgets('Un patient n\'a pas les champs d\'agrément',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: SignUpWidget(role: 'patient')));
      await tester.pump();

      expect(find.text('SPÉCIALITÉ *'), findsNothing);
      expect(find.text("N° D'ORDRE / LICENCE *"), findsNothing);
      // Le titre et le bouton portent tous deux « Créer un compte »
      expect(find.text('Créer un compte'), findsWidgets);
      expect(find.text('Créer un compte patient'), findsNothing);
    });

    testWidgets('Un médecin doit fournir sa spécialité et son n° d\'ordre',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: SignUpWidget(role: 'medecin')));
      await tester.pump();

      expect(find.text('SPÉCIALITÉ *'), findsOneWidget);
      expect(find.text("N° D'ORDRE / LICENCE *"), findsOneWidget);
      expect(find.text('Créer un compte médecin'), findsOneWidget);
    });

    testWidgets('Une pharmacie et une clinique ont aussi un dossier d\'agrément',
        (WidgetTester tester) async {
      for (final role in ['pharmacie', 'clinique']) {
        await tester.pumpWidget(MaterialApp(home: SignUpWidget(role: role)));
        await tester.pump();
        expect(find.text('SPÉCIALITÉ *'), findsOneWidget);
        expect(find.text("N° D'ORDRE / LICENCE *"), findsOneWidget);
      }
    });
  });

  group('Garde-fou de rôle', () {
    test('Chaque rôle a son propre accueil', () {
      expect(homeRouteForRole('medecin'), HomeDoctorWidget.routeName);
      expect(homeRouteForRole('pharmacie'), HomePharmacyWidget.routeName);
      expect(homeRouteForRole('clinique'), HomeCliniqueWidget.routeName);
      expect(homeRouteForRole('patient'), HomeHubWidget.routeName);
    });

    test('Un rôle inconnu retombe sur l\'accueil patient', () {
      expect(homeRouteForRole(null), HomeHubWidget.routeName);
      expect(homeRouteForRole('admin'), HomeHubWidget.routeName);
      expect(homeRouteForRole('inconnu'), HomeHubWidget.routeName);
    });

    test('Le libellé du rôle est lisible', () {
      expect(roleLabel('medecin'), 'médecin');
      expect(roleLabel('pharmacie'), 'pharmacie');
      expect(roleLabel('clinique'), 'clinique');
      expect(roleLabel('patient'), 'patient');
    });

    test('Les rôles applicatifs sont les seuls acceptés à l\'inscription', () {
      expect(kAppRoles, ['patient', 'medecin', 'pharmacie', 'clinique']);
      expect(kAppRoles.contains('admin'), isFalse);
    });
  });
}
