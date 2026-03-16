import 'package:flutter_test/flutter_test.dart';
import 'package:scramble/main.dart';

void main() {
  testWidgets('App renders with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const WordScramblerApp());
    expect(find.text('✨ Kids Scramble Quest ✨'), findsOneWidget);
  });
}
