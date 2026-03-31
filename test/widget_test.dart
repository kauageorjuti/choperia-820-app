import 'package:choperia_820_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shell builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ChoperiaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
