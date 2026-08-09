import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floorpulse/main.dart';

void main() {
  testWidgets('FloorPulse app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FloorPulseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
