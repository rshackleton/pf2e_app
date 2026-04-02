import 'package:flutter_test/flutter_test.dart';
import 'package:pf2e_app/app.dart';

void main() {
  testWidgets('app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
  });
}
