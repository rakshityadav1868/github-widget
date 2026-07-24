import 'package:flutter_test/flutter_test.dart';
import 'package:github_widget/data/sample_stats.dart';

void main() {
  test('sample stats match the reference design', () {
    final stats = sampleGitHubStats();
    expect(stats.prsMerged, 148);
    expect(stats.currentStreak, 23);
    expect(stats.followers, 128);
    expect(stats.weeks.length, greaterThan(40)); // ~a year of weeks
    expect(stats.contributions.length, greaterThan(300));
  });
}
