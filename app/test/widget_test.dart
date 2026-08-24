import 'package:flutter_test/flutter_test.dart';

import 'package:habit_forge_app/app.dart';

void main() {
  testWidgets('App builds and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitForgeApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
