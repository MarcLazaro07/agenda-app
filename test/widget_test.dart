import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_app/app.dart';

void main() {
  testWidgets('Agenda app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgendaApp());
    expect(find.text('Agenda'), findsOneWidget);
  });
}
