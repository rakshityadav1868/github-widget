import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../../core/config.dart';

class GitHubOAuthException implements Exception {
  GitHubOAuthException(this.message);
  final String message;
  @override
  String toString() => 'GitHubOAuthException: $message';
}

/// GitHub sign-in via the OAuth **authorization-code flow**.
///
/// Opens the GitHub authorize page in a secure in-app browser tab; the user
/// just taps "Authorize" and is sent straight back to the app. The returned
/// `code` is exchanged for a token by the backend (which holds the secret).
class GitHubOAuth {
  GitHubOAuth({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Runs the full flow and returns the access token.
  Future<String> signIn() async {
    final authorizeUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': AppConfig.githubClientId,
      'redirect_uri': AppConfig.authRedirectUri,
      'scope': AppConfig.githubScopes.join(' '),
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authorizeUrl.toString(),
      callbackUrlScheme: AppConfig.authCallbackScheme,
    );

    final params = Uri.parse(result).queryParameters;
    if (params['error'] != null) {
      throw GitHubOAuthException(
          params['error_description'] ?? params['error']!);
    }
    final code = params['code'];
    if (code == null) {
      throw GitHubOAuthException('No authorization code returned.');
    }

    return _exchange(code);
  }

  Future<String> _exchange(String code) async {
    final response = await _client.post(
      Uri.parse(AppConfig.authBackendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode != 200) {
      throw GitHubOAuthException('Token exchange failed (${response.statusCode}).');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['access_token'];
    if (token is! String) {
      throw GitHubOAuthException('No token returned from the backend.');
    }
    return token;
  }

  void close() => _client.close();
}
