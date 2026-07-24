import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_widget/data/sample_stats.dart';
import 'package:github_widget/features/preview/widget_card.dart';

void main() {
  testWidgets('WidgetCard shows streak and PRs merged', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetCard(
            stats: sampleGitHubStats(),
            brightness: Brightness.dark,
            animate: false,
          ),
        ),
      ),
    );

    expect(find.text('day streak'), findsOneWidget);
    expect(find.text('PRs merged'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('148'), findsOneWidget);
  });
}
