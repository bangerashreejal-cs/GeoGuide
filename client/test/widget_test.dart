import 'package:flutter_test/flutter_test.dart';
import 'package:client/main.dart';

void main() {
  testWidgets('GeoGuide home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GeoGuideApp());

    expect(find.text('GeoGuide'), findsOneWidget);
    expect(find.text('Discover places around you'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });
}
