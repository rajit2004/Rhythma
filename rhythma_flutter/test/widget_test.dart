import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rhythma/screens/profile/profile_screen.dart';
import 'package:rhythma/services/local_storage_service.dart';

void main() {
  // Setup temporary Hive path for testing
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox<Map>('user_profile');
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<Map>('cycle_logs');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Profile Screen renders name, stats, and elements correctly', (WidgetTester tester) async {
    // Save a mock profile first
    await LocalStorageService.saveProfile({
      'name': 'Aarya Test',
      'age': 30,
      'cycle_length': 29,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileScreen(),
        ),
      ),
    );

    // Advance the clock by 1 second to let entry animations complete
    await tester.pump(const Duration(seconds: 1));

    // Verify profile details are rendered
    expect(find.text('Aarya Test'), findsOneWidget);
    expect(find.text('30 years old'), findsOneWidget);
    expect(find.text('29 days'), findsOneWidget);
    expect(find.text('Cycle Day 12 • Follicular Phase'), findsOneWidget);

    // Verify stats and settings sections
    expect(find.text('Quick Stats'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);

    // Verify menu items
    expect(find.text('Edit Profile Information'), findsOneWidget);
    expect(find.text('Medical Emergency Contact'), findsOneWidget);
    expect(find.text('App Settings'), findsOneWidget);
  });
}
