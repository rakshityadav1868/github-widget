import 'package:flutter_test/flutter_test.dart';

import 'package:github_widget/main.dart';

void main() {
  testWidgets('App boots and shows the title', (WidgetTester tester) async {
    await tester.pumpWidget(const GitHubWidgetApp());

    expect(find.text('GitHub Widget'), findsOneWidget);
  });
}
