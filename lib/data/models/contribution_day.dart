/// A single day in the GitHub contribution calendar.
class ContributionDay {
  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
  });

  /// The calendar date (local midnight).
  final DateTime date;

  /// Number of contributions on this day.
  final int count;

  /// Intensity level 0–4, matching GitHub's five green shades
  /// (0 = none, 4 = highest activity).
  final int level;

  /// Parses one `contributionDays` entry from the GitHub GraphQL API.
  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: DateTime.parse(json['date'] as String),
      count: (json['contributionCount'] as num).toInt(),
      level: _levelFromString(json['contributionLevel'] as String?),
    );
  }

  static int _levelFromString(String? level) {
    switch (level) {
      case 'FIRST_QUARTILE':
        return 1;
      case 'SECOND_QUARTILE':
        return 2;
      case 'THIRD_QUARTILE':
        return 3;
      case 'FOURTH_QUARTILE':
        return 4;
      case 'NONE':
      default:
        return 0;
    }
  }
}
