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

/// Deterministic sample stats for previewing the widget before sign-in.
/// Numbers mirror the reference design (23-day streak, 148 PRs merged).
GitHubStats sampleGitHubStats() {
  final rng = Random(7);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = <ContributionDay>[];
  const total = 140;

  for (var i = total - 1; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final int count;
    if (i < 23) {
      count = 1 + rng.nextInt(12); // active — builds the 23-day streak
    } else if (i == 23) {
      count = 0; // the break that ends the streak at 23
    } else {
      count = rng.nextInt(10) == 0 ? 0 : rng.nextInt(14);
    }
    days.add(ContributionDay(date: date, count: count, level: _levelForCount(count)));
  }

  return GitHubStats(
    login: 'octocat',
    name: 'The Octocat',
    avatarUrl: '',
    followers: 128,
    totalStars: 2300,
    totalContributions: 1204,
    prsMerged: 148,
    contributions: days,
  );
}
