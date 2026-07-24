import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:github_widget/data/services/github_auth.dart';

void main() {
  group('DeviceCodeResponse', () {
    test('parses the device-code response', () {
      final r = DeviceCodeResponse.fromJson({
        'device_code': 'dc123',
        'user_code': 'ABCD-1234',
        'verification_uri': 'https://github.com/login/device',
        'interval': 5,
        'expires_in': 900,
      });
      expect(r.deviceCode, 'dc123');
      expect(r.userCode, 'ABCD-1234');
      expect(r.verificationUri, 'https://github.com/login/device');
      expect(r.interval, 5);
      expect(r.expiresIn, 900);
    });
  });

  group('TokenPollResult', () {
    test('success carries the token', () {
      final r = TokenPollResult.fromJson({'access_token': 'gho_abc'});
      expect(r.status, PollStatus.success);
      expect(r.token, 'gho_abc');
    });

    test('maps known error codes', () {
      expect(TokenPollResult.fromJson({'error': 'authorization_pending'}).status,
          PollStatus.pending);
      expect(TokenPollResult.fromJson({'error': 'slow_down'}).status,
          PollStatus.slowDown);
      expect(TokenPollResult.fromJson({'error': 'access_denied'}).status,
          PollStatus.denied);
      expect(TokenPollResult.fromJson({'error': 'expired_token'}).status,
          PollStatus.expired);
      expect(TokenPollResult.fromJson({'error': 'whatever'}).status,
          PollStatus.unknown);
    });
  });

  group('pollForToken', () {
    DeviceCodeResponse code() => DeviceCodeResponse.fromJson({
          'device_code': 'dc',
          'user_code': 'X',
          'verification_uri': 'https://github.com/login/device',
          'interval': 1,
          'expires_in': 900,
        });

    test('returns the token once the user authorizes', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        final body = calls < 2
            ? {'error': 'authorization_pending'}
            : {'access_token': 'gho_final'};
        return http.Response(jsonEncode(body), 200);
      });
      final auth =
          GitHubAuth(clientId: 'cid', scopes: const ['read:user'], client: client);

      final token = await auth.pollForToken(code(), wait: (_) async {});

      expect(token, 'gho_final');
      expect(calls, 2);
    });

    test('throws when the user denies access', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode({'error': 'access_denied'}), 200),
      );
      final auth =
          GitHubAuth(clientId: 'cid', scopes: const ['read:user'], client: client);

      expect(
        () => auth.pollForToken(code(), wait: (_) async {}),
        throwsA(isA<GitHubAuthException>()),
      );
    });
  });
}
