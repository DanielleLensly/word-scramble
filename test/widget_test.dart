import 'package:flutter_test/flutter_test.dart';
import 'package:scramble/main.dart';

void main() {
  testWidgets('App renders with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const WordScrambleApp());
    expect(find.text('✨ Scramble Quest ✨'), findsOneWidget);
  });
}
