import 'package:flutter_test/flutter_test.dart';
import 'package:github_widget/data/models/contribution_day.dart';
import 'package:github_widget/data/models/github_stats.dart';

Map<String, dynamic> _day(String date, int count, String level) => {
      'date': date,
      'contributionCount': count,
      'contributionLevel': level,
    };

void main() {
  group('ContributionDay', () {
    test('maps GraphQL level strings to 0-4', () {
      expect(ContributionDay.fromJson(_day('2026-01-01', 0, 'NONE')).level, 0);
      expect(ContributionDay.fromJson(_day('2026-01-02', 1, 'FIRST_QUARTILE')).level, 1);
      expect(ContributionDay.fromJson(_day('2026-01-03', 5, 'SECOND_QUARTILE')).level, 2);
      expect(ContributionDay.fromJson(_day('2026-01-04', 9, 'THIRD_QUARTILE')).level, 3);
      expect(ContributionDay.fromJson(_day('2026-01-05', 20, 'FOURTH_QUARTILE')).level, 4);
    });
  });

  group('GitHubStats.fromGraphQL', () {
    final data = {
      'user': {
        'login': 'octocat',
        'name': 'The Octocat',
        'avatarUrl': 'https://example.com/a.png',
        'followers': {'totalCount': 128},
        'repositories': {
          'nodes': [
            {'stargazerCount': 2000},
            {'stargazerCount': 300},
            {'stargazerCount': 0},
          ],
        },
        'contributionsCollection': {
          'contributionCalendar': {
            'totalContributions': 1204,
            'weeks': [
              {
                'contributionDays': [
                  _day('2026-01-01', 3, 'FIRST_QUARTILE'),
                  _day('2026-01-02', 0, 'NONE'),
                ],
              },
              {
                'contributionDays': [
                  _day('2026-01-03', 7, 'THIRD_QUARTILE'),
                  _day('2026-01-04', 2, 'FIRST_QUARTILE'),
                ],
              },
            ],
          },
        },
      },
      'search': {'issueCount': 148},
    };

    test('parses top-level stats', () {
      final stats = GitHubStats.fromGraphQL(data);
      expect(stats.login, 'octocat');
      expect(stats.name, 'The Octocat');
      expect(stats.followers, 128);
      expect(stats.totalStars, 2300);
      expect(stats.totalContributions, 1204);
      expect(stats.prsMerged, 148);
      expect(stats.contributions.length, 4);
    });
  });

  group('currentStreak', () {
    GitHubStats withDays(List<ContributionDay> days) => GitHubStats(
          login: 'x',
          name: null,
          avatarUrl: '',
          followers: 0,
          totalStars: 0,
          totalContributions: 0,
          prsMerged: 0,
          weeks: [days],
        );

    test('counts consecutive active days from the end', () {
      final stats = withDays([
        ContributionDay(date: DateTime(2026, 1, 1), count: 5, level: 2),
        ContributionDay(date: DateTime(2026, 1, 2), count: 1, level: 1),
        ContributionDay(date: DateTime(2026, 1, 3), count: 2, level: 1),
      ]);
      expect(stats.currentStreak, 3);
    });

    test('an empty most-recent day (today) does not break the streak', () {
      final stats = withDays([
        ContributionDay(date: DateTime(2026, 1, 1), count: 5, level: 2),
        ContributionDay(date: DateTime(2026, 1, 2), count: 1, level: 1),
        ContributionDay(date: DateTime(2026, 1, 3), count: 0, level: 0),
      ]);
      expect(stats.currentStreak, 2);
    });

    test('an earlier gap breaks the streak', () {
      final stats = withDays([
        ContributionDay(date: DateTime(2026, 1, 1), count: 5, level: 2),
        ContributionDay(date: DateTime(2026, 1, 2), count: 0, level: 0),
        ContributionDay(date: DateTime(2026, 1, 3), count: 2, level: 1),
      ]);
      expect(stats.currentStreak, 1);
    });

    test('empty calendar yields zero', () {
      expect(withDays(const []).currentStreak, 0);
    });
  });
}
