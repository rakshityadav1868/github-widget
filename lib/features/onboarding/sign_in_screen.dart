import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../data/services/github_api.dart';
import '../../data/services/github_oauth.dart';
import '../../data/services/token_store.dart';

/// Sign in with GitHub using the OAuth authorization-code flow: the GitHub
/// authorize page opens in a secure browser tab, the user taps "Authorize",
/// and they're sent straight back to the app - no codes to copy.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onSignedIn, this.onPreview});

  /// Called with the signed-in username once a token is stored.
  final ValueChanged<String> onSignedIn;

  /// Optional: preview the widget with sample data without signing in.
  final VoidCallback? onPreview;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

enum _Stage { idle, signing, error }

class _SignInScreenState extends State<SignInScreen> {
  final _oauth = GitHubOAuth();
  final _store = TokenStore();

  _Stage _stage = _Stage.idle;
  String? _error;

  @override
  void dispose() {
    _oauth.close();
    super.dispose();
  }

  Future<void> _start() async {
    if (!AppConfig.isConfigured) {
      setState(() {
        _stage = _Stage.error;
        _error = 'Sign-in isn\'t set up yet. Deploy the auth backend and set '
            'authBackendUrl in lib/core/config.dart (see server/README.md).';
      });
      return;
    }
    setState(() {
      _stage = _Stage.signing;
      _error = null;
    });
    try {
      final token = await _oauth.signIn();
      final api = GitHubApi(token: token);
      final login = await api.fetchViewerLogin();
      api.close();
      await _store.save(token: token, login: login);
      if (mounted) widget.onSignedIn(login);
    } catch (e) {
      final message = e is GitHubOAuthException || e is GitHubApiException
          ? e.toString().split(': ').skip(1).join(': ')
          : 'Sign-in was cancelled or failed. Please try again.';
      setState(() {
        _stage = _Stage.error;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _stage == _Stage.signing
                ? const _Loading()
                : _Intro(
                    error: _error,
                    onPressed: _start,
                    onPreview: widget.onPreview,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({this.error, required this.onPressed, this.onPreview});
  final String? error;
  final VoidCallback onPressed;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/icon/icon.png',
            width: 56,
            height: 56,
          ),
        ),
        const SizedBox(height: 20),
        Text('Forge',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Sign in to show your live stats on your home screen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.code),
          label: const Text('Sign in with GitHub'),
        ),
        if (onPreview != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onPreview,
            child: const Text('Preview with sample data'),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 20),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(height: 16),
        Text('Waiting for GitHub…',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
