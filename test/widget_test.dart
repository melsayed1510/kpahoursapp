import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kpa_shift_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KpaShiftApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(KpaShiftApp), findsOneWidget);
  });
}
