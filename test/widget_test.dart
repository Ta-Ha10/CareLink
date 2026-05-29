import 'package:carelink/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CareLink splash navigates to role selection', (tester) async {
    await tester.pumpWidget(const CareLinkApp());

    expect(find.text('CareLink'), findsOneWidget);
    expect(find.text('Precision Care for Every Generation'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to CareLink'), findsOneWidget);
    expect(find.text('I am a Patient'), findsOneWidget);
  });
}
