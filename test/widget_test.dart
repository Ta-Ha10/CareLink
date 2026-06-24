import 'package:carelink/core/constants.dart';
import 'package:carelink/pages/auth_page.dart';
import 'package:carelink/pages/role_selection_page.dart';
import 'package:carelink/services/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app storage persists onboarding state', () async {
    await AppStorage.instance.clear();

    expect(
      await AppStorage.instance.readBool(AppPrefsKeys.onboardingComplete),
      isNull,
    );

    await AppStorage.instance.writeBool(AppPrefsKeys.onboardingComplete, true);
    await AppStorage.instance.writeString(
      AppPrefsKeys.preferredRole,
      UserRole.monitor.value,
    );

    expect(
      await AppStorage.instance.readBool(AppPrefsKeys.onboardingComplete),
      isTrue,
    );
    expect(
      await AppStorage.instance.readString(AppPrefsKeys.preferredRole),
      UserRole.monitor.value,
    );
  });

  testWidgets('role choice goes to login after selecting patient', (
    tester,
  ) async {
    await AppStorage.instance.clear();

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const RoleSelectionPage(),
          '/auth': (_) => const AuthPage(),
        },
      ),
    );

    await tester.tap(find.text('Continue as Patient'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(
      find.text('Futuristic wellness at your fingertips.'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
