import 'dart:math';

import 'models/contribution_day.dart';
import 'models/github_stats.dart';

int _levelForCount(int count) {
  if (count <= 0) return 0;
  if (count < 4) return 1;
  if (count < 7) return 2;
  if (count < 10) return 3;
  return 4;
}

/// Deterministic sample stats for previewing the widget before sign-in, built
/// as real weeks (Sun → Sat) so the grid looks like GitHub's. Numbers mirror
/// the reference design (23-day streak, 148 PRs merged).
GitHubStats sampleGitHubStats() {
  final rng = Random(7);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final currentSunday = today.subtract(Duration(days: today.weekday % 7));
  final startSunday = currentSunday.subtract(const Duration(days: 51 * 7));

  final weeks = <List<ContributionDay>>[];
  var total = 0;
  for (var weekStart = startSunday;
      !weekStart.isAfter(currentSunday);
      weekStart = weekStart.add(const Duration(days: 7))) {
    final days = <ContributionDay>[];
    for (var d = 0; d < 7; d++) {
      final date = weekStart.add(Duration(days: d));
      if (date.isAfter(today)) break;
      final daysAgo = today.difference(date).inDays;
      final int count;
      if (daysAgo < 23) {
        count = 1 + rng.nextInt(12); // active - builds the 23-day streak
      } else if (daysAgo == 23) {
        count = 0; // the break that ends the streak at 23
      } else {
        count = rng.nextInt(10) == 0 ? 0 : rng.nextInt(14);
      }
      total += count;
      days.add(ContributionDay(date: date, count: count, level: _levelForCount(count)));
    }
    weeks.add(days);
  }

  return GitHubStats(
    login: 'octocat',
    name: 'The Octocat',
    avatarUrl: '',
    followers: 128,
    totalStars: 2300,
    totalContributions: total,
    prsMerged: 148,
    weeks: weeks,
  );
}
