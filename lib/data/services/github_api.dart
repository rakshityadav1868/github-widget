import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/github_stats.dart';

/// Thrown when the GitHub API returns an error or unexpected response.
class GitHubApiException implements Exception {
  GitHubApiException(this.message);
  final String message;
  @override
  String toString() => 'GitHubApiException: $message';
}

/// Fetches real stats from GitHub's GraphQL API.
///
/// Needs an OAuth access token (provided by the sign-in flow in PR #3). The
/// single [fetchStats] call returns followers, total stars, the contribution
/// calendar, and merged-PR count in one request.
class GitHubApi {
  GitHubApi({required this.token, http.Client? client})
      : _client = client ?? http.Client();

  final String token;
  final http.Client _client;

  static const _endpoint = 'https://api.github.com/graphql';

  Future<GitHubStats> fetchStats(String login) async {
    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': _statsQuery,
        'variables': {
          'login': login,
          'prSearch': 'is:pr is:merged author:$login',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw GitHubApiException('HTTP ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['errors'] != null) {
      throw GitHubApiException(body['errors'].toString());
    }
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null || data['user'] == null) {
      throw GitHubApiException('User "$login" not found');
    }
    return GitHubStats.fromGraphQL(data);
  }

  void close() => _client.close();
}

const _statsQuery = r'''
query($login: String!, $prSearch: String!) {
  user(login: $login) {
    login
    name
    avatarUrl
    followers { totalCount }
    repositories(ownerAffiliations: OWNER, first: 100, orderBy: {field: STARGAZERS, direction: DESC}) {
      nodes { stargazerCount }
    }
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
            contributionLevel
          }
        }
      }
    }
  }
  search(query: $prSearch, type: ISSUE, first: 0) {
    issueCount
  }
}
''';
