import 'package:flutter_test/flutter_test.dart';
import 'package:github_widget/data/sample_stats.dart';

void main() {
  test('sample stats match the reference design', () {
    final stats = sampleGitHubStats();
    expect(stats.prsMerged, 148);
    expect(stats.currentStreak, 23);
    expect(stats.contributions.length, 140);
    expect(stats.followers, 128);
  });
}
