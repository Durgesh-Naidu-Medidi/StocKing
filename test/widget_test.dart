
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stocking/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StocKing app launches successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StocKingApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('StocKing 👑'), findsOneWidget);
  });
}
