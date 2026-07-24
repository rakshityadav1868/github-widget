import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_widget/features/onboarding/sign_in_screen.dart';

void main() {
  testWidgets('Sign-in screen shows the GitHub sign-in button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(onSignedIn: (_) {})),
    );

    expect(find.text('Sign in with GitHub'), findsOneWidget);
    expect(find.text('GitHub Widget'), findsOneWidget);
  });
}
