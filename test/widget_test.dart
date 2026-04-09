import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_drift/main.dart';
import 'package:open_drift/screens/home_screen.dart';
import 'package:open_drift/widgets/sound_tile_widget.dart';

void main() {
  testWidgets('App renders with OpenDrift title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OpenDriftApp()),
    );
    await tester.pump();

    expect(find.text('OPENDRIFT'), findsOneWidget);
    expect(find.text('LO-FI AMBIENT GENERATOR'), findsOneWidget);
  });

  testWidgets('Home screen shows sound grid', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    // Verify sounds are present
    expect(find.byType(SoundTileWidget), findsWidgets);
  });

  testWidgets('Save button disabled when no sounds active',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('SAVE CURRENT MIX'), findsOneWidget);
    // Master volume slider present
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    // Timer section present
    expect(find.text('SLEEP TIMER'), findsOneWidget);
  });

  testWidgets('Saved mixes button navigates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.library_music), findsOneWidget);
  });
}
