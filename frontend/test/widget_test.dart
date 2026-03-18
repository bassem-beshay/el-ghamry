import 'package:flutter_test/flutter_test.dart';
import 'package:elghamry_pharmacy/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ElGhamryPharmacyApp());
    expect(find.text('صيدلية الغمري'), findsOneWidget);
  });
}
