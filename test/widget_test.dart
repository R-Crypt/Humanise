import 'package:flutter_test/flutter_test.dart';
import 'package:de_humanise/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DeHumaniseApp());
    expect(find.text('Humanise'), findsOneWidget);
  });
}
