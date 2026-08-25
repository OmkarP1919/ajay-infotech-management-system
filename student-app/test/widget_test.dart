import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_app/features/auth/presentation/splash_screen.dart';

void main() {
  testWidgets(
      'SplashScreen renders Ajay Infotech branding and Get Started button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Brand title is rendered
    expect(find.text('AJAY INFOTECH'), findsOneWidget);
    expect(find.text('Empowering Future Innovators'), findsOneWidget);
    expect(find.text('ISO 9001:2015 Certified Institute'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
