import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hobby_track/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const HobbyTrackApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
