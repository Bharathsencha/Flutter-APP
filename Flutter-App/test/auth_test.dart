import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/main.dart';
import 'package:video_downloader/services/auth_provider.dart';

void main() {
  group('Authentication System Tests', () {
    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const VideoDownloaderApp(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Can navigate to sign up', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const VideoDownloaderApp(),
        ),
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Login validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const VideoDownloaderApp(),
        ),
      );

      // Try to login without entering credentials
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill all fields'), findsOneWidget);
    });
  });
}
