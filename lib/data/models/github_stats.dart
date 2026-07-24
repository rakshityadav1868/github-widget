import 'contribution_day.dart';

/// The full set of GitHub stats shown by the app and the widget.
class GitHubStats {
  const GitHubStats({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.followers,
    required this.totalStars,
    required this.totalContributions,
    required this.prsMerged,
    required this.weeks,
  });

  final String login;
  final String? name;
  final String avatarUrl;
  final int followers;

  /// Sum of stargazers across the user's owned repositories.
  final int totalStars;

  /// Contributions in the last year (calendar total).
  final int totalContributions;

  /// Number of merged pull requests authored by the user.
  final int prsMerged;

  /// The contribution calendar as weeks (oldest week first). Each week holds
  /// its days in order (Sunday → Saturday); the first/last weeks may be
  /// partial. This is exactly GitHub's own layout: one column per week.
  final List<List<ContributionDay>> weeks;

  /// The calendar flattened to a single day list, oldest first.
  List<ContributionDay> get contributions => [
        for (final week in weeks) ...week,
      ];

  /// Current daily contribution streak. An empty most-recent day (today, not
  /// finished yet) does not break the streak; any earlier empty day does.
  int get currentStreak {
    final days = contributions;
    if (days.isEmpty) return 0;
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    var streak = 0;
    for (var i = sorted.length - 1; i >= 0; i--) {
      if (sorted[i].count > 0) {
        streak++;
      } else if (i == sorted.length - 1) {
        continue; // today may still be empty
      } else {
        break;
      }
    }
    return streak;
  }

  /// Builds stats from the `data` object of the GraphQL stats query.
  factory GitHubStats.fromGraphQL(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>;

    final followers =
        (user['followers']['totalCount'] as num?)?.toInt() ?? 0;

    final repoNodes = (user['repositories']['nodes'] as List?) ?? const [];
    final totalStars = repoNodes.fold<int>(
      0,
      (sum, r) => sum + (((r as Map)['stargazerCount'] as num?)?.toInt() ?? 0),
    );

    final calendar =
        user['contributionsCollection']['contributionCalendar'] as Map;
    final totalContributions =
        (calendar['totalContributions'] as num?)?.toInt() ?? 0;

    final weeks = <List<ContributionDay>>[];
    for (final week in (calendar['weeks'] as List)) {
      final days = <ContributionDay>[];
      for (final day in ((week as Map)['contributionDays'] as List)) {
        days.add(ContributionDay.fromJson(day as Map<String, dynamic>));
      }
      weeks.add(days);
    }

    final prsMerged =
        ((data['search'] as Map?)?['issueCount'] as num?)?.toInt() ?? 0;

    return GitHubStats(
      login: user['login'] as String,
      name: user['name'] as String?,
      avatarUrl: user['avatarUrl'] as String,
      followers: followers,
      totalStars: totalStars,
      totalContributions: totalContributions,
      prsMerged: prsMerged,
      weeks: weeks,
    );
  }
}
