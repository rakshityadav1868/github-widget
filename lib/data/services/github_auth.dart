import 'dart:convert';

import 'package:http/http.dart' as http;

/// Response from GitHub's device-code request.
class DeviceCodeResponse {
  const DeviceCodeResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.interval,
    required this.expiresIn,
  });

  /// Secret code the app polls with.
  final String deviceCode;

  /// Short code the user types on github.com/login/device.
  final String userCode;

  /// Where the user goes to enter the code.
  final String verificationUri;

  /// Minimum seconds between polls.
  final int interval;

  /// Seconds until [userCode] expires.
  final int expiresIn;

  factory DeviceCodeResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCodeResponse(
      deviceCode: json['device_code'] as String,
      userCode: json['user_code'] as String,
      verificationUri: json['verification_uri'] as String,
      interval: (json['interval'] as num?)?.toInt() ?? 5,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 900,
    );
  }
}

/// Outcome of a single access-token poll.
enum PollStatus { success, pending, slowDown, denied, expired, unknown }

class TokenPollResult {
  const TokenPollResult(this.status, [this.token]);
  final PollStatus status;
  final String? token;

  factory TokenPollResult.fromJson(Map<String, dynamic> json) {
    if (json['access_token'] != null) {
      return TokenPollResult(PollStatus.success, json['access_token'] as String);
    }
    switch (json['error']) {
      case 'authorization_pending':
        return const TokenPollResult(PollStatus.pending);
      case 'slow_down':
        return const TokenPollResult(PollStatus.slowDown);
      case 'access_denied':
        return const TokenPollResult(PollStatus.denied);
      case 'expired_token':
        return const TokenPollResult(PollStatus.expired);
      default:
        return const TokenPollResult(PollStatus.unknown);
    }
  }
}

class GitHubAuthException implements Exception {
  GitHubAuthException(this.message);
  final String message;
  @override
  String toString() => 'GitHubAuthException: $message';
}

/// GitHub OAuth **device flow**: no client secret required, so it's safe for a
/// mobile app. The app shows [DeviceCodeResponse.userCode] to the user, who
/// enters it at github.com/login/device; meanwhile the app polls for a token.
class GitHubAuth {
  GitHubAuth({
    required this.clientId,
    required this.scopes,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String clientId;
  final List<String> scopes;
  final http.Client _client;

  static const _deviceCodeUrl = 'https://github.com/login/device/code';
  static const _tokenUrl = 'https://github.com/login/oauth/access_token';

  Future<DeviceCodeResponse> requestDeviceCode() async {
    final response = await _client.post(
      Uri.parse(_deviceCodeUrl),
      headers: {'Accept': 'application/json'},
      body: {'client_id': clientId, 'scope': scopes.join(' ')},
    );
    if (response.statusCode != 200) {
      throw GitHubAuthException('Device code request failed (${response.statusCode})');
    }
    return DeviceCodeResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Polls until the user authorizes, then returns the access token.
  /// Respects the server's interval and `slow_down` requests.
  Future<String> pollForToken(
    DeviceCodeResponse code, {
    Future<void> Function(Duration)? wait,
  }) async {
    final delay = wait ?? (d) => Future<void>.delayed(d);
    var interval = code.interval;
    final deadline = DateTime.now().add(Duration(seconds: code.expiresIn));

    while (DateTime.now().isBefore(deadline)) {
      await delay(Duration(seconds: interval));
      final result = await _pollOnce(code.deviceCode);
      switch (result.status) {
        case PollStatus.success:
          return result.token!;
        case PollStatus.pending:
          break;
        case PollStatus.slowDown:
          interval += 5;
          break;
        case PollStatus.denied:
          throw GitHubAuthException('You declined the authorization.');
        case PollStatus.expired:
          throw GitHubAuthException('The code expired. Please try again.');
        case PollStatus.unknown:
          throw GitHubAuthException('Unexpected response from GitHub.');
      }
    }
    throw GitHubAuthException('Sign-in timed out. Please try again.');
  }

  Future<TokenPollResult> _pollOnce(String deviceCode) async {
    final response = await _client.post(
      Uri.parse(_tokenUrl),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': clientId,
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      },
    );
    return TokenPollResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  void close() => _client.close();
}
